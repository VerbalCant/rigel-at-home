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

### Authentication Setup

The application uses OAuth2 for authentication. Currently supported providers:
- Google OAuth2 (implemented)
- Apple Sign In (planned)
- Microsoft Office 365 (planned)

#### Managing Rails Credentials

The application uses Rails' encrypted credentials system to securely store sensitive information like OAuth client IDs and secrets. The credentials are encrypted with a master key stored in `config/master.key` (not committed to version control).

To work with credentials:

1. Ensure you have the master key:
   - For development, get the `master.key` file from a team member
   - Place it in `server/config/master.key`
   - Never commit this file to version control

2. View current credentials:
```bash
docker compose -f docker/compose.base.yml -f docker/compose.dev.yml exec server rails credentials:show
```

3. Edit credentials:
```bash
# Using vim (default)
docker compose -f docker/compose.base.yml -f docker/compose.dev.yml exec server rails credentials:edit

# Using VS Code
EDITOR="code --wait" docker compose -f docker/compose.base.yml -f docker/compose.dev.yml exec server rails credentials:edit
```

4. Structure your credentials like this:
```yaml
# Used by Rails for signing cookies, etc.
secret_key_base: your_secret_key_base

# OAuth Providers
google:
  client_id: your_google_client_id
  client_secret: your_google_client_secret

# Add other providers similarly
apple:
  client_id: your_apple_client_id
  client_secret: your_apple_client_secret

microsoft:
  client_id: your_microsoft_client_id
  client_secret: your_microsoft_client_secret
```

#### Setting up Google OAuth2

1. Create a project in the [Google Cloud Console](https://console.cloud.google.com/)
2. Enable the Google OAuth2 API
3. Create OAuth 2.0 credentials:
   - Application type: Web application
   - Authorized JavaScript origins: 
     - `http://localhost:3000` (development)
     - `http://localhost:3001` (development)
     - Your production URLs
   - Authorized redirect URIs:
     - `http://localhost:3000/api/auth/auth/google_oauth2/callback` (development)
     - Your production callback URL

4. Add your credentials to Rails:
```bash
EDITOR="vim" rails credentials:edit
```

Add the following structure:
```yaml
google:
  client_id: your_client_id_here
  client_secret: your_client_secret_here
```

#### Adding New OAuth Providers

To add support for a new OAuth provider:

1. Add the provider gem to `server/Gemfile`:
```ruby
gem 'omniauth-provider-name'
```

2. Configure the provider in `server/config/initializers/devise.rb`:
```ruby
config.omniauth :provider_name,
                Rails.application.credentials.dig(:provider, :client_id),
                Rails.application.credentials.dig(:provider, :client_secret),
                scope: 'desired_scopes'
```

3. Add credentials in Rails:
```yaml
provider_name:
  client_id: your_client_id
  client_secret: your_client_secret
```

4. Add the provider to the User model in `server/app/models/user.rb`:
```ruby
devise :omniauthable, omniauth_providers: [:google_oauth2, :your_provider]
```

5. Add the provider to the login options in `server/app/controllers/api/auth_test_controller.rb`

6. Update the frontend to support the new provider in `agent/src/renderer/components/LoginButton.tsx`

#### User Model

Users created through OAuth will have the following fields:
- `email`: User's email from OAuth provider
- `name`: User's full name
- `provider`: OAuth provider name (e.g., 'google_oauth2')
- `uid`: Unique identifier from the provider

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