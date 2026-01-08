const request = require('supertest');
const app = require('../src/index');

describe('GET /', () => {
    it('should return Hello, CI/CD!', async () => {
        const res = await request(app).get('/');
        expect(res.statusCode).toEqual(200);
        expect(res.text).toBe('Hello, CI/CD!');
    });
});

describe('GET /health', () => {
    it('should return status ok', async () => {
        const res = await request(app).get('/health');
        expect(res.statusCode).toEqual(200);
        expect(res.body).toEqual({ status: 'ok' });
    });
});
