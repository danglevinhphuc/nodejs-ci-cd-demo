# Node.js CI/CD Demo

A robust, production-ready Node.js application showcasing **Clean Architecture**, **TypeScript**, **PostgreSQL**, **Docker**, and **GitHub Actions**.

## 🚀 Features

-   **Clean Architecture**: Separation of concerns (Domain, Application, Infrastructure, Interface).
-   **TypeScript**: Static typing for reliability.
-   **PostgreSQL**: Relational database with connection pooling.
-   **Flyway**: Automated database migrations.
-   **Docker & Compose**: Consistent development and deployment environments.
-   **GitHub Actions**: Automated CI/CD pipeline (Lint, Test, Build, Push).

---

## 🛠️ Setup & Installation

### Prerequisites
-   Node.js (v18+)
-   Docker & Docker Compose

### Fast Start (Local)
Run everything (DB, Migrations, App) with one command:
```bash
docker-compose up --build
```
-   App: `http://localhost:3000`
-   DB: `localhost:5432`

---

## 🏃 Manual Execution Scripts

We provide scripts to run the application manually in Docker without `docker-compose` (useful for debugging or single-container testing).

### 1. Build & Run Locally
To run the application locally in a container with a database:
```bash
docker-compose up --build
```

### 2. Run from Docker Hub
Download and run the image directly from the registry.
```bash
# Usage: sh run-hub.sh <TAG> [REPO_NAME]
sh run-hub.sh latest
# OR specific tag
sh run-hub.sh bc0e739...
# OR custom repository
sh run-hub.sh latest myuser/myrepo
```

---

## ⚙️ CI/CD Configuration
 
The project uses GitHub Actions (`.github/workflows/ci.yml`) or Jenkins (`Jenkinsfile`).

### Workflow Steps
1.  **Lint**: Checks code style (`npm run lint`).
2.  **Test**: Runs unit tests (`npm test`).
3.  **Build & Push**: Builds the Docker image and pushes to Docker Hub with `latest` and `SHA` tags.

### Required Secrets & Variables
To enable the CI/CD pipeline, configure these in your GitHub Repository settings:

| Type | Name | Description |
| :--- | :--- | :--- |
| **Secret** | `DOCKER_USERNAME` | Your Docker Hub Username |
| **Secret** | `DOCKER_PASSWORD` | Your Docker Hub Access Token |
| **Variable** | `DOCKER_REPOSITORY` | Repository name (e.g. `user/repo`) |

*Note: Define variables under `Settings > Secrets and variables > Actions > Variables` (Environment: `CI/CD Nodejs`).*

---

## 🧪 Testing

### Unit Tests
Run Jest unit tests with coverage (Threshold: 80%):
```bash
npm test
```

### API Testing (Postman)
Import `postman_collection.json` into Postman to test:
-   `GET /health`
-   `GET /items`
-   `POST /items`
-   `GET /items/:id`
-   `DELETE /items/:id`

### Manual cURL
```bash
# Health
curl http://localhost:3000/health

# Create
curl -X POST http://localhost:3000/items -H "Content-Type: application/json" -d '{"name": "Demo Item"}'

# List
curl http://localhost:3000/items
```
