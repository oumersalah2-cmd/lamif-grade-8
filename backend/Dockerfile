FROM node:20-alpine

# Set working directory
WORKDIR /app

# Install wget for healthcheck (included in alpine)
RUN apk add --no-cache wget

# Copy package manifests
COPY package*.json ./
COPY prisma ./prisma/

# Install production dependencies only & generate Prisma Client
RUN npm ci --omit=dev && npx prisma generate

# Copy source code and scripts
COPY src ./src
COPY entrypoint.sh ./entrypoint.sh

# Ensure upload directory exists and set permissions for non-root 'node' user
RUN mkdir -p /app/uploads/receipts && \
    chmod +x /app/entrypoint.sh && \
    chown -R node:node /app

# Switch to non-root user
USER node

# Expose server port
EXPOSE 5000

# Container healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:5000/health || exit 1

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["node", "src/server.js"]
