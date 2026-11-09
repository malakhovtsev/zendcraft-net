import dotenv from 'dotenv';

dotenv.config();

export const PORT = Number(process.env.PORT) || 3000;

export const javaServer = {
  host: process.env.JAVA_SERVER_HOST || 'localhost',
  port: parseInt(process.env.JAVA_SERVER_PORT || '25565'),
};
