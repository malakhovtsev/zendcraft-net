import dotenv from 'dotenv';

dotenv.config();

export const PORT = Number(process.env.PORT) || 3000;

export const CORS_ORIGINS = [
  'http://localhost:3000',
  'https://www.zendcraft.net',
  'https://zendcraft.net',
];

export const javaServer = {
  host: process.env.JAVA_SERVER_HOST || 'localhost',
  port: parseInt(process.env.JAVA_SERVER_PORT || '25565'),
};
