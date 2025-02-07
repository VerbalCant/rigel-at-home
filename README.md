# Rigel@Home

A distributed computing platform that allows running distributed tasks across multiple devices, similar to SETI@home. The platform consists of a coordination server and agent devices that can run various tasks including file processing and LLM operations.

## Architecture

- **Coordination Server**: Rails API backend with PostgreSQL and Redis
- **Agent**: Cross-platform Electron application with React UI
- **Task Engine**: Python-based task execution system

## Development Setup

### Prerequisites

- Docker Desktop
- Git
- Node.js 18+ (for local development outside containers)
- Ruby 3.2.2 (for local development outside containers)

### Getting Started

1. Clone the repository:
```bash
git clone <repository-url>
cd rigel-at-home
```

2. Make the run script executable:
```bash
chmod +x run.sh
```

3. Start the development environment:
```bash
# Quick start (uses existing builds if available)
./run.sh

# Or perform a clean rebuild
./run.sh rebuild

# View all available commands
./run.sh help
```

The script provides several commands:
- `./run.sh start` - Start all services (default)
- `./run.sh stop` - Stop all services
- `./run.sh restart` - Restart all services
- `./run.sh rebuild` - Rebuild and start services
- `./run.sh reset` - Factory reset (removes all data, images, and volumes)
- `./run.sh logs` - Show logs (use ctrl+c to exit)
- `./run.sh status` - Show status of all services

This will start:
- Rails server on http://localhost:3000
- Agent's Vite dev server on http://localhost:3001
- PostgreSQL on port 5432
- Redis on port 6379

### Development Workflow

#### Using the Development Environment

The development environment uses Docker Compose with several services:

- **Server (Rails API)**
  - Auto-runs database migrations on startup
  - Hot-reloads for development
  - Access the API at http://localhost:3000
  - Logs are available via `./run.sh logs`

- **Agent (Electron + React)**
  - Uses Vite for development
  - Hot-reloads for both React and Electron
  - Access the UI at http://localhost:3001
  - Logs are available via `./run.sh logs`

- **Database (PostgreSQL)**
  - Persists data in a Docker volume
  - Available on port 5432
  - Credentials (dev environment):
    - Username: postgres
    - Password: postgres
    - Database: rigel_development

- **Redis**
  - Used for Sidekiq background jobs and caching
  - Available on port 6379

#### Common Development Tasks

**Running Rails Console:**
```bash
docker compose -f docker/compose.base.yml -f docker/compose.dev.yml exec server rails console
```

**Running Database Migrations:**
```bash
docker compose -f docker/compose.base.yml -f docker/compose.dev.yml exec server rails db:migrate
```

**Viewing Logs:**
```bash
# All services
./run.sh logs

# Specific service
docker compose -f docker/compose.base.yml -f docker/compose.dev.yml logs -f server
```

**Rebuilding Services:**
```bash
# Quick rebuild and restart
./run.sh rebuild

# Complete factory reset (removes all data)
./run.sh reset
```

### Testing

#### Running Server Tests

```bash
# Run all tests
docker compose -f docker/compose.base.yml -f docker/compose.dev.yml exec server bundle exec rspec

# Run specific test file
docker compose -f docker/compose.base.yml -f docker/compose.dev.yml exec server bundle exec rspec spec/path/to/file_spec.rb
```

#### Running Agent Tests

```bash
docker compose -f docker/compose.base.yml -f docker/compose.dev.yml exec agent npm test
```

## Project Structure

```
.
├── .devcontainer/          # Development container configuration
├── docker/                 # Docker configuration files
│   ├── compose.base.yml    # Base Docker Compose configuration
│   ├── compose.dev.yml     # Development-specific configuration
│   └── compose.prod.yml    # Production configuration
├── server/                 # Rails API server
│   ├── app/               # Rails application code
│   ├── config/           # Rails configuration
│   ├── db/               # Database migrations and schema
│   └── spec/             # RSpec tests
├── agent/                 # Electron-based agent application
│   ├── src/              # React application code
│   ├── electron/         # Electron-specific code
│   └── __tests__/        # Jest tests
└── tasks/                 # Task definitions and scripts
```

## Troubleshooting

### Common Issues

1. **Ports Already in Use**
   - Stop any existing services using the required ports (3000, 3001, 5432, 6379)
   - Or modify the port mappings in `docker/compose.dev.yml`

2. **Database Issues**
   - Reset the database: `docker compose exec server rails db:reset`
   - Check migrations: `docker compose exec server rails db:migrate:status`
   - Factory reset everything: `./run.sh reset`

3. **Container Build Issues**
   - Quick rebuild: `./run.sh rebuild`
   - Factory reset: `./run.sh reset`
   - Check logs: `./run.sh logs`

## License

MIT 