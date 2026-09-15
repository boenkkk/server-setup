# Immich Docker Compose - Quick Reference

## Installation (Copy & Paste)

```bash
cd /Users/notuser/GUA/program/server/server-setup

# 1. Setup environment
cp .env.immich .env
nano .env  # Edit DB_PASSWORD and VITE_SERVER_URL

# 2. Start services
./immich-manage.sh start

# 3. Wait and verify
sleep 10
./immich-manage.sh health

# 4. Access
# Web: http://localhost:3000
# API: http://localhost:3001
```

---

## Service Management

```bash
# Start all services
./immich-manage.sh start

# Stop services
./immich-manage.sh stop

# Restart services
./immich-manage.sh restart

# View status
./immich-manage.sh status

# View logs (all services)
./immich-manage.sh logs

# View specific service logs
./immich-manage.sh logs immich-server

# Check health
./immich-manage.sh health

# Remove everything (destructive!)
./immich-manage.sh remove
```

---

## Backup & Restore

```bash
# Backup database only
./immich-backup.sh backup-db

# Backup database (compressed)
./immich-backup.sh backup-db-gz

# Full backup (everything)
./immich-backup.sh backup-full

# List backups
./immich-backup.sh list

# Restore from backup
./immich-backup.sh restore-db immich-backups/immich-db-20260913_150000.sql.gz

# Cleanup old backups (keep last 7 days)
./immich-backup.sh cleanup 7
```

---

## Monitoring & Diagnostics

```bash
# Full health check & report
./immich-health-check.sh

# View report
cat immich-reports/health-report-*.txt

# Check disk usage
docker run --rm -v immich-upload:/data busybox du -sh /data

# Monitor in real-time
docker stats

# Database connection count
docker exec immich-db psql -U immich -d immich -c "SELECT count(*) FROM pg_stat_activity;"

# Redis memory usage
docker exec immich-redis redis-cli info memory
```

---

## Configuration Changes

```bash
# Edit environment
nano .env

# Restart to apply changes
./immich-manage.sh restart

# View what changed
docker-compose -f docker-compose_immich.yml config | diff -u - <(docker-compose -f docker-compose_immich.yml config)
```

---

## Common Issues & Fixes

### Services won't start
```bash
docker-compose -f docker-compose_immich.yml logs
docker system df  # Check disk space
```

### Database connection error
```bash
docker exec immich-db pg_isready -U immich
grep DB_PASSWORD .env
```

### High memory usage
```bash
docker stats
export WORKERS=2
./immich-manage.sh restart
```

### Slow uploads
```bash
docker exec immich-server iostat -x 1 5
# Check disk I/O - consider SSD
```

### Web UI not loading
```bash
curl http://localhost:3001/api/server/ping
grep VITE_SERVER_URL .env
# Open browser DevTools → Network tab
```

---

## File Locations

| File | Purpose |
|------|---------|
| `docker-compose_immich.yml` | Standard setup (5 services) |
| `docker-compose_immich-advanced.yml` | Advanced setup (+ ML, search) |
| `.env.immich` | Environment template |
| `immich-manage.sh` | Service management CLI |
| `immich-backup.sh` | Backup/restore utility |
| `immich-health-check.sh` | Health monitoring |
| `postgres/postgresql.conf` | DB optimization |
| `IMMICH_README.md` | Service details |
| `IMMICH_DEPLOYMENT_GUIDE.md` | Complete guide |

---

## Default Access Points

| Service | URL | Port |
|---------|-----|------|
| Web UI | http://localhost:3000 | 3000 |
| API | http://localhost:3001 | 3001 |
| ML Service | http://localhost:3003 | 3003 (advanced only) |
| Search (Typesense) | http://localhost:8108 | 8108 (advanced only) |

---

## Environment Variables Reference

| Variable | Purpose | Default | Example |
|----------|---------|---------|---------|
| `DB_PASSWORD` | PostgreSQL password | immich_password | `$(openssl rand -base64 32)` |
| `IMMICH_PORT` | API server port | 3001 | 3001 |
| `IMMICH_WEB_PORT` | Web UI port | 3000 | 3000 |
| `VITE_SERVER_URL` | Frontend API endpoint | http://localhost:3001 | https://immich.example.com |
| `LOG_LEVEL` | Log verbosity | log | log, debug, warn, error |
| `WORKERS` | API threads | 4 | 8 |
| `JWT_SECRET` | Auth token secret | N/A | `$(openssl rand -base64 32)` |
| `NODE_ENV` | Environment | production | production |

---

## Production Checklist

