# Full Stack Time Tracker (Node.js + React)

A robust, production-ready **Full Stack Application** featuring a **React** frontend and a **Node.js** backend. It showcases **Clean Architecture**, **TypeScript**, **PostgreSQL**, **Docker**, and **Nginx** reverse proxying.

## 🚀 Features

### 🎨 Frontend (`frontend/`)
-   **React 19 & Vite**: Fast, modern UI development.
-   **Tailwind CSS**: Utility-first styling with "Glassmorphism" aesthetics.
-   **Time Tracking UI**: Clean interface to manage work logs.

### ⚙️ Backend (`backend/`)
-   **Clean Architecture**: Separation of concerns (Domain, Application, Infrastructure, Interface).
-   **Node.js & Express**: Scalable server-side logic.
-   **PostgreSQL**: Relational database with connection pooling.
-   **Flyway**: Automated database migrations.

### 🏗️ Infrastructure
-   **Monorepo Structure**: Separate `frontend` and `backend` directories.
-   **Nginx Gateway**: Serves static files and proxies API requests on port 80.
-   **Docker Compose**: Orchestrates the entire stack (Frontend, Backend, DB, Migrations).

---

## 🛠️ Setup & Installation

### Prerequisites
-   Docker & Docker Compose
-   Node.js (for local development)

### 🚀 Fast Start (Docker)
Run the entire application stack:
```bash
docker-compose up --build
```
-   **Web App**: [http://localhost](http://localhost) (Nginx -> React)
-   **API**: [http://localhost/items](http://localhost/items) (Nginx -> Node.js)
-   **DB**: `localhost:5432`

### 💻 Local Development (Root Directory)
You can now manage both `frontend` and `backend` from the root directory using the centralized `package.json`.

1.  **Install Dependencies** (Installs for both frontend and backend):
    ```bash
    npm install
    ```

2.  **Start Applications**:
    -   **Frontend**: `npm run start:frontend`
    -   **Backend**: `npm run start:backend`

3.  **Build Applications**:
     -   **Frontend**: `npm run build:frontend`
     -   **Backend**: `npm run build:backend`

---

## 📂 Project Structure

```
├── package.json        # Root configuration & workspaces
├── backend/            # Node.js Application
│   ├── src/           # Source code (Clean Architecture)
│   ├── db/            # Database migrations
│   └── Dockerfile     # Backend container
│
├── frontend/           # React Application
│   ├── src/           # UI Components
│   └── Dockerfile     # Frontend + Nginx container
│
└── docker-compose.yml  # Stack orchestration
```

---

## 🧪 Testing

Run all tests across the entire monorepo from the root:
```bash
npm test
```

### Or run individually:
-   **Frontend**: `npm run test --workspace=frontend`
-   **Backend**: `npm run test --workspace=backend`

### Manual API Testing
Import `backend/postman_collection.json` into Postman.

---

## ⚙️ CI/CD Configuration

The project uses a `Jenkinsfile` configured to build and deploy from the `backend/` directory.
-   **Build**: Compiles TypeScript.
-   **Deploy**: Executes `run-hub.sh` (located in `backend/`) to pull/run Docker images.
