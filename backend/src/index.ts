import express from 'express';
import { PORT } from './config';
import statusRouter from './routes/status';

const app = express();

app.use('/api', statusRouter);

app.listen(PORT, '0.0.0.0', () => {
  console.log(`API server listening on port ${PORT}`);
});
