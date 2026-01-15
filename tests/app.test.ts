import request from 'supertest';
import { createApp } from '../src/app';
import { getPool } from '../src/db';
import { PostgresItemRepository } from '../src/infrastructure/db/PostgresItemRepository';
import { ItemService } from '../src/application/ItemService';
import { ItemController } from '../src/interfaces/http/ItemController';

// Mock the database query
jest.mock('../src/db', () => {
    const mPool = {
        query: jest.fn(),
        connect: jest.fn(),
        end: jest.fn(),
    };
    return {
        query: jest.fn(),
        getPool: jest.fn().mockReturnValue(mPool)
    };
});

// Import the mocked query function to add implementations
// and get the mock pool
import { query } from '../src/db';

describe('API Endpoints', () => {
    let app: any;

    beforeAll(() => {
        // Compose dependencies for testing
        // accessing the mock pool from getPool would be ideal, but for now we rely on the fact 
        // that PostgresItemRepository uses the pool passed to it.
        // We need to pass the MOCK pool instance.
        const mockPool = getPool();
        const itemRepo = new PostgresItemRepository(mockPool);
        const itemService = new ItemService(itemRepo);
        const itemController = new ItemController(itemService);

        app = createApp(itemController);
    });

    beforeEach(() => {
        jest.clearAllMocks();
        // Since PostgresItemRepository calls pool.query, and we mocked 'query' export in the previous file/approach 
        // BUT here PostgresItemRepository uses `this.pool.query`.
        // We mocked getPool() to return mPool. 
        // We simply need to ensure mPool.query is the jest fn we spy on.
        (getPool() as any).query.mockImplementation(query as any);
    });

    describe('GET /health/:id', () => {
        it('should return 200 and status ok with id', async () => {
            const res = await request(app).get('/health/123');
            expect(res.statusCode).toEqual(200);
            expect(res.body).toEqual({ status: 'ok', id: '123' });
        });
    });

    describe('GET /', () => {
        it('should return 200 and welcome message', async () => {
            const res = await request(app).get('/');
            expect(res.statusCode).toEqual(200);
            expect(res.text).toContain('Hello, CI/CD');
        })
    });

    describe('POST /items', () => {
        it('should create a new item', async () => {
            const mockItem = { id: 1, name: 'Test Item' };
            // Mock the pool.query result called by Repository
            (getPool() as any).query.mockResolvedValue({ rows: [mockItem] });

            const res = await request(app)
                .post('/items')
                .send({ name: 'Test Item' });

            expect(res.statusCode).toEqual(201);
            expect(res.body).toEqual(mockItem);
            expect((getPool() as any).query).toHaveBeenCalledWith(
                expect.stringContaining('INSERT INTO items'),
                ['Test Item']
            );
        });

        it('should handle errors', async () => {
            (getPool() as any).query.mockRejectedValue(new Error('DB Error'));
            const res = await request(app).post('/items').send({ name: 'Fail' });
            expect(res.statusCode).toEqual(500);
        });

        it('should return 400 if name is missing', async () => {
            const res = await request(app).post('/items').send({});
            expect(res.statusCode).toEqual(400);
            expect(res.body).toEqual({ error: 'Name is required' });
        });
    });

    describe('GET /items', () => {
        it('should list all items', async () => {
            const mockItems = [{ id: 1, name: 'Item 1' }, { id: 2, name: 'Item 2' }];
            (getPool() as any).query.mockResolvedValue({ rows: mockItems });

            const res = await request(app).get('/items');

            expect(res.statusCode).toEqual(200);
            expect(res.body).toHaveLength(2);
            expect((getPool() as any).query).toHaveBeenCalledWith('SELECT * FROM items');
        });
    });

    describe('GET /items/:id', () => {
        it('should return an item if found', async () => {
            const mockItem = { id: 1, name: 'Item 1' };
            (getPool() as any).query.mockResolvedValue({ rows: [mockItem] });

            const res = await request(app).get('/items/1');
            expect(res.statusCode).toEqual(200);
            expect(res.body).toEqual(mockItem);
        });

        it('should return 404 if not found', async () => {
            (getPool() as any).query.mockResolvedValue({ rows: [] });
            const res = await request(app).get('/items/999');
            expect(res.statusCode).toEqual(404);
        });
    });

    describe('DELETE /items/:id', () => {
        it('should delete an item', async () => {
            (getPool() as any).query.mockResolvedValue({ rows: [] });
            const res = await request(app).delete('/items/1');
            expect(res.statusCode).toEqual(204);
            expect((getPool() as any).query).toHaveBeenCalledWith(
                expect.stringContaining('DELETE FROM items'),
                [1]
            );
        });
    });
});
