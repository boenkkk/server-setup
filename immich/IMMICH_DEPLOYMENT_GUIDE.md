# Immich Docker Compose - Complete Deployment Guide

## Table of Contents
1. [Quick Start](#quick-start)
2. [Architecture Overview](#architecture-overview)
3. [Installation & Setup](#installation--setup)
4. [Configuration](#configuration)
5. [Deployment Scenarios](#deployment-scenarios)
6. [Troubleshooting](#troubleshooting)
7. [Performance Tuning](#performance-tuning)
8. [Security Hardening](#security-hardening)
9. [Backup & Recovery](#backup--recovery)
10. [Monitoring & Maintenance](#monitoring--maintenance)

---

## Quick Start

### Minimum Setup (5 minutes)

```bash
# 1. Navigate to server setup directory
cd /Users/notuser/GUA/program/server/server-setup

# 2. Copy environment template
cp .env.immich .env

# 3. Edit configuration (change DB_PASSWORD at minimum)
nano .env

# 4. Start services
./immich-manage.sh start

# 5. Wait for services to be healthy
sleep 10
./immich-manage.sh health

# 6. Access web UI
# Open browser: http://localhost:3000
```

### Full Deployment (15 minutes)

```bash
# 1. Initialize environment with secure settings
cp .env.immich .env
# Edit .env with your settings:
# - Change DB_PASSWORD to a strong password
# - Set VITE_SERVER_URL to your domain
# - Configure other options as needed

# 2. Start with advanced features
./immich-manage.sh docker-compose_immich-advanced.yml start

# 3. Monitor startup
./immich-manage.sh logs

# 4. Run health check
./immich-health-check.sh

# 5. Create initial backup
./immich-backup.sh backup-full
```

---

## Architecture Overview

### Standard Setup
```
┌─────────────────────────────────────────────────┐
│            Immich Services                       │
├─────────────────────────────────────────────────┤
│  immich-web:3000 (React Frontend)               │
│  immich-server:3001 (Node.js API)               │
│  immich-microservices (Background Jobs)         │
├─────────────────────────────────────────────────┤
│            Data Layer                            │
├─────────────────────────────────────────────────┤
│  PostgreSQL Database (Metadata)                 │
│  Redis Cache (Sessions & Queue)                 │
├─────────────────────────────────────────────────┤
│            Storage Volumes                       │
├─────────────────────────────────────────────────┤
│  immich-upload (User uploads)                   │
│  immich-thumbs (Generated thumbnails)           │
│  immich-db-data (Database persistence)          │
└─────────────────────────────────────────────────┘
```

### Advanced Setup (with ML & Monitoring)
```
Same as above, plus:
  - immich-machine-learning (Face detection, AI features)
  - Typesense (Full-text search)
  - Monitoring exporters
```

---

## Installation & Setup

### Prerequisites

```bash
# Check Docker installation
docker --version
docker-compose --version

# Required: Docker 20.10+, Docker Compose 2.0+
# Recommended: 4GB+ RAM, 20GB+ disk space
```

### Directory Structure

```
/Users/notuser/GUA/program/server/server-setup/
├── docker-compose_immich.yml              # Standard setup
├── docker-compose_immich-advanced.yml     # With ML & advanced features
├── .env.immich                            # Environment template
├── immich-manage.sh                       # Service management CLI
├── immich-health-check.sh                 # Health monitoring
├── immich-backup.sh                       # Backup/restore utility
├── postgres/
│   └── postgresql.conf                    # Database optimization
└── IMMICH_README.md                       # Service documentation
```

### Initial Setup

```bash
# 1. Copy compose file to working directory
cd /Users/notuser/GUA/program/server/server-setup

# 2. Create environment file
cp .env.immich .env

# 3. Generate secure passwords
DB_PASSWORD=$(openssl rand -base64 32)
JWT_SECRET=$(openssl rand -base64 32)

# 4. Edit .env with your values
# Required settings:
export DB_PASSWORD="your_secure_password"
export VITE_SERVER_URL="http://your-domain-or-ip:3001"
export JWT_SECRET="your_jwt_secret"

# 5. Verify configuration
docker-compose -f docker-compose_immich.yml config
```

---

## Configuration

### Environment Variables Reference

| Variable | Default | Purpose | Production |
|----------|---------|---------|------------|
| `DB_PASSWORD` | immich_password | PostgreSQL password | ⚠️ CHANGE |
| `IMMICH_PORT` | 3001 | API server port | Fixed |
| `IMMICH_WEB_PORT` | 3000 | Web UI port | Fixed |
| `VITE_SERVER_URL` | http://localhost:3001 | Frontend API endpoint | ⚠️ Use HTTPS |
| `LOG_LEVEL` | log | Logging verbosity | Production: warn |
| `WORKERS` | 4 | API worker threads | Adjust per CPU cores |
| `JWT_SECRET` | N/A | API authentication | ⚠️ Generate random |
| `NODE_ENV` | production | Node environment | Fixed |

### Port Configuration

Default ports can be customized:

```bash
# Standard setup uses:
IMMICH_WEB_PORT=3000    # Web UI
IMMICH_PORT=3001        # API
TYPESENSE_PORT=8108     # Search (advanced only)
ML_PORT=3003            # ML Service (advanced only)

# Behind reverse proxy, expose only:
80  -> immich-web:80
443 -> (SSL/TLS termination)
```

### Database Configuration

```bash
# Default PostgreSQL settings in docker-compose:
POSTGRES_DB: immich
POSTGRES_USER: immich
POSTGRES_PASSWORD: ${DB_PASSWORD}

# For large instances, tune in postgres/postgresql.conf:
shared_buffers = 256MB      # ~25% of RAM
effective_cache_size = 1GB  # ~50% of RAM
work_mem = 16MB             # RAM / (max_connections * 2)
```

---

## Deployment Scenarios

### Scenario 1: Home Lab / Small Instance

```bash
# Use standard docker-compose_immich.yml
./immich-manage.sh start

# Resources: 2GB RAM, 30GB storage
# Expected users: 1-3
# Features: Basic photo backup, thumbnails
```

### Scenario 2: Small Team (5-10 users)

```bash
# Use advanced setup with ML
./immich-manage.sh docker-compose_immich-advanced.yml start

# Resources: 8GB RAM, 100GB+ storage
# Enable features:
# - Face detection (ML service)
# - Full-text search (Typesense)
# - Advanced album features
```

### Scenario 3: Production (50+ users)

```bash
# 1. Use advanced setup
./immich-manage.sh docker-compose_immich-advanced.yml start

# 2. Add resource limits to docker-compose
services:
  immich-server:
    deploy:
      resources:
        limits:
          cpus: '4'
          memory: 4G

# 3. Setup reverse proxy (Nginx/Caddy)
# 4. Enable SSL/TLS
# 5. Configure monitoring
# 6. Setup automated backups
# 7. Configure log aggregation

# Resources: 16GB+ RAM, 500GB+ storage, SSD
# High availability: Use external PostgreSQL, S3 storage
```

### Scenario 4: Behind Reverse Proxy

```nginx
# Nginx configuration example
upstream immich_web {
    server localhost:3000;
}

upstream immich_api {
    server localhost:3001;
}

server {
    listen 443 ssl http2;
    server_name immich.example.com;
    
    ssl_certificate /etc/ssl/certs/cert.pem;
    ssl_certificate_key /etc/ssl/private/key.pem;
    
    # Web UI
    location / {
        proxy_pass http://immich_web;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # API
    location /api {
        proxy_pass http://immich_api/api;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Increase timeout for large uploads
        client_max_body_size 10G;
        proxy_read_timeout 600s;
    }
}

# Update .env:
VITE_SERVER_URL=https://immich.example.com
```

---

## Troubleshooting

### Service Won't Start

```bash
# 1. Check Docker daemon
docker ps

# 2. Verify compose file syntax
docker-compose -f docker-compose_immich.yml config

# 3. Check resource availability
docker system df

# 4. View detailed logs
docker-compose -f docker-compose_immich.yml logs -f

# 5. Restart Docker daemon
sudo systemctl restart docker
```

### Database Connection Failed

```bash
# 1. Verify database is running
docker exec immich-db pg_isready -U immich

# 2. Check password
echo $DB_PASSWORD

# 3. View database logs
docker logs immich-db | tail -50

# 4. Reset database (WARNING: destructive)
docker-compose -f docker-compose_immich.yml down -v
docker-compose -f docker-compose_immich.yml up -d immich-db
docker-compose -f docker-compose_immich.yml up -d
```

### High Memory Usage

```bash
# 1. Check container memory
docker stats --no-stream

# 2. Review microservices workload
docker logs immich-microservices | grep -i memory

# 3. Reduce workers
export WORKERS=2
docker-compose -f docker-compose_immich.yml restart immich-server

# 4. Disable optional features
# - Disable machine learning if not needed
# - Disable full-text search
```

### Slow Photo Upload

```bash
# 1. Check network bandwidth
docker exec immich-server curl -O https://speed.cloudflare.com/download

# 2. Verify disk I/O
docker exec immich-server iostat -x 1 5

# 3. Check database connection pool
docker exec immich-db psql -U immich -c "SELECT count(*) FROM pg_stat_activity;"

# 4. Enable upload compression
# In .env: IMMICH_ENABLE_UPLOAD_COMPRESSION=true

# 5. Use faster storage (SSD vs HDD)
```

### Web UI Not Loading

```bash
# 1. Check web container
docker logs immich-web

# 2. Verify API is accessible
curl http://localhost:3001/api/server/ping

# 3. Check VITE_SERVER_URL setting
grep VITE_SERVER_URL .env

# 4. Verify browser can reach API
# Browser console: Check for CORS errors
# Check network tab in developer tools

# 5. Clear browser cache
# Ctrl+Shift+Delete (most browsers)
```

### Permission Issues with Volumes

```bash
# Check volume ownership
docker run --rm -v immich-upload:/data busybox ls -la /data

# Fix permissions (if needed)
docker run --rm -v immich-upload:/data busybox chown -R 1000:1000 /data

# For host-mounted volumes
sudo chown -R 1000:1000 /path/to/immich/uploads
```

---

## Performance Tuning

### Database Optimization

```sql
-- Connect to database
docker exec -it immich-db psql -U immich -d immich

-- Check index usage
SELECT schemaname, tablename, indexname, idx_scan
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;

-- Analyze query performance
EXPLAIN ANALYZE SELECT * FROM assets WHERE createdAt > NOW() - INTERVAL '7 days';

-- Vacuum and analyze
VACUUM ANALYZE;

-- Monitor connections
SELECT count(*), state FROM pg_stat_activity GROUP BY state;
```

### Cache Optimization

```bash
# Monitor Redis memory usage
docker exec immich-redis redis-cli info memory

# Check Redis keys
docker exec immich-redis redis-cli dbsize

# Clear cache if needed (WARNING: users will be logged out)
docker exec immich-redis redis-cli FLUSHALL
```

### API Server Tuning

```bash
# Adjust worker threads based on CPU cores
export WORKERS=8  # For 8+ core systems

# Enable response compression
# Add to docker-compose environment:
IMMICH_ENABLE_RESPONSE_COMPRESSION=true

# Monitor API performance
docker logs immich-server | grep -i "response time"
```

### Thumbnail Generation

```bash
# For faster thumbnail generation:
1. Use SSD storage
2. Increase microservices workers
3. Enable GPU acceleration (if available)
4. Consider running separate microservices instance on different host
```

---

## Security Hardening

### Essential Security Steps

```bash
# 1. Change all default passwords
DB_PASSWORD=$(openssl rand -base64 32)
JWT_SECRET=$(openssl rand -base64 32)
TYPESENSE_API_KEY=$(openssl rand -base64 32)

# 2. Use HTTPS/TLS
# - Use reverse proxy with SSL certificate
# - Never expose HTTP to internet

# 3. Use strong authentication
# - Enable 2FA if available
# - Use strong passwords

# 4. Restrict network access
# - Use firewall rules
# - Expose only HTTP/HTTPS ports
# - Use VPN for remote access

# 5. Keep images updated
docker-compose -f docker-compose_immich.yml pull
docker-compose -f docker-compose_immich.yml up -d
```

### Firewall Rules (Example)

```bash
# UFW (Ubuntu)
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp      # SSH
sudo ufw allow 80/tcp      # HTTP
sudo ufw allow 443/tcp     # HTTPS
sudo ufw enable

# iptables (if UFW not available)
sudo iptables -P INPUT DROP
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
```

### Environment Security

```bash
# Store sensitive data securely
chmod 600 .env

# Never commit .env to git
echo ".env" >> .gitignore

# Use environment variable secrets in production
# Instead of .env files:
# - Use Docker secrets (Swarm)
# - Use Kubernetes secrets (K8s)
# - Use HashiCorp Vault
# - Use cloud provider secrets (AWS Secrets Manager, etc.)
```

---

## Backup & Recovery

### Automated Daily Backups

```bash
# Create cron job
crontab -e

# Add line for daily backup at 2 AM
0 2 * * * cd /Users/notuser/GUA/program/server/server-setup && ./immich-backup.sh backup-db-gz

# Keep only 30 days of backups
0 3 * * * cd /Users/notuser/GUA/program/server/server-setup && ./immich-backup.sh cleanup 30
```

### Full Disaster Recovery

```bash
# 1. Backup everything
./immich-backup.sh backup-full

# 2. Store in secure location
# - External drive
# - Cloud storage (encrypted)
# - Separate server

# 3. Test restore procedure quarterly
# - Restore to test environment
# - Verify data integrity
# - Document any issues

# 4. Keep multiple copies
# - Local backup
# - Off-site backup (cloud)
# - Encrypted backup
```

### Restore Procedure

```bash
# Database-only restore (minimal downtime)
./immich-backup.sh restore-db immich-backups/immich-db-20260913_150000.sql.gz

# Full restore (complete replacement)
1. docker-compose down
2. Remove volumes: docker volume rm immich-*
3. Extract backup archive
4. Restore database
5. Restore volumes
6. docker-compose up -d
```

---

## Monitoring & Maintenance

### Health Monitoring

```bash
# Run health check
./immich-health-check.sh

# This generates report in immich-reports/ with:
# - Container status
# - Database health
# - Redis status
# - API responsiveness
# - Disk usage
# - Recent errors
# - Resource recommendations
```

### Regular Maintenance Tasks

```bash
# Weekly
- Review health check reports
- Monitor disk space: df -h
- Check for updates: docker-compose pull

# Monthly
- Run full backup and test restore
- Review logs for errors
- Optimize database: VACUUM ANALYZE
- Update documentation

# Quarterly
- Test disaster recovery procedure
- Security audit (passwords, access)
- Performance analysis
- Update Docker images
```

### Log Management

```bash
# View recent logs
docker-compose logs --tail=100 immich-server

# Filter for errors
docker-compose logs | grep -i error

# Archive old logs
docker container prune --filter "until=240h"

# Configure log rotation
# In docker-compose (already configured):
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

### Metrics to Monitor

Key metrics to track:
- Database size growth rate
- Upload volume usage
- API response times (target: <200ms)
- Thumbnail generation queue depth
- Memory usage
- Disk I/O performance
- Network bandwidth
- CPU utilization

---

## Additional Resources

### Official Documentation
- Immich: https://immich.app
- GitHub: https://github.com/immich-app/immich
- Discord Community: https://discord.com/invite/D8JsnBEuKb

### Management Scripts

All scripts are located in `/Users/notuser/GUA/program/server/server-setup/`:

1. **immich-manage.sh** - Service lifecycle management
2. **immich-health-check.sh** - System health monitoring
3. **immich-backup.sh** - Backup and restore operations

### Quick Command Reference

```bash
# Start services
./immich-manage.sh start

# View logs
./immich-manage.sh logs immich-server

# Check health
./immich-manage.sh health

# Backup database
./immich-backup.sh backup-db-gz

# Full backup
./immich-backup.sh backup-full

# Restore database
./immich-backup.sh restore-db <backup_file>

# Generate health report
./immich-health-check.sh
```

---

## Checklist for Production Deployment

- [ ] Change all default passwords (DB, JWT secret)
- [ ] Configure HTTPS/TLS certificate
- [ ] Setup reverse proxy (Nginx/Caddy)
- [ ] Configure firewall rules
- [ ] Enable regular backups (daily minimum)
- [ ] Test backup restore procedure
- [ ] Setup monitoring/alerts
- [ ] Configure log aggregation
- [ ] Document access procedures
- [ ] Create disaster recovery runbook
- [ ] Train team on procedures
- [ ] Schedule maintenance windows
- [ ] Setup performance monitoring
- [ ] Configure rate limiting (if public)
- [ ] Enable audit logging

---

## Support & Issues

For issues or questions:
1. Check troubleshooting section above
2. Review logs: `./immich-manage.sh logs`
3. Run health check: `./immich-health-check.sh`
4. Check official documentation: https://immich.app
5. Report issues: https://github.com/anomalyco/opencode

