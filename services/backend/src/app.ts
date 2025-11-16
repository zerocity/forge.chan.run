import express, { Request, Response } from 'express';
import cors from 'cors';

export const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (_req: Request, res: Response) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Sample API endpoint
app.get('/api/hello', (_req: Request, res: Response) => {
  res.json({ message: 'Hello from Express + TypeScript!' });
});

// Sample data endpoint
app.get('/api/data', (_req: Request, res: Response) => {
  res.json({
    items: [
      { id: 1, name: 'Item 1', description: 'First test item' },
      { id: 2, name: 'Item 2', description: 'Second test item' },
      { id: 3, name: 'Item 3', description: 'Third test item' },
    ],
  });
});

// Error handling middleware
app.use((_req: Request, res: Response) => {
  res.status(404).json({ error: 'Not found' });
});
