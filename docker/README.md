# Docker Deployment for Yahtzee Clone

This directory contains Docker configuration files for running the Yahtzee Clone application in containers.

## Quick Start

From the project root directory:

```bash
# Build and start both services
docker compose up -d

# View logs
docker compose logs -f

# Stop services
docker compose down

# Stop and remove volumes (deletes database)
docker compose down -v
```

The application will be available at:
- Frontend: http://localhost:3000
- Backend API: http://localhost:3001

## Architecture

- **Frontend**: Multi-stage build using Node 20 (build) + Nginx (serve)
- **Backend**: Node 20 Alpine with Express server
- **Database**: SQLite stored in a Docker volume for persistence

## Configuration

### Environment Variables

Copy `docker/.env.example` to `docker/.env` and modify as needed:

```bash
cp docker/.env.example docker/.env
```

Key variables:
- `VITE_API_URL`: Backend API URL for frontend (build-time)
- `CORS_ORIGINS`: Allowed origins for CORS
- `DB_PATH`: Database file location inside container
- `PORT`: Backend server port

### Ports

Default ports (modify in `../compose.yml` if needed):
- Frontend: 3000 → 80 (nginx)
- Backend: 3001 → 3001

## Building Images Individually

```bash
# Build frontend image
docker build -f docker/Dockerfile.frontend -t yahtzee-frontend .

# Build backend image
docker build -f docker/Dockerfile.backend -t yahtzee-backend .
```

## Production Deployment

For production:

1. Update `VITE_API_URL` to your production backend URL
2. Update `CORS_ORIGINS` to include your production frontend URL
3. Use a reverse proxy (nginx/traefik) for SSL termination
4. Consider using Docker secrets for sensitive configuration

Example with custom API URL:

```bash
docker compose build --build-arg VITE_API_URL=https://api.yourdomain.com
docker compose up -d
```

## Persistence

Game data is stored in the `./data` directory. To backup:

```bash
# Create backup
tar czf yahtzee-backup.tar.gz data/

# Restore backup
tar xzf yahtzee-backup.tar.gz
```

## Troubleshooting

### Check service health
```bash
docker compose ps
```

### View logs
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f backend
```

### Connect to backend container
```bash
docker compose exec backend sh
```

### Rebuild after code changes
```bash
docker compose up -d --build
```
