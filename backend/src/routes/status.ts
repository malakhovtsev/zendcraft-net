import { Router } from 'express';
import { javaServer } from '../config';
import { pingLegacy } from '../minecraft/legacyPing';

const router = Router();

router.get('/java-server-status', async (_req, res) => {
  try {
    const status = await pingLegacy(javaServer.host, javaServer.port);

    res.json({
      server: 'java-1.5.2',
      online: true,
      playerCount: status.playersOnline,
    });
  } catch {
    res.json({
      server: 'java-1.5.2',
      online: false,
      playerCount: 0,
    });
  }
});

export default router;
