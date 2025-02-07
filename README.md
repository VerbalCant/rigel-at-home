# Rigel@Home

A distributed computing platform that allows running distributed tasks across multiple devices, similar to SETI@home. The platform consists of a coordination server and agent devices that can run various tasks including file processing and LLM operations.

## Architecture

- **Coordination Server**: Rails API backend with PostgreSQL and Redis
- **Agent**: Cross-platform Electron application with React UI
- **Task Engine**: Python-based task execution system

## Development Setup

### Prerequisites

- Docker Desktop
- VS Code with Remote - Containers extension
- Git

### Getting Started

1. Clone the repository:
```bash
git clone <repository-url>
cd rigel-at-home
```

2. Open in VS Code:
```bash
code .
```

3. When prompted, click "Reopen in Container" or run the "Remote-Containers: Reopen in Container" command from the command palette.

4. The container will build and install all dependencies. This may take a few minutes the first time.

### Development Workflow

- The Rails server runs on port 3000
- PostgreSQL runs on port 5432
- Redis runs on port 6379
- All changes in the workspace are automatically synced with the container

## Project Structure

```
.
├── .devcontainer/          # Development container configuration
├── server/                 # Rails API server
├── agent/                  # Electron-based agent application
└── tasks/                  # Task definitions and scripts
```

## License

MIT 