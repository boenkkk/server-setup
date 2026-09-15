# Immich Docker Compose Setup

## Overview

Immich is a self-hosted photo and video backup solution with machine learning-powered search and face recognition. This Docker Compose configuration sets up a complete Immich instance with:

- **PostgreSQL Database** for metadata storage
- **Redis Cache** for performance optimization
- **Immich Server** (API backend)
- **Immich Microservices** for background tasks
- **Immich Web** (frontend UI)
- **Optional: Machine Learning Service** for advanced features

## Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- Minimum 4GB RAM (8GB+ recommended for ML features)
- 20GB+ disk space for media storage

## Quick Start

### 1. Configuration

Copy and customize the environment file:

```bash
cp .env.immich .env
```

Edit `.env` and change the following:

```bash
DB_PASSWORD=your_secure_password_here
VITE_SERVER_URL=http://your-domain-or-ip:3001
```

### 2. Start Services

```bash
docker-compose -f docker-compose_immich.yml up -d
```

Verify all services are running:

```bash
docker-compose -f docker-compose_immich.yml ps
```

### 3. Access Immich

- **Web UI**: http://localhost:3000
- **API**: http://localhost:3001/api

Default credentials will be set on first login.

## Service Configuration Details

### immich-db
- **Image**: postgres:15-alpine
- **Purpose**: Stores all metadata, user data, and configuration
- **Volume**: `immich-db-data:/var/lib/postgresql/data`
- **Health Check**: PostgreSQL ping every 10s

### immich-redis
- **Image**: redis:7-alpine
- **Purpose**: Session cache and job queue
- **Health Check**: Redis PONG every 10s

### immich-server
- **Image**: ghcr.io/immich-app/immich-server:latest
- **Purpose**: Main API backend
- **Port**: 3001
- **Volume Mounts**:
  - `immich-upload`: Photo/video uploads
  - `immich-thumbs`: Generated thumbnails
- **Health Check**: HTTP ping every 30s

### immich-microservices
- **Image**: ghcr.io/immich-app/immich-server:latest
- **Purpose**: Background tasks (thumbnail generation, face detection, etc.)
- **Command**: `start.sh microservices`
- **Same volumes as immich-server**

### immich-web
- **Image**: ghcr.io/immich-app/immich-web:latest
- **Purpose**: React-based frontend
- **Port**: 3000
- **Health Check**: HTTP GET every 30s

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DB_PASSWORD` | immich_password | PostgreSQL password (CHANGE THIS) |
| `IMMICH_PORT` | 3001 | API server port |
| `IMMICH_WEB_PORT` | 3000 | Web UI port |
| `VITE_SERVER_URL` | http://localhost:3001 | Server URL for frontend (must be accessible from browser) |
| `LOG_LEVEL` | log | Logging level (log, debug, warn, error) |
| `NODE_ENV` | production | Node environment |

## Common Operations

### View Logs

```bash
# All services
docker-compose -f docker-compose_immich.yml logs -f

# Specific service
docker-compose -f docker-compose_immich.yml logs -f immich-server

# Last 100 lines
docker-compose -f docker-compose_immich.yml logs --tail=100
```

### Stop Services

```bash
docker-compose -f docker-compose_immich.yml stop
```

### Restart Services

```bash
docker-compose -f docker-compose_immich.yml restart
```

### Remove Everything (including data)

```bash
docker-compose -f docker-compose_immich.yml down -v
```

### Backup Database

```bash
docker exec immich-db pg_dump -U immich immich > immich-db-backup.sql
```

### Restore Database

```bash
docker exec -i immich-db psql -U immich immich < immich-db-backup.sql
```

## Production Deployment

### 1. Use Strong Passwords

```bash
# Generate secure password
openssl rand -base64 32
```

### 2. Configure Reverse Proxy

Use Nginx or another reverse proxy to:
- Handle SSL/TLS
- Route traffic to port 3000 (web) and 3001 (API)
- Add authentication layer if needed

Example Nginx config snippet:

```nginx
server {
    listen 443 ssl http2;
    server_name immich.example.com;
    
    ssl_certificate /path/to/cert;
    ssl_certificate_key /path/to/key;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /api {
        proxy_pass http://localhost:3001/api;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

### 3. Set VITE_SERVER_URL

```bash
VITE_SERVER_URL=https://immich.example.com
```

### 4. Enable Resource Limits

Add to docker-compose to prevent resource exhaustion:

```yaml
services:
  immich-server:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 1G
```

### 5. Use Named Volumes with Backup

```bash
docker run --rm -v immich-db-data:/data -v $(pwd):/backup \
  ubuntu tar czf /backup/immich-db-data-$(date +%Y%m%d).tar.gz -C /data .
```

## Machine Learning (Optional)

To enable face detection and advanced search, uncomment the `immich-machine-learning` service in the compose file:

```yaml
immich-machine-learning:
  image: ghcr.io/immich-app/immich-machine-learning:latest
  # ... rest of config
```

**Note**: Requires significant disk space (5-10GB) and GPU recommended for faster processing.

## Troubleshooting

### Database Connection Error

```bash
# Check database health
docker exec immich-db pg_isready -U immich

# View database logs
docker logs immich-db
```

### Redis Connection Error

```bash
# Test Redis connection
docker exec immich-redis redis-cli ping
```

### Web UI Not Loading

1. Check `VITE_SERVER_URL` is correct in `.env`
2. Verify API is accessible: `curl http://localhost:3001/api/server/ping`
3. Check web container logs: `docker logs immich-web`

### High Memory Usage

- Reduce microservices concurrency: Add `WORKERS=1` to environment
- Disable machine learning if not needed
- Limit container resources (see Production Deployment section)

### Slow Thumbnail Generation

- Enable GPU support if available
- Increase microservices resources
- Check disk I/O performance

## Resources

- Official Docs: https://immich.app
- GitHub: https://github.com/immich-app/immich
- Community: https://discord.com/invite/D8JsnBEuKb

## Security Recommendations

✅ Change default database password  
✅ Use HTTPS in production  
✅ Run behind reverse proxy  
✅ Enable firewall rules  
✅ Regular backups  
✅ Keep images updated: `docker-compose pull && docker-compose up -d`  
✅ Use strong API keys if external access needed  

## Notes

- First startup may take 2-3 minutes for database initialization
- Initial thumbnail generation can be slow for large libraries
- Recommend 1GB+ disk space per 10,000 photos
