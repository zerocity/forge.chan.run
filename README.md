# Forge

A modern fullstack TypeScript bootstrap project with Express backend and React frontend, featuring comprehensive development tooling and best practices.

## Tech Stack

**Backend:**
- Express.js with TypeScript
- PostgreSQL database
- Vitest for unit testing

**Frontend:**
- React 18 with TypeScript
- Vite for fast development
- Vitest for unit testing

**QA Tools:**
- TypeScript for type safety
- ESLint for code linting
- Prettier for code formatting
- Vitest for unit testing

**Infrastructure:**
- mise for tool management and task orchestration (monorepo support enabled)
- PostgreSQL via Docker Compose
- Pitchfork for daemon management
- Localias for custom `.local` domains

## Prerequisites

- [mise](https://mise.jdx.dev/) - Tool version manager
- [Docker](https://www.docker.com/) - For PostgreSQL

**Note:** Pitchfork and Localias are installed automatically via mise.

## Quick Start

```bash
# Install all tools and dependencies
mise install

# Grant localias permission to bind to privileged ports (one-time setup)
sudo setcap CAP_NET_BIND_SERVICE=+eip $(which localias)

# Start development environment (PostgreSQL + Backend + Frontend)
mise run dev
```

**Why the setcap command?** Localias needs to bind to ports 80 and 443 to serve HTTPS traffic. Linux restricts these privileged ports to root only. The `setcap` command grants localias just the capability it needs without requiring sudo on every run. See [Troubleshooting](#troubleshooting) for details.

Your application will be available at:
- Frontend: https://www.testing.local
- Backend: https://api.testing.local
- Database: postgresql://testuser:testpass@localhost:5432/testdb

## Available Commands

```bash
# Development
mise run dev        # Start PostgreSQL, backend, and frontend (alias: mise run start)
mise run stop       # Stop all services and DNS proxy
mise run logs       # Show logs from all services

# Service Management
mise tasks          # List all available tasks
mise tasks --all    # List all tasks including hidden ones

# Code Quality
mise run //services/backend:lint         # Lint backend code
mise run //services/backend:lint-fix     # Lint and fix backend code
mise run //services/backend:fmt          # Format backend code
mise run //services/frontend:lint        # Lint frontend code
mise run //services/frontend:lint-fix    # Lint and fix frontend code
mise run //services/frontend:fmt         # Format frontend code

# Testing
mise run //services/backend:test         # Run backend tests
mise run //services/frontend:test        # Run frontend tests

# Building
mise run //services/backend:build        # Build backend for production
mise run //services/frontend:build       # Build frontend for production
```

## Project Structure

```
.
├── .config/
│   ├── docker-compose.yml     # PostgreSQL and infrastructure
│   ├── localias.yaml          # Custom .local domain configuration
│   └── mise/
│       └── tasks/             # Custom mise tasks (if any)
├── services/
│   ├── backend/
│   │   ├── src/
│   │   │   ├── app.ts        # Express app setup
│   │   │   └── index.ts      # Server entry point
│   │   ├── tests/            # Backend unit tests
│   │   ├── mise.toml         # Backend-specific tools and tasks
│   │   ├── package.json
│   │   ├── tsconfig.json
│   │   ├── vitest.config.ts
│   │   ├── .eslintrc.json
│   │   └── .prettierrc
│   └── frontend/
│       ├── src/
│       │   ├── App.tsx       # Main React component
│       │   ├── App.test.tsx  # Component tests
│       │   └── main.tsx      # React entry point
│       ├── tests/            # Frontend unit tests
│       ├── mise.toml         # Frontend-specific tools and tasks
│       ├── package.json
│       ├── tsconfig.json
│       ├── vite.config.ts
│       ├── vitest.config.ts
│       ├── .eslintrc.json
│       └── .prettierrc
├── mise.toml                  # Root mise config (monorepo mode enabled)
├── pitchfork.toml             # Daemon orchestration config
└── .gitignore
```

## Development Workflow

1. Start the development environment:
   ```bash
   mise run dev
   ```
   This will:
   - Start the localias DNS proxy (requires sudo for port 80/443)
   - Launch PostgreSQL via Docker Compose
   - Start the backend service at https://api.testing.local
   - Start the frontend service at https://www.testing.local

2. Make changes to backend or frontend code
   - Changes are hot-reloaded automatically
   - Backend uses nodemon for auto-restart
   - Frontend uses Vite HMR

3. Run tests from service directories:
   ```bash
   cd services/backend && pnpm test
   cd services/frontend && pnpm test
   ```

4. View logs:
   ```bash
   mise run logs
   ```

5. Stop services when done:
   ```bash
   mise run stop
   ```

## API Endpoints

**Backend (https://api.testing.local):**
- `GET /health` - Health check endpoint
- `GET /api/hello` - Returns a hello message
- `GET /api/data` - Returns sample data items

## Architecture Notes

This project uses a **service-based monorepo structure** with mise for orchestration:

- **mise.toml** (root): Contains `experimental_monorepo_root=true` to enable monorepo support
- **services/**: Each service has its own `mise.toml` with service-specific tools and tasks
- **pitchfork.toml**: Orchestrates all daemons (docker, backend, frontend) using mise task references
- **localias**: Provides custom `.local` domains that work over HTTPS in development

### Key Benefits

- **Isolated Dependencies**: Each service manages its own tool versions via mise
- **Task Caching**: mise caches task outputs based on `sources` and `outputs` for faster rebuilds
- **Unified Commands**: `mise run dev` starts everything; `mise run stop` stops everything
- **Custom Domains**: No more `localhost:PORT` - use clean URLs like https://api.testing.local

## Troubleshooting

### Localias fails to bind to ports 80/443

**Problem:** When running `mise run dev`, localias fails with a permission error about binding to privileged ports.

**Why:** Linux restricts binding to ports below 1024 (including 80 and 443) to root user only. Localias needs these ports to serve HTTP/HTTPS traffic.

**Solution 1 - Run with sudo (default):**
The mise task will prompt for your password when starting. This is the most secure approach.

**Solution 2 - Grant capability permanently (recommended for frequent development):**
```bash
sudo setcap CAP_NET_BIND_SERVICE=+eip $(which localias)
```

This grants localias the specific capability to bind to privileged ports without requiring sudo for every startup. More convenient and still secure (only grants port binding, not full root access).

**Verify it worked:**
```bash
getcap $(which localias)
# Should output: /path/to/localias cap_net_bind_service=eip
```

**Note:** If you upgrade localias via mise, you'll need to run the `setcap` command again since it applies to the specific binary.

## License

ISC