- [ ] Change `DB_PASSWORD` to strong password
- [ ] Set `VITE_SERVER_URL` to production domain
- [ ] Configure SSL/TLS certificate
- [ ] Setup reverse proxy (Nginx)
- [ ] Enable firewall rules
- [ ] Schedule daily backups: `0 2 * * * ./immich-backup.sh backup-db-gz`
- [ ] Test backup restore
- [ ] Configure monitoring
- [ ] Setup log aggregation
- [ ] Document runbooks
- [ ] Train team members

---

## Performance Guidelines

| Metric | Threshold | Action |
|--------|-----------|--------|
| API response time | >500ms | Check database, increase WORKERS |
| Memory usage | >80% | Reduce WORKERS, disable ML |
| Disk usage | >85% | Archive old photos, expand storage |
| Database size | >10GB | Review VACUUM schedule |
| Upload queue | >100 items | Check microservices, increase resources |

---

## Ports & Networking

### Internal Network (immich-network)
- All services communicate on isolated Docker network
- No external exposure required

### External Exposure
```
Host Port 80/443  →  Reverse Proxy  →  Port 3000 (Web)
                                     →  Port 3001 (API)
```

### Behind NAT/Firewall
1. Setup port forwarding on router
2. Or use VPN access
3. Or use reverse proxy on public server

---

## Database Optimization

### For Small Deployments (<100GB)
```bash
shared_buffers = 256MB
effective_cache_size = 1GB
work_mem = 16MB
```

### For Medium Deployments (100GB-1TB)
```bash
shared_buffers = 512MB
effective_cache_size = 2GB
work_mem = 32MB
```

### For Large Deployments (>1TB)
```bash
shared_buffers = 1GB
effective_cache_size = 4GB
work_mem = 64MB
# Consider dedicated database server
```

---

## Upgrade Procedure

```bash
# 1. Backup current data
./immich-backup.sh backup-full

# 2. Pull latest images
docker-compose -f docker-compose_immich.yml pull

# 3. Recreate containers
./immich-manage.sh restart

# 4. Verify everything works
./immich-manage.sh health

# 5. Keep backup for 30 days
./immich-backup.sh cleanup 30
```

---

## Emergency Procedures

### Database Corruption Recovery
```bash
# 1. Stop services
./immich-manage.sh stop

# 2. Restore from backup
./immich-backup.sh restore-db <latest_backup>

# 3. Start services
./immich-manage.sh start

# 4. Verify
./immich-manage.sh health
```

### Disk Space Emergency
```bash
# 1. Check volume sizes
docker run --rm -v immich-upload:/data busybox du -sh /data

# 2. Identify large files
docker run --rm -v immich-upload:/data busybox find /data -type f -size +100M

# 3. If critical, expand storage and restart
# Or archive old photos and remove from upload volume
```

### Complete System Failure
```bash
# 1. Restore latest backup on new system
./immich-backup.sh restore-db <backup_file>

# 2. Restore volumes
./immich-backup.sh restore-volume immich-upload <volume_backup>

# 3. Start services
./immich-manage.sh start

# 4. Restore configuration
# Copy .env from backup or recreation
```

---

## Daily Operations

```bash
# Morning check (before users access)
./immich-health-check.sh

# Monitor during day
docker stats

# Evening maintenance (low usage)
# Usually no action needed, but check:
docker-compose logs --tail=20 immich-server

# Nightly backup
./immich-backup.sh backup-db-gz
```

---

## Security Best Practices

✅ DO:
- Use strong passwords
- Enable HTTPS/TLS
- Keep images updated
- Regular backups
- Monitor access logs
- Use firewall rules
- Change default settings

❌ DON'T:
- Expose port 5432 (PostgreSQL) to internet
- Use default passwords
- Store backups only locally
- Ignore security warnings
- Run with excessive permissions
- Disable HTTPS
- Commit .env to git

---

## Support Resources

- **Official Site**: https://immich.app
- **GitHub**: https://github.com/immich-app/immich
- **Discord**: https://discord.com/invite/D8JsnBEuKb
- **Issues**: https://github.com/immich-app/immich/issues
- **Docs**: https://immich.app/docs

---

## Version Info

- **Created**: 2026-09-13
- **Docker Compose Version**: 3.8
- **Immich Latest**: ghcr.io/immich-app/immich-server:latest
- **PostgreSQL**: 15-alpine
- **Redis**: 7-alpine

---

## Additional Notes

- Services automatically restart on failure
- Health checks ensure service readiness
- All logs stored in container (rotated automatically)
- Volumes persist data across restarts
- Network is isolated from host by default
- GPU support available (advanced setup)
- Machine learning requires additional resources

For detailed information, see:
- `IMMICH_README.md` - Service overview
- `IMMICH_DEPLOYMENT_GUIDE.md` - Complete deployment guide
