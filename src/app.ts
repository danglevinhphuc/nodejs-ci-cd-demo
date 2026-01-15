import express, { Express, Request, Response } from 'express';
import { ItemController } from './interfaces/http/ItemController';
import { createItemRouter } from './interfaces/http/routes';

export function createApp(itemController: ItemController): Express {
    const app = express();

    app.use(express.json());

    app.get('/', (req: Request, res: Response) => {
        res.status(200).send('Hello, CI/CD with TypeScript & PostgreSQL!');
    });

    app.get('/health/:id', (req: Request, res: Response) => {
        res.status(200).json({ status: 'ok', id: req?.params?.id });
    });

    app.use('/items', createItemRouter(itemController));

    return app;
}
