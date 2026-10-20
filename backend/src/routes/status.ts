import { Router } from 'express';
import { statusLegacy, statusBedrock } from 'minecraft-server-util';
import { javaServer, bedrockServer } from '../config';

const router = Router();

router.get('/java-server-status', async (_req, res) => {
  try {
    const response = await statusLegacy(javaServer.host, javaServer.port, {
      timeout: 5000,
      enableSRV: false,
    });

    res.json({
      server: 'java-1.5.2',
      online: true,
      playerCount: response.players.online,
    });
  } catch {
    res.json({
      server: 'java-1.5.2',
      online: false,
      playerCount: 0,
    });
  }
});

router.get('/bedrock-server-status', async (_req, res) => {
  try {
    const response = await statusBedrock(bedrockServer.host, bedrockServer.port, {
      timeout: 5000,
    });

    res.json({
      server: 'bedrock',
      online: true,
      playerCount: response.players.online,
    });
  } catch {
    res.json({
      server: 'bedrock',
      online: false,
      playerCount: 0,
    });
  }
});

export default router;
