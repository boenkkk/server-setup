# Immich Docker Compose - Complete Index & Reference

**Setup Date**: 2026-09-13  
**Location**: `/Users/notuser/GUA/program/server/server-setup/`  
**Status**: ✅ Production Ready

---

## 📑 Table of Contents

1. [File Inventory](#file-inventory)
2. [Getting Started](#getting-started)
3. [File Guide by Use Case](#file-guide-by-use-case)
4. [Command Quick Reference](#command-quick-reference)
5. [Troubleshooting Index](#troubleshooting-index)
6. [Configuration Reference](#configuration-reference)
7. [Deployment Scenarios](#deployment-scenarios)

---

## 📦 File Inventory

### Compose Files (Choose one)

```
docker-compose_immich.yml
├─ Services: 5 (DB, Redis, Server, Microservices, Web)
├─ Size: 3.9KB
├─ Best for: Most users, home lab, small teams
├─ Memory: 4GB+
└─ Includes: Basic photo backup, thumbnails, API

docker-compose_immich-advanced.yml
├─ Services: 8 (all above + ML, Typesense, Exporter)
├─ Size: 6.9KB
├─ Best for: Power users, face detection, full-text search
├─ Memory: 8GB+
└─ Includes: AI features, advanced search, monitoring
```

### Configuration Files

```
.env.immich (726 bytes)
├─ Template for environment variables
├─ Copy to .env and customize
└─ Variables: Passwords, ports, URLs, feature flags

postgres/postgresql.conf (983 bytes)
├─ Database performance tuning
├─ Memory settings optimized for typical deployments
├─ Connection pool and query optimization
└─ Automatically loaded by Docker container
```

### Management Scripts (All Executable)

```
immich-manage.sh (6.8KB)
├─ Commands: start, stop, restart, status, logs, health, backup, restore, update, remove
├─ Usage: ./immich-manage.sh [command]
├─ Provides: Colored output, error handling, health verification
└─ Features: Automatic service dependency checking

immich-health-check.sh (7.6KB)
├─ Generates comprehensive health reports
├─ Checks: Containers, DB, Redis, API, Web, Disk, Errors
├─ Output: Saved to immich-reports/health-report-TIMESTAMP.txt
└─ Features: Resource monitoring, recommendations, detailed analysis

immich-backup.sh (8.8KB)
├─ Commands: backup-db, backup-db-gz, backup-volumes, backup-full, restore-db, restore-volume, list, cleanup
├─ Usage: ./immich-backup.sh [command] [options]
├─ Output: Stored in immich-backups/ with timestamps
└─ Features: Compression, incremental, disaster recovery
```

### Documentation Files

```
IMMICH_GETTING_STARTED.md (10KB) ⭐ START HERE
├─ Purpose: First-time user guide
├─ Contents: 5-minute setup, verification, next steps
├─ Read time: 5-10 minutes
└─ Action: Follow the Quick Start section

IMMICH_README.md (6.7KB)
├─ Purpose: Service-level documentation
├─ Contents: Services, configuration, operations, troubleshooting
├─ Read time: 10 minutes
└─ Action: Understand what each service does

IMMICH_QUICK_REFERENCE.md (8.4KB)
├─ Purpose: Daily operations cheat sheet
├─ Contents: Commands, configurations, common issues
├─ Read time: 5 minutes (reference)
└─ Action: Bookmark for daily use

IMMICH_DEPLOYMENT_GUIDE.md (17KB)
├─ Purpose: Complete deployment & operations manual
├─ Contents: Architecture, scenarios, tuning, security, monitoring
├─ Read time: 30 minutes (or as reference)
└─ Action: Reference for production deployments

IMMICH_SETUP_SUMMARY.md (12KB)
├─ Purpose: Setup details and architecture overview
├─ Contents: Files created, structure, features, checklist
├─ Read time: 15 minutes
└─ Action: Understand the complete setup

IMMICH_COMPLETE_INDEX.md (This file)
├─ Purpose: Navigation and comprehensive reference
├─ Contents: All files, commands, troubleshooting, scenarios
├─ Read time: 20 minutes (or as reference)
└─ Action: Navigate to needed sections
```

---

## 🚀 Getting Started

### 60-Second Setup

```bash
cd /Users/notuser/GUA/program/server/server-setup
cp .env.immich .env
sed -i "" "s/DB_PASSWORD=.*/DB_PASSWORD=$(openssl rand -base64 32)/" .env
./immich-manage.sh start
sleep 15
./immich-manage.sh health
# Open http://localhost:3000
```

### 5-Minute Setup (With Verification)

```bash
# 1. Navigate to directory
cd /Users/notuser/GUA/program/server/server-setup

# 2. Setup configuration
cp .env.immich .env
nano .env  # Review and set DB_PASSWORD

# 3. Start services
./immich-manage.sh start

# 4. Wait for initialization
sleep 15

# 5. Verify all services healthy
./immich-manage.sh health

# 6. Access web UI
open http://localhost:3000
```

### Full Setup With Monitoring (15 minutes)

```bash
# Steps 1-5 from above, then:

# 6. Create comprehensive backup
./immich-backup.sh backup-full

# 7. Generate health report
./immich-health-check.sh

# 8. Review system status
./immich-manage.sh status

# 9. Review health report
cat immich-reports/health-report-*.txt | tail -50

# 10. Schedule automated backup (crontab)
# 0 2 * * * cd /Users/notuser/GUA/program/server/server-setup && ./immich-backup.sh backup-db-gz
```

---

## 📚 File Guide by Use Case

### "I'm New to This"
1. Read: `IMMICH_GETTING_STARTED.md` (5 min)
2. Read: `IMMICH_README.md` (10 min)
3. Run: `./immich-manage.sh start`
4. Access: http://localhost:3000

### "I Need to Start/Stop Services"
1. Use: `./immich-manage.sh start` | `stop` | `restart`
2. Check: `./immich-manage.sh status`
3. Reference: `IMMICH_QUICK_REFERENCE.md`

### "I Need to Backup Data"
1. Run: `./immich-backup.sh backup-full`
2. List: `./immich-backup.sh list`
3. Restore: `./immich-backup.sh restore-db <file>`
4. Details: `IMMICH_QUICK_REFERENCE.md` → Backup & Restore

### "I'm Going to Production"
1. Read: `IMMICH_DEPLOYMENT_GUIDE.md` (complete)
2. Follow: Production Checklist section
3. Execute: Production Deployment steps
4. Use: All scripts for monitoring

### "I Need to Troubleshoot"
1. Run: `./immich-health-check.sh`
2. View: `./immich-manage.sh logs`
3. Search: `IMMICH_DEPLOYMENT_GUIDE.md` → Troubleshooting
4. Reference: `IMMICH_QUICK_REFERENCE.md` → Common Issues

### "I Need to Tune Performance"
1. Read: `IMMICH_DEPLOYMENT_GUIDE.md` → Performance Tuning
2. Edit: `.env` or `postgres/postgresql.conf`
3. Monitor: `./immich-health-check.sh`
4. Verify: `docker stats`

### "I Need to Secure the System"
1. Read: `IMMICH_DEPLOYMENT_GUIDE.md` → Security Hardening
2. Execute: All security steps
3. Reference: `IMMICH_QUICK_REFERENCE.md` → Security Best Practices

---

## 🔧 Command Quick Reference

### Service Lifecycle

```bash
# Start all services
./immich-manage.sh start

# Stop all services (can be restarted)
./immich-manage.sh stop

# Restart services (useful for configuration changes)
./immich-manage.sh restart

# Remove everything (destructive - needs confirmation)
./immich-manage.sh remove

# Update images to latest version
./immich-manage.sh update
```

### Service Status & Monitoring

```bash
# Show all container status
./immich-manage.sh status

# Check if all services are healthy
./immich-manage.sh health

# View real-time resource usage
docker stats

# Monitor for errors in real-time
./immich-manage.sh logs -f

# Generate comprehensive health report
./immich-health-check.sh

# View health report
cat immich-reports/health-report-*.txt
```

### Logging

```bash
# View logs from all services (last 50 lines)
./immich-manage.sh logs

# View logs from specific service
./immich-manage.sh logs immich-server
./immich-manage.sh logs immich-microservices
./immich-manage.sh logs immich-db

# Follow logs in real-time
./immich-manage.sh logs -f

# View last 100 lines
./immich-manage.sh logs --tail=100
```

### Backup & Recovery

```bash
# Quick database backup (uncompressed)
./immich-backup.sh backup-db

# Compressed database backup (recommended)
./immich-backup.sh backup-db-gz

# Complete system backup (database + volumes + config)
./immich-backup.sh backup-full

# List all available backups
./immich-backup.sh list

# Restore database from backup
./immich-backup.sh restore-db immich-backups/immich-db-20260913_150000.sql.gz

# Restore specific volume
./immich-backup.sh restore-volume immich-upload immich-backups/immich-volume-immich-upload-*.tar.gz

# Delete backups older than 30 days
./immich-backup.sh cleanup 30

# Delete backups older than 7 days (weekly rotation)
./immich-backup.sh cleanup 7
```

### Advanced Operations

```bash
# Access database directly
docker exec -it immich-db psql -U immich -d immich

# Execute Redis command
docker exec immich-redis redis-cli [command]

# View database size
docker exec immich-db psql -U immich -d immich -c "SELECT pg_size_pretty(pg_database_size('immich'));"

# Check active connections
docker exec immich-db psql -U immich -d immich -c "SELECT count(*) FROM pg_stat_activity;"

# View volume sizes
docker run --rm -v immich-upload:/data busybox du -sh /data

# Remove old log data (if needed)
docker container prune --filter "until=240h"
```

---

## 🆘 Troubleshooting Index

### Quick Diagnostics

```bash
# Run full health check (generates report)
./immich-health-check.sh

# Check if services are running
./immich-manage.sh status

# View recent errors
./immich-manage.sh logs | grep -i error

# Check disk space
df -h

# Check memory usage
docker stats
```

### Common Issues & Solutions

| Issue | Solution | Reference |
|-------|----------|-----------|
| Services won't start | Check Docker daemon, disk space, ports | DEPLOYMENT_GUIDE.md#service-wont-start |
| Database connection error | Verify DB_PASSWORD, check pg_isready | DEPLOYMENT_GUIDE.md#database-connection-failed |
| High memory usage | Reduce WORKERS, disable ML | DEPLOYMENT_GUIDE.md#high-memory-usage |
| Slow uploads | Check disk I/O, verify network | DEPLOYMENT_GUIDE.md#slow-photo-upload |
| Web UI not loading | Check VITE_SERVER_URL, verify API | DEPLOYMENT_GUIDE.md#web-ui-not-loading |
| Permission denied errors | Fix volume ownership with chown | DEPLOYMENT_GUIDE.md#permission-issues |

### Detailed Troubleshooting

For comprehensive troubleshooting, see:
- `IMMICH_DEPLOYMENT_GUIDE.md` → Troubleshooting section (full details)
- `IMMICH_QUICK_REFERENCE.md` → Common Issues & Fixes (quick solutions)

---

## ⚙️ Configuration Reference

### Environment Variables

| Variable | Default | Type | Purpose |
|----------|---------|------|---------|
| `DB_PASSWORD` | immich_password | String | PostgreSQL password (⚠️ CHANGE) |
| `IMMICH_PORT` | 3001 | Port | API server port |
| `IMMICH_WEB_PORT` | 3000 | Port | Web UI port |
| `VITE_SERVER_URL` | http://localhost:3001 | URL | Frontend API endpoint |
| `LOG_LEVEL` | log | String | Logging level (log/debug/warn/error) |
| `WORKERS` | 4 | Number | API worker threads |
| `JWT_SECRET` | N/A | String | Authentication secret (generate new) |
| `NODE_ENV` | production | String | Node environment |

### File Locations

| Component | Location | Type |
|-----------|----------|------|
| Uploads | `immich-upload` volume | Docker volume |
| Thumbnails | `immich-thumbs` volume | Docker volume |
| Database | `immich-db-data` volume | Docker volume |
| Backups | `immich-backups/` | Local directory |
| Reports | `immich-reports/` | Local directory |
| Config | `.env` | Local file |

### Port Mappings

| Service | Port | Internal | External |
|---------|------|----------|----------|
| Web UI | 3000 | :80 | :3000 |
| API | 3001 | :3001 | :3001 |
| ML Service | 3003 | :3003 | :3003 (advanced only) |
| Typesense | 8108 | :8108 | :8108 (advanced only) |
| PostgreSQL | 5432 | :5432 | (internal only) |
| Redis | 6379 | :6379 | (internal only) |

---

## 🏢 Deployment Scenarios

### Scenario 1: Home Lab (1-3 Users)

**Use**: `docker-compose_immich.yml`

```bash
# Setup
cp .env.immich .env
# Keep defaults, just change DB_PASSWORD
./immich-manage.sh start

# Resources: 2GB RAM, 30GB storage
# Costs: Free (self-hosted)
# Features: Basic backup, photo viewing, thumbnails
```

**Maintenance**:
- Weekly: Check health
- Monthly: Create backup

### Scenario 2: Small Team (5-10 Users)

**Use**: `docker-compose_immich.yml` with tuning

```bash
# Setup
cp .env.immich .env
sed -i "" 's/WORKERS=4/WORKERS=8/' .env
./immich-manage.sh start

# Resources: 4GB RAM, 100GB storage
# Costs: Low (self-hosted)
# Features: Team sharing, face detection, mobile sync
```

**Maintenance**:
- Daily: Health check
- Weekly: Backup
- Monthly: Review performance

### Scenario 3: Large Team (50+ Users)

**Use**: `docker-compose_immich-advanced.yml`

```bash
# Setup
cp .env.immich .env
# Configure all advanced settings
# Setup monitoring, logging, reverse proxy
./immich-manage.sh docker-compose_immich-advanced.yml start

# Resources: 8GB+ RAM, 500GB+ storage
# Costs: Moderate (server infrastructure)
# Features: All features, AI, search, monitoring
```

**Maintenance**:
- Daily: Automated health checks, monitoring
- Weekly: Backup & test restore
- Monthly: Performance review, security audit
- Quarterly: Disaster recovery drill

### Scenario 4: Public Access (Behind Reverse Proxy)

**Setup**:
```bash
# 1. Use advanced setup
./immich-manage.sh docker-compose_immich-advanced.yml start

# 2. Configure Nginx/Caddy for SSL
# 3. Update .env:
VITE_SERVER_URL=https://immich.example.com

# 4. Restart
./immich-manage.sh restart

# 5. Enable monitoring & alerting
./immich-health-check.sh
```

See: `IMMICH_DEPLOYMENT_GUIDE.md` → Deployment Scenarios → Production

---

## 📋 Daily Operations Checklist

### Morning (Before Users Access)

```bash
# □ Check service health
./immich-manage.sh health

# □ Review overnight logs
./immich-manage.sh logs --tail=50 | grep -i error
```

### During Day

```bash
# □ Monitor resource usage
docker stats

# □ Check for slow queries
# (If performance issues, investigate)
```

### Evening (After Users Done)

```bash
# □ No action needed (usually)
# □ But check for any errors
./immich-manage.sh logs | tail -20
```

### Weekly

```bash
# □ Generate health report
./immich-health-check.sh

# □ Review backup status
./immich-backup.sh list

# □ Check disk space
df -h
```

### Monthly

```bash
# □ Test backup restore
./immich-backup.sh restore-db <test_backup>

# □ Review performance metrics
./immich-health-check.sh

# □ Update documentation
# (If procedures changed)

# □ Perform security audit
# (Review access logs, passwords, SSL certs)
```

### Quarterly

```bash
# □ Full disaster recovery test
# (Restore to alternate system)

# □ Update Docker images
./immich-manage.sh update

# □ Review and update runbooks
```

---

## 🔒 Security Checklist

### Initial Setup

- [ ] Change `DB_PASSWORD` from default
- [ ] Generate unique `JWT_SECRET`
- [ ] Set `.env` file permissions: `chmod 600 .env`
- [ ] Add `.env` to `.gitignore`
- [ ] Review environment variables

### Network Security

- [ ] Configure firewall rules (allow 80, 443 only)
- [ ] Never expose port 5432 (PostgreSQL)
- [ ] Never expose port 6379 (Redis)
- [ ] Use HTTPS/TLS for all external access
- [ ] Setup reverse proxy (Nginx/Caddy)

### Backup & Recovery

- [ ] Test backup procedure
- [ ] Verify restore works
- [ ] Store backups off-site
- [ ] Encrypt sensitive backups
- [ ] Document restore procedure

### Ongoing

- [ ] Keep images updated
- [ ] Monitor access logs
- [ ] Review user permissions
- [ ] Update passwords quarterly
- [ ] Test disaster recovery annually

---

## 📊 Performance Guidelines

### Recommended Settings by Scale

```
Small (1-10 users):
- WORKERS=4
- shared_buffers=256MB
- effective_cache_size=1GB
- Storage: 50-100GB

Medium (10-50 users):
- WORKERS=8
- shared_buffers=512MB
- effective_cache_size=2GB
- Storage: 200-500GB

Large (50+ users):
- WORKERS=12+
- shared_buffers=1GB+
- effective_cache_size=4GB+
- Storage: 500GB+
- Consider: External DB, separate ML server
```

### Monitoring Thresholds

| Metric | Warning | Critical |
|--------|---------|----------|
| API Response | >200ms | >1000ms |
| Memory Usage | >70% | >90% |
| Disk Usage | >80% | >95% |
| DB Size | >5GB | >20GB |
| Queue Depth | >50 items | >200 items |

---

## 🎓 Learning Resources

### Official Documentation
- Website: https://immich.app
- GitHub: https://github.com/immich-app/immich
- Docs: https://immich.app/docs

### Community
- Discord: https://discord.com/invite/D8JsnBEuKb
- Issues: https://github.com/immich-app/immich/issues
- Discussions: https://github.com/immich-app/immich/discussions

### Local Resources
- Getting Started: `IMMICH_GETTING_STARTED.md`
- README: `IMMICH_README.md`
- Quick Reference: `IMMICH_QUICK_REFERENCE.md`
- Full Guide: `IMMICH_DEPLOYMENT_GUIDE.md`

---

## ✅ Verification Steps

### After First Start

```bash
# 1. All services running
./immich-manage.sh status

# 2. All services healthy
./immich-manage.sh health

# 3. Web accessible
curl http://localhost:3000

# 4. API responding
curl http://localhost:3001/api/server/ping

# 5. Create admin account at http://localhost:3000
```

### After Configuration Changes

```bash
# 1. Restart services
./immich-manage.sh restart

# 2. Wait for health
sleep 10

# 3. Verify health
./immich-manage.sh health

# 4. Check logs for errors
./immich-manage.sh logs | grep -i error
```

### After Upgrade

```bash
# 1. Backup current data
./immich-backup.sh backup-full

# 2. Update images
./immich-manage.sh update

# 3. Verify health
./immich-manage.sh health

# 4. Check for migration errors
./immich-manage.sh logs | grep -i "error\|migration"
```

---

## 🚨 Emergency Procedures

### Database Corruption

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
# 1. Check which volume is full
docker run --rm -v immich-upload:/data busybox du -sh /data
docker run --rm -v immich-thumbs:/data busybox du -sh /data

# 2. If upload volume: Archive and remove old files
# 3. If thumbs: Can be regenerated (delete safely)
# 4. Expand storage and restart
```

### Complete System Failure

```bash
# 1. On new system, restore latest backup
./immich-backup.sh restore-db <backup_file>

# 2. Restore volumes
./immich-backup.sh restore-volume immich-upload <vol_backup>

# 3. Start services
./immich-manage.sh start

# 4. Verify data integrity
./immich-health-check.sh
```

---

## 📞 When to Use Each Command

| Task | Command |
|------|---------|
| Start services | `./immich-manage.sh start` |
| Stop services | `./immich-manage.sh stop` |
| Restart services | `./immich-manage.sh restart` |
| Check if running | `./immich-manage.sh status` |
| See what's broken | `./immich-manage.sh logs` |
| Verify everything OK | `./immich-manage.sh health` |
| Full diagnostics | `./immich-health-check.sh` |
| Backup database | `./immich-backup.sh backup-db-gz` |
| Backup everything | `./immich-backup.sh backup-full` |
| Restore from backup | `./immich-backup.sh restore-db <file>` |
| See all backups | `./immich-backup.sh list` |
| Update to latest | `./immich-manage.sh update` |

---

## 🎯 Complete Setup Summary

**What you have:**
- ✅ Two production-ready Docker Compose configurations
- ✅ Three management utility scripts
- ✅ Comprehensive documentation (5 guides)
- ✅ Database optimization settings
- ✅ Health monitoring system
- ✅ Backup/restore utilities
- ✅ Security best practices
- ✅ Multiple deployment scenarios

**What you can do:**
- ✅ Start/stop/restart services with one command
- ✅ Backup and restore complete system
- ✅ Monitor health and get recommendations
- ✅ Scale from home lab to enterprise
- ✅ Deploy behind reverse proxy with SSL
- ✅ Automate backups
- ✅ Generate health reports
- ✅ Troubleshoot issues systematically

**Ready to:**
- ✅ Deploy to production
- ✅ Support multiple users
- ✅ Implement disaster recovery
- ✅ Monitor performance
- ✅ Scale infrastructure

---

## 🎉 Quick Navigation

**New users**: Start with `IMMICH_GETTING_STARTED.md`

**Need command**: See section "Command Quick Reference" above

**Troubleshooting**: See section "Troubleshooting Index" above

**Production deployment**: See `IMMICH_DEPLOYMENT_GUIDE.md`

**Daily operations**: See `IMMICH_QUICK_REFERENCE.md`

**Understand architecture**: See `IMMICH_SETUP_SUMMARY.md`

---

**Status**: ✅ Complete and Ready for Deployment  
**Last Updated**: 2026-09-13  
**Version**: 1.0
