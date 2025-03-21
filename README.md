# Tarot API

[![ci](https://github.com/abdul-hamid-achik/tarot-api/actions/workflows/ci.yml/badge.svg)](https://github.com/abdul-hamid-achik/tarot-api/actions/workflows/ci.yml)
[![pulumi deployment](https://github.com/abdul-hamid-achik/tarot-api/actions/workflows/pulumi-deploy.yml/badge.svg)](https://github.com/abdul-hamid-achik/tarot-api/actions/workflows/pulumi-deploy.yml)
[![preview environments](https://github.com/abdul-hamid-achik/tarot-api/actions/workflows/preview-environments.yml/badge.svg)](https://github.com/abdul-hamid-achik/tarot-api/actions/workflows/preview-environments.yml)
[![security scan](https://github.com/abdul-hamid-achik/tarot-api/actions/workflows/security-scan.yml/badge.svg)](https://github.com/abdul-hamid-achik/tarot-api/actions/workflows/security-scan.yml)
[![cleanup previews](https://github.com/abdul-hamid-achik/tarot-api/actions/workflows/cleanup-previews.yml/badge.svg)](https://github.com/abdul-hamid-achik/tarot-api/actions/workflows/cleanup-previews.yml)

![ruby](https://img.shields.io/badge/ruby-3.4-ruby.svg)
![rails](https://img.shields.io/badge/rails-8.0-rails.svg)
![license](https://img.shields.io/badge/license-MIT-green.svg)
![docker](https://img.shields.io/badge/docker-compose-blue.svg)

A Ruby on Rails API for tarot card reading and interpretation, leveraging OpenAI technologies.

## Table of Contents
- [Quick Start](#quick-start)
- [Overview](#overview)
- [Infrastructure](#infrastructure)
- [Development](#development)
- [Deployment](#deployment)
- [API Documentation](#api-documentation)
- [Command Reference](#command-reference)
- [Contributing](#contributing)
- [Troubleshooting](#troubleshooting)
- [License](#license)
- [Connection Pooling & Health Checks](#connection-pooling--health-checks)

## Quick Start

Get up and running in minutes:

```bash
# Clone the repository
git clone https://github.com/abdul-hamid-achik/tarot-api.git
cd tarot-api

# Install dependencies
bundle install

# Copy and configure environment variables
cp .env.example .env

# Set up the development environment with Docker
bundle exec rake dev:setup

# Start the API server
bundle exec rake dev

# Visit the API at http://localhost:3000
# API documentation at http://localhost:3000/docs
```

## Overview

This API provides endpoints for tarot card readings, user management, and AI-powered interpretations. It is designed to be scalable, secure, and user-friendly.

## Infrastructure

The project uses AWS infrastructure deployed via Pulumi to provide a scalable, reliable application environment. 

For detailed information about the infrastructure, see the [infrastructure/README.md](infrastructure/README.md) file.

### Technology Stack

- **Ruby on Rails 8**: A web-application framework that includes everything needed to create database-backed web applications according to the Model-View-Controller (MVC) pattern.
- **PostgreSQL**: A powerful, open source object-relational database system.
- **Redis**: An in-memory data structure store, used as a database, cache, and message broker.
- **Docker**: For containerization and consistent environments across development, staging, and production.
- **Pulumi**: Infrastructure as code tool for AWS resource provisioning.
- **Kamal**: Zero-downtime container deployments using Docker and Traefik.
- **AWS**: Cloud infrastructure provider (ECS, RDS, ElastiCache, S3, CloudFront, Route53).

### System Architecture

The application follows a microservices architecture with:

- Web API layer handling HTTP requests
- Business logic layer implementing core functionality
- Data persistence layer for storage
- Background job processing for async tasks
- AI integration layer for OpenAI/LLM interactions

```mermaid
graph TD
    Client[Client] --> ALB[Application Load Balancer]
    ALB --> Blue[Blue Deployment]
    ALB --> Green[Green Deployment]
    Blue --> API[API Service]
    Green --> API
    API --> DB[(PostgreSQL RDS)]
    API --> Cache[(Redis ElastiCache)]
    API --> S3[(S3 Storage)]
    Client --> CDN[CloudFront CDN]
    CDN --> ImageBucket[(S3 Images Bucket)]
    API --> OpenAI[OpenAI API]
```

### Environments

The project supports multiple deployment environments with their own domains:

- **Production**: https://tarotapi.cards
- **Staging**: https://staging.tarotapi.cards
- **Preview**: https://preview-{feature-name}.tarotapi.cards

### Deployment Workflow

Deployments are handled via GitHub Actions workflows:

1. **Staging Deployment**: Automatically triggered when code is merged to the main branch
2. **Preview Environments**: Created when a branch is tagged with `preview-*`
3. **Production Deployment**: Triggered when a version tag (`v*`) is created or through manual approval

## Development

### Prerequisites

- Ruby 3.4.0
- PostgreSQL 16
- Redis 7
- Docker and Docker Compose
- Node.js and Yarn

### Setup

1. Clone the repository
```bash
git clone https://github.com/abdul-hamid-achik/tarot-api.git
cd tarot-api
```

2. Install dependencies
```bash
bundle install
```

3. Setup environment variables
```bash
cp .env.example .env
```
Edit `.env` with your configuration

4. Setup development environment
```bash
bundle exec rake dev:setup
```

5. Start the server
```bash
bundle exec rake dev
```

### common development tasks

```bash
# start development environment with docker
bundle exec rake dev

# open rails console
bundle exec rake dev:console

# run tests
bundle exec rake dev:test

# view logs
bundle exec rake dev:logs

# rebuild all containers
bundle exec rake dev:rebuild
```

### running tests

```bash
bundle exec rails test
# or
bundle exec rspec
# or
bundle exec cucumber
```

### linting and style

```bash
bundle exec rubocop
```

## Deployment

this project can be deployed to aws using pulumi for infrastructure as code:

### prerequisites

1. aws account and credentials
2. docker registry access
3. pulumi installed (`gem install pulumi`)
4. ssh access to deployment servers

### deployment commands

```bash
# set up servers for deployment
bundle exec rake deploy:setup

# deploy to staging
bundle exec rake deploy

# deploy to production
bundle exec rake deploy:production

# deploy a preview environment
bundle exec rake deploy:preview[branch-name]

# check deployment status
bundle exec rake deploy:status

# destroy an environment
bundle exec rake deploy:destroy[environment-name]
```

### dependabot configuration

the project is configured with special handling for dependabot pull requests:

- preview environments are not created for dependabot prs
- ci runs limited tests for dependabot prs (only security and linting checks)
- full test suites are skipped for dependabot to speed up dependency updates
- minor and patch updates are automatically merged when ci passes
- major version updates require manual review

configuration:
- `.github/dependabot.yml`: controls update frequency and versioning strategy
- `.github/workflows/dependabot-auto-merge.yml`: handles auto-merging of safe updates

this helps reduce infrastructure costs and ci pipeline usage while still maintaining security checks.

### data management

```bash
# seed database with tarot card data
bundle exec rake seed

# backup database
bundle exec rake data:backup

# restore from backup
bundle exec rake data:restore[filename]

# analyze database performance
bundle exec rake data:analyze
```

## API Documentation

The API follows JSONapi specification. Full OpenAPI documentation is available at `/api-docs`.

### Authentication Methods

The API supports three authentication methods:

1. **JWT Bearer Token**
```bash
# Register a new user
curl -X POST \
  "https://api.tarotapi.cards/api/v1/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"email": "abdulachik@icloud.com", "password": "securepassword"}'

# Login to get JWT token
curl -X POST \
  "https://api.tarotapi.cards/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "abdulachik@icloud.com", "password": "securepassword"}'
```

2. **HTTP Basic Authentication**
```bash
curl -X GET \
  "https://api.tarotapi.cards/api/v1/cards" \
  -H "Authorization: Basic $(echo -n 'abdulachik@icloud.com:password' | base64)"
```

3. **API Key Authentication**
```bash
curl -X GET \
  "https://api.tarotapi.cards/api/v1/cards" \
  -H "X-API-Key: your-api-key"
```

### Key Endpoints

| Endpoint | Description | Authentication Required |
|----------|-------------|-------------------------|
| `GET /api/v1/cards` | List all tarot cards | No |
| `GET /api/v1/spreads` | List available spreads | No |
| `POST /api/v1/readings` | Create a new reading | Yes |
| `GET /api/v1/readings/{id}` | Get a specific reading | Yes |

## Command Reference

### Infrastructure Management

| Command | Description |
|---------|-------------|
| `bundle exec rake infra:init` | Initialize infrastructure for staging and production |
| `bundle exec rake infra:deploy[staging]` | Deploy to staging environment |
| `bundle exec rake infra:deploy[production]` | Deploy to production environment |
| `bundle exec rake infra:create_preview[feature]` | Create preview environment |
| `bundle exec rake infra:manage_state[backup]` | Backup Pulumi state |
| `bundle exec rake infra:manage_state[restore,file]` | Restore Pulumi state from backup |

### Development Commands

| Command | Description |
|---------|-------------|
| `bundle exec rake dev:setup` | Set up development environment |
| `bundle exec rake dev` | Start development environment |
| `bundle exec rake dev:console` | Open Rails console in development |
| `bundle exec rake dev:test` | Run tests in development |
| `bundle exec rake dev:logs` | View development logs |
| `bundle exec rake dev:rebuild` | Rebuild development containers |

### Complete Environment Setup Sequence

1. Initialize Pulumi and create state bucket:
   ```bash
   bundle exec rake infra:init
   ```

2. Set up secrets for each environment:
   ```bash
   bundle exec rake infra:set_secrets[staging]
   bundle exec rake infra:set_secrets[production]
   ```

3. Deploy infrastructure:
   ```bash
   # Deploy staging first
   bundle exec rake infra:deploy[staging]
   
   # Once staging is verified, deploy production
   bundle exec rake infra:deploy[production]
   ```

4. Deploy application:
   ```bash
   bundle exec rake deploy:app:staging
   bundle exec rake deploy:app:production
   ```

### Local Workflow Testing with Act

We use [Act](https://github.com/nektos/act) to test GitHub Actions workflows locally. Our setup uses the development stage from our main `Dockerfile`.

Prerequisites:
- Docker running
- PostgreSQL running on port 5432
- Redis running on port 6379
- `.env` file with required variables

```bash
# Build the CI image (required once)
bundle exec rake ci:build_image

# Run all CI checks
bundle exec rake ci:all

# Run specific checks
bundle exec rake ci:lint  # Run linting
bundle exec rake ci:test  # Run tests
bundle exec rake ci:docs  # Generate docs
```

Common issues:
- Database errors: Check PostgreSQL is running (`docker ps`)
- Redis errors: Check Redis is running (`docker ps`)
- Build errors: Try rebuilding the CI image

For more details on Act, see the [official documentation](https://github.com/nektos/act#readme).

### Preview Environment Management

Preview environments are temporary deployments for feature testing:

- **Creation Methods**:
  1. Branch naming: Create a branch with `preview-*` prefix
  2. PR tagging: Add `preview` label to a PR
  3. Manual trigger: Use GitHub Actions workflow dispatch

- **Access Control**:
  - Only repository owner (@abdul-hamid-achik) can create preview environments
  - Dependabot PRs do not create preview environments
  - Preview URLs follow pattern: `https://preview-{feature-name}.tarotapi.cards`

- **Lifecycle**:
  - Created automatically on PR open or preview tag
  - Updated on PR synchronize
  - Cleaned up automatically:
    - When PR is closed
    - After 3 days of inactivity
    - When preview tag is removed
  - Can be recreated using `bundle exec rake deploy:preview[name]`

### Deployment Verification

After deploying to any environment, verify the setup:

1. Check infrastructure status:
   ```bash
   bundle exec rake deploy:status[environment]
   ```

2. Verify domain and SSL setup:
   ```bash
   bundle exec rake deploy:verify_ssl[environment]
   ```

3. Monitor application logs:
   ```bash
   bundle exec rake deploy:logs[environment]
   ```

## Connection Pooling & Health Checks

### Connection Pooling

The API uses optimized connection pooling for both PostgreSQL and Redis to handle high-traffic workloads in AWS Fargate:

- **PostgreSQL Connection Pool**: Automatically sized based on worker processes and thread count
- **Redis Connection Pool**: Separate pools for caching, throttling, and Sidekiq
- **Pool Monitoring**: Automatic monitoring and cleanup of idle connections

#### PostgreSQL Read Replicas

The application supports PostgreSQL read replicas through the Makara gem:

- **Primary/Replica Routing**: Automatically routes reads to replicas and writes to primary
- **Sticky Connections**: Ensures consistent reads in the same request
- **Fault Tolerance**: Automatically blacklists unavailable database instances

To enable read replicas:

```bash
# Enable replica support
export DB_REPLICA_ENABLED=true
export DB_PRIMARY_HOST=your-primary-db-host
export DB_REPLICA_HOST=your-replica-db-host

# Validate the replica setup
bundle exec rake makara:validate

# Run a load test to verify balancing
bundle exec rake makara:load_test

# Check current status
bundle exec rake makara:status
```

For PostgreSQL optimization:
```bash
# View connection pool stats
bundle exec rake db:pool:stats

# Reset connection pool
bundle exec rake db:pool:clear

# Verify connections
bundle exec rake db:pool:verify

# Optimize pool size for current environment
bundle exec rake db:pool:healthcheck
```

For production environments, consider using PgBouncer as a connection pooler in a sidecar container.

### Health Checks

Health checks are available at multiple levels with appropriate authentication:

- `/health` - Public basic health check for load balancers (no auth)
- `/health_checks` - OkComputer health checks with detailed system status (requires auth)
- `/api/v1/health/detailed` - Authenticated detailed health report (requires API authentication)
- `/api/v1/health/database` - Authenticated database status report (requires API authentication)

When using Makara replicas, additional health checks are added automatically:
- `/health_checks/db_primary_primary` - Checks the primary database 
- `/health_checks/db_replica_replica` - Checks the replica database

Protected health checks require either:
1. OkComputer auth credentials (username/password)
2. API authentication (Bearer token, Basic auth, or API key)

Set the following environment variables in production:
```
HEALTH_CHECK_USERNAME=your_secure_username
HEALTH_CHECK_PASSWORD=your_secure_password
```