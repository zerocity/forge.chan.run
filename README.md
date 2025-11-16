# Dummy Test Project

A fullstack TypeScript application with Express backend and React frontend, featuring comprehensive QA tooling.

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
- Playwright for E2E testing

**Infrastructure:**
- pnpm workspace for monorepo management
- PostgreSQL via Docker Compose
- Pitchfork for daemon management
- Localias for custom domains

## Prerequisites

- [mise](https://mise.jdx.dev/) - Tool version manager
- [Docker](https://www.docker.com/) - For PostgreSQL
- [Pitchfork](https://github.com/jdx/pitchfork) - Daemon manager
- [Localias](https://github.com/peterldowns/localias) - Custom domain manager

## Quick Start

```bash
# Install all tools and dependencies
mise install

# Install pnpm dependencies
pnpm install

# Start development environment (PostgreSQL + Backend + Frontend)
mise run dev
```

Your application will be available at:
- Frontend: http://frontend.test:5173
- Backend: http://backend.test:3000
- Database: postgresql://testuser:testpass@localhost:5432/testdb

## Available Commands

```bash
# Development
mise run dev        # Start PostgreSQL, backend, and frontend
mise run stop       # Stop all services

# Building
mise run build      # Build backend and frontend for production

# Testing
mise run test       # Run all tests (backend + frontend + E2E)
pnpm test          # Run unit tests only
pnpm exec playwright test  # Run E2E tests only

# Code Quality
pnpm run lint       # Lint all code
pnpm run lint:fix   # Fix linting issues
pnpm run fmt        # Format all code with Prettier

# Utilities
mise tasks          # List all available tasks
mise run clean      # Clean build artifacts and dependencies
```

## Project Structure

```
.
├── .config/
│   ├── mise.toml              # Tool versions and environment
│   ├── localias.yaml          # Custom domain configuration
│   └── mise/
│       └── tasks/             # Development tasks
│           ├── dev.sh         # Start all services
│           ├── stop.sh        # Stop all services
│           ├── build.sh       # Build project
│           └── test.sh        # Run tests
├── backend/
│   ├── src/
│   │   ├── app.ts            # Express app setup
│   │   └── index.ts          # Server entry point
│   ├── tests/                # Backend unit tests
│   ├── package.json
│   ├── tsconfig.json
│   ├── vitest.config.ts
│   ├── .eslintrc.json
│   └── .prettierrc
├── frontend/
│   ├── src/
│   │   ├── App.tsx           # Main React component
│   │   ├── App.test.tsx      # Component tests
│   │   └── main.tsx          # React entry point
│   ├── tests/                # Frontend unit tests
│   ├── package.json
│   ├── tsconfig.json
│   ├── vite.config.ts
│   ├── vitest.config.ts
│   ├── .eslintrc.json
│   └── .prettierrc
├── e2e/
│   └── app.spec.ts           # Playwright E2E tests
├── docker-compose.yml        # PostgreSQL setup
├── pitchfork.toml            # Backend/Frontend daemon config
├── playwright.config.ts      # Playwright configuration
├── pnpm-workspace.yaml       # pnpm workspace config
└── package.json              # Root package.json
```

## Development Workflow

1. Start the development environment:
   ```bash
   mise run dev
   ```

2. Make changes to backend or frontend code

3. Run tests:
   ```bash
   # Unit tests
   cd backend && pnpm test
   cd frontend && pnpm test

   # E2E tests
   pnpm exec playwright test
   ```

4. Format and lint:
   ```bash
   pnpm run fmt
   pnpm run lint:fix
   ```

5. Build for production:
   ```bash
   mise run build
   ```

6. Stop services when done:
   ```bash
   mise run stop
   ```

## API Endpoints

**Backend (http://backend.test:3000):**
- `GET /health` - Health check endpoint
- `GET /api/hello` - Returns a hello message
- `GET /api/data` - Returns sample data items

## License

ISC
