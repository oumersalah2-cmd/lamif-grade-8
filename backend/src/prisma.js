import { PrismaClient } from '@prisma/client';

let prisma;

try {
  prisma = new PrismaClient();
} catch (error) {
  console.warn('PrismaClient initialization warning:', error.message);
}

export default prisma;
