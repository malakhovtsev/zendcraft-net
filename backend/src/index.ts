import express from 'express';
import cors from 'cors';
import { PORT, CORS_ORIGINS } from './config';
import statusRouter from './routes/status';

const app = express();

app.use(cors({ origin: CORS_ORIGINS }));
app.use('/api', statusRouter);

app.listen(PORT, '0.0.0.0', () => {
  console.log(`API server listening on port ${PORT}`);
});
