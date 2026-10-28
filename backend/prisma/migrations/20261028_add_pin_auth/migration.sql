-- AlterTable User to add PIN authentication, token revocation, and rate limiting columns
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "pinHash" TEXT;
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "mustSetPin" BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "refreshTokenHash" TEXT;
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "tokenRevokedAt" TIMESTAMP(3);
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "pinResetCodeHash" TEXT;
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "pinResetExpiresAt" TIMESTAMP(3);
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "failedAttempts" INTEGER NOT NULL DEFAULT 0;
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "lockedUntil" TIMESTAMP(3);

-- Migration safety for existing users:
-- Any account created without a PIN is flagged with mustSetPin = true,
-- which requires the student to set their 6-digit PIN on their next online login.
UPDATE "User" SET "mustSetPin" = true WHERE "pinHash" IS NULL;
