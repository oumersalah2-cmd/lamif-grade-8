# Production Deployment Guide: Lamif Kutaa 8 Prep

Targeted for a pilot of **500 – 2,000 students** running on a **single small VPS** (2 vCPU, 4GB RAM, Ubuntu 22.04/24.04 LTS).

---

## 1. Server Prerequisites & Initial Setup

### A. System Requirements
- OS: Ubuntu 22.04 LTS or 24.04 LTS
- Specs: 2 vCPU, 4GB RAM, 40GB SSD
- Inbound Ports: `80` (HTTP), `443` (HTTPS), `22` (SSH)

### B. Docker & Docker Compose Installation
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl ufw git gzip

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Enable UFW Firewall
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

---

## 2. Environment Variables Configuration

In `backend/`, copy the example file and fill in production secrets:
```bash
cd backend
cp .env.example .env
nano .env
```

Ensure you set:
- `POSTGRES_PASSWORD`: Use a strong random alphanumeric string (32+ characters).
- `DATABASE_URL`: Update password to match `POSTGRES_PASSWORD`.
- `JWT_SECRET`: 64-character random string for signing student session access tokens.
- `JWT_REFRESH_SECRET`: 64-character random string for signing 90-day refresh tokens.
- `ADMIN_SECRET`: Secret header key required to invoke `POST /api/v1/auth/admin/generate-reset-code`.
- `OFFLINE_GRACE_DAYS`: Default `21`. Controls how long students can practice completely offline before an online check-in is required.
- `REQUIRE_PHONE_OTP_AT_SIGNUP`: Default `false` (0 SMS cost). If set to `true`, sends 1 SMS OTP at account creation.
- `SMS_PROVIDER`: Options `mock` (console), `http`, `ethio_telecom`, or `africastalking`.
- `BASE_URL`: Your production public domain (e.g. `https://api.lamif.org`).

Run database migration on production:
```bash
npx prisma migrate deploy
```

## 3. SSL / HTTPS Certificate Issuance (Let's Encrypt / Certbot)

For Cloudflare users: You can enable Cloudflare SSL ("Full" mode) and use an Origin Certificate, or issue a Let's Encrypt certificate:

```bash
# 1. Start nginx to serve the ACME challenge
docker compose -f docker-compose.prod.yml up -d nginx

# 2. Run certbot standalone or via webroot
docker run -it --rm --name certbot \
  -v lamif_certbot_etc:/etc/letsencrypt \
  -v lamif_certbot_var:/var/www/certbot \
  certbot/certbot certonly --webroot \
  --webroot-path=/var/www/certbot \
  -d api.lamif.org --email admin@lamif.org --agree-tos --no-eff-email

# 3. Reload nginx with certificates in place
docker compose -f docker-compose.prod.yml restart nginx
```

---

## 4. Deploying the Application

```bash
cd backend

# Build and start services in background
docker compose -f docker-compose.prod.yml up -d --build

# Verify all containers are healthy
docker compose -f docker-compose.prod.yml ps

# Follow live logs
docker compose -f docker-compose.prod.yml logs -f api
```

Prisma database migrations (`npx prisma migrate deploy`) run automatically upon container startup via `entrypoint.sh`.

---

## 5. Zero-Downtime Rolling Update & Rollback

### Zero-Downtime Deployment
```bash
git pull origin main
docker compose -f docker-compose.prod.yml build api
docker compose -f docker-compose.prod.yml up -d --no-deps api
docker compose -f docker-compose.prod.yml exec nginx nginx -s reload
```

### Rollback Procedure
If an issue occurs after deploying a new version:
```bash
# 1. Rollback code to previous git commit
git checkout HEAD~1

# 2. Rebuild and restart API service
docker compose -f docker-compose.prod.yml up -d --build --no-deps api

# 3. Verify health endpoint
curl -s http://localhost:5000/health | jq .
```

---

## 6. Database Backup & Restoration

### Automated Backup (Cron every 3 hours)
Add a crontab entry on the host:
```bash
crontab -e
```
Add the following lines:
```cron
# Run database backup every 3 hours
0 */3 * * * /home/ubuntu/lamif-grade-8/backend/scripts/backup.sh >> /var/log/lamif_backup.log 2>&1

# Prune receipts older than 45 days daily at 3:00 AM
0 3 * * * /home/ubuntu/lamif-grade-8/backend/scripts/cleanup_receipts.sh >> /var/log/lamif_cleanup.log 2>&1
```

### Manual Backup
```bash
./scripts/backup.sh
```

### Backup Verification & Restoration Testing
Test the validity of your backup at any time without touching live data:
```bash
./scripts/restore_test.sh
```

### Emergency Restore to Live Production
```bash
gunzip -c ./scripts/backups/lamif_backup_YYYYMMDD_HHMMSS.sql.gz | \
  docker exec -i lamif_postgres psql -U postgres -d lamif_kutaa_8
```

---

## 7. Monitoring Setup (Uptime Kuma)

Deploy a lightweight Uptime Kuma instance on the same VPS or an external free tier (e.g. Fly.io, Railway, or second cheap node):

```bash
docker run -d --restart=always -p 3001:3001 -v uptime-kuma:/app/data --name uptime-kuma louislam/uptime-kuma:1
```

1. Navigate to `http://YOUR_SERVER_IP:3001`
2. Add Monitor:
   - **Type**: HTTP(s)
   - **URL**: `https://api.lamif.org/health`
   - **Interval**: 60 seconds
   - **Expected Status**: 200 OK
   - **JSON Query**: `status` equals `"healthy"`
3. Setup Notifications: Telegram Bot or Email for instant alerts if server response exceeds 2,000ms or drops offline.

---

## 8. Exam-Day Go-Live Checklist

- [ ] **Change Freeze**: 48 hours before mock or live exam windows, freeze git commits and server deployments.
- [ ] **Database Connection Check**: Run `curl https://api.lamif.org/health` and verify `"database": "connected"`.
- [ ] **Disk Space Verification**: Ensure `df -h` shows > 10GB free disk space for database growth and temporary logs.
- [ ] **Backup Verification**: Run `./scripts/restore_test.sh` to ensure backups from the last 24 hours are restorable.
- [ ] **Rate Limit Readiness**: Verify Nginx is reading `X-User-Phone` so students on shared school Wi-Fi or mobile hotspots are not throttled.
- [ ] **Offline Seeding**: Confirm Android APK build has the default Grade 8 question banks bundled locally in Isar.
