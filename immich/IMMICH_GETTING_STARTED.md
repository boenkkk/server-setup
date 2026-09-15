# Immich Docker Compose - Getting Started Guide

**Setup Date**: 2026-09-13  
**Location**: `/Users/notuser/GUA/program/server/server-setup/`

---

## ✅ Complete Setup Verification

All files have been successfully created and are ready to use:

### Docker Compose Configurations
- ✅ `docker-compose_immich.yml` - Standard 5-service setup
- ✅ `docker-compose_immich-advanced.yml` - Advanced setup with ML & search

### Configuration Files
- ✅ `.env.immich` - Environment template
- ✅ `postgres/postgresql.conf` - Database optimization

### Management Scripts (Executable)
- ✅ `immich-manage.sh` - Service lifecycle management
- ✅ `immich-health-check.sh` - Health monitoring & reporting
- ✅ `immich-backup.sh` - Backup & restore utility

### Documentation
- ✅ `IMMICH_README.md` - Service overview
- ✅ `IMMICH_DEPLOYMENT_GUIDE.md` - Complete deployment guide
- ✅ `IMMICH_QUICK_REFERENCE.md` - Quick reference for daily use
- ✅ `IMMICH_SETUP_SUMMARY.md` - Setup summary & architecture

---

## 🚀 Getting Started (5 Minutes)

### Step 1: Prepare Environment

```bash
cd /Users/notuser/GUA/program/server/server-setup

# Copy environment template
cp .env.immich .env

# Verify files exist
ls -la immich-*.sh docker-compose_immich*.yml .env.immich
```

### Step 2: Configure Settings

```bash
# Edit environment file
nano .env
```

**Minimum required changes:**
```bash
DB_PASSWORD=your_secure_password_here
VITE_SERVER_URL=http://localhost:3001
```

**Or use one-liner to set secure password:**
```bash
sed -i "" "s/DB_PASSWORD=immich_password/DB_PASSWORD=$(openssl rand -base64 32)/" .env
```

### Step 3: Start Services

```bash
# Start all services
./immich-manage.sh start

# Expected output:
# [INFO] Starting Immich services...
# [SUCCESS] Immich services started
```

### Step 4: Wait for Health

```bash
# Wait for services to initialize
sleep 15

# Check if all services are healthy
./immich-manage.sh health

# Expected output:
# [SUCCESS] Database: OK
# [SUCCESS] Redis: OK
# [SUCCESS] API Server: OK
# [SUCCESS] Web UI: OK
```

### Step 5: Access Application

Open in browser:
- **Web Interface**: http://localhost:3000
- **API Endpoint**: http://localhost:3001/api

---

## 📋 Verification Checklist

Run through this checklist to confirm everything is working:

### Service Health
```bash
# ✅ All containers running
./immich-manage.sh status

# ✅ Services responding
./immich-manage.sh health

# ✅ No error logs
./immich-manage.sh logs | grep -i error | wc -l
# (Should be 0 or very few)
```

### Network Access
```bash
# ✅ Web UI responds
curl -s http://localhost:3000 | head -20

# ✅ API responds
curl -s http://localhost:3001/api/server/ping

# ✅ Can connect to database
docker exec immich-db pg_isready -U immich

# ✅ Redis is responding
docker exec immich-redis redis-cli ping
```

### Volume Storage
```bash
# ✅ Volumes exist and are writable
docker run --rm -v immich-upload:/data busybox touch /data/.test

# ✅ Database volume accessible
docker run --rm -v immich-db-data:/data busybox ls -la /data | head -5
```

---

## 📚 Documentation Quick Links

### For First-Time Users
Start here: [`IMMICH_README.md`](./IMMICH_README.md)
- Service descriptions
- Quick start guide
- Basic troubleshooting

### For Daily Operations
Use this: [`IMMICH_QUICK_REFERENCE.md`](./IMMICH_QUICK_REFERENCE.md)
- Common commands
- Quick fixes
- Useful one-liners

### For Complete Understanding
Read this: [`IMMICH_DEPLOYMENT_GUIDE.md`](./IMMICH_DEPLOYMENT_GUIDE.md)
- Architecture details
- All deployment scenarios
- Performance tuning
- Security hardening

### For Setup Details
Reference: [`IMMICH_SETUP_SUMMARY.md`](./IMMICH_SETUP_SUMMARY.md)
- What was created
- Why each file exists
- Long-term planning

---

## 🔧 Common First Steps

### 1. Create Initial Backup

```bash
# Backup database
./immich-backup.sh backup-db-gz

# List backups
./immich-backup.sh list

# Full system backup
./immich-backup.sh backup-full
```

### 2. Monitor System Health

```bash
# Generate health report
./immich-health-check.sh

# View report
cat immich-reports/health-report-*.txt | tail -50
```

### 3. View Service Logs

```bash
# All services
./immich-manage.sh logs | tail -50

# Specific service
./immich-manage.sh logs immich-server

# Follow in real-time
./immich-manage.sh logs -f immich-microservices
```

### 4. Test Backup/Restore

```bash
# Create backup
./immich-backup.sh backup-db-gz

# Verify backup file exists
ls -lh immich-backups/

# Try restore on test (see DEPLOYMENT_GUIDE for procedure)
```

---

## 🎯 Next Steps by Timeline

### Today (0-2 hours)
- [ ] Verify all services are running: `./immich-manage.sh health`
- [ ] Access web interface and create admin account
- [ ] Create initial backup: `./immich-backup.sh backup-full`
- [ ] Read [`IMMICH_README.md`](./IMMICH_README.md)

### This Week
- [ ] Test backup restore procedure
- [ ] Configure firewall rules if needed
- [ ] Setup SSL certificate (if public access)
- [ ] Plan storage capacity
- [ ] Schedule automated backups

### This Month
- [ ] Setup monitoring alerts
- [ ] Document access procedures
- [ ] Train team members
- [ ] Create disaster recovery runbook
- [ ] Setup log aggregation

### Ongoing
- [ ] Daily: Monitor health via health check script
- [ ] Weekly: Review logs and health reports
- [ ] Monthly: Test backup restore
- [ ] Quarterly: Security audit
- [ ] Annually: Full disaster recovery drill

---

## 🛠️ Quick Command Reference

### Service Management
```bash
./immich-manage.sh start              # Start all services
./immich-manage.sh stop               # Stop services
./immich-manage.sh restart            # Restart services
./immich-manage.sh status             # Show status
./immich-manage.sh health             # Check health
./immich-manage.sh logs               # View logs
```

### Backup & Restore
```bash
./immich-backup.sh backup-db          # Quick database backup
./immich-backup.sh backup-db-gz       # Compressed backup
./immich-backup.sh backup-full        # Complete system backup
./immich-backup.sh list               # List backups
./immich-backup.sh cleanup 30         # Keep last 30 days
```

### Monitoring
```bash
./immich-health-check.sh              # Full health report
docker stats                          # Real-time resource usage
docker-compose ps                     # Container status
```

---

## ⚠️ Important Notes

### Passwords & Security
- ⚠️ Always change `DB_PASSWORD` from default
- ⚠️ Generate strong passwords: `openssl rand -base64 32`
- ⚠️ Keep `.env` file secure (add to `.gitignore`)
- ⚠️ Use HTTPS in production

### Storage
- 💾 Uploads stored in `immich-upload` volume (user photos)
- 💾 Thumbnails stored in `immich-thumbs` volume (auto-generated)
- 💾 Database in `immich-db-data` volume (metadata)
- 📈 Plan for growth: ~1GB per 10,000 photos

### Ports
- 🔌 Port 3000: Web UI (configure in `.env` as `IMMICH_WEB_PORT`)
- 🔌 Port 3001: API (configure in `.env` as `IMMICH_PORT`)
- 🔌 Port 5432: PostgreSQL (internal, not exposed)
- 🔌 Port 6379: Redis (internal, not exposed)

### Backups
- 📦 Backups stored in `immich-backups/` directory (local by default)
- 📦 Test restore procedure before relying on backups
- 📦 Store copies off-site for disaster recovery
- 📦 Schedule automated backups: `0 2 * * * ./immich-backup.sh backup-db-gz`

---

## 🆘 Troubleshooting Quick Links

### Services Won't Start
→ See [`IMMICH_DEPLOYMENT_GUIDE.md`](./IMMICH_DEPLOYMENT_GUIDE.md#service-wont-start)

### Database Connection Error
→ See [`IMMICH_DEPLOYMENT_GUIDE.md`](./IMMICH_DEPLOYMENT_GUIDE.md#database-connection-failed)

### High Memory Usage
→ See [`IMMICH_DEPLOYMENT_GUIDE.md`](./IMMICH_DEPLOYMENT_GUIDE.md#high-memory-usage)

### Web UI Not Loading
→ See [`IMMICH_DEPLOYMENT_GUIDE.md`](./IMMICH_DEPLOYMENT_GUIDE.md#web-ui-not-loading)

### Slow Performance
→ See [`IMMICH_DEPLOYMENT_GUIDE.md`](./IMMICH_DEPLOYMENT_GUIDE.md#performance-tuning)

---

## 📞 Support & Resources

### Documentation (Local)
```bash
# View all documentation
ls -lh IMMICH_*.md

# Quick reference
less IMMICH_QUICK_REFERENCE.md

# Complete guide
less IMMICH_DEPLOYMENT_GUIDE.md
```

### External Resources
- **Official Website**: https://immich.app
- **GitHub Repository**: https://github.com/immich-app/immich
- **Community Discord**: https://discord.com/invite/D8JsnBEuKb
- **Documentation**: https://immich.app/docs
- **Issue Tracker**: https://github.com/immich-app/immich/issues

### Getting Help
1. Check local documentation first
2. Run health check: `./immich-health-check.sh`
3. Review logs: `./immich-manage.sh logs`
4. Search GitHub issues
5. Ask in Discord community

---

## 📊 File Summary

| File | Type | Size | Purpose |
|------|------|------|---------|
| `docker-compose_immich.yml` | YAML | ~3KB | Standard deployment |
| `docker-compose_immich-advanced.yml` | YAML | ~4KB | Advanced features |
| `.env.immich` | ENV | <1KB | Configuration template |
| `postgres/postgresql.conf` | CONF | ~2KB | Database tuning |
| `immich-manage.sh` | Script | ~8KB | Service management |
| `immich-health-check.sh` | Script | ~10KB | Monitoring |
| `immich-backup.sh` | Script | ~12KB | Backup/restore |
| `IMMICH_README.md` | MD | ~15KB | Service overview |
| `IMMICH_DEPLOYMENT_GUIDE.md` | MD | ~25KB | Complete guide |
| `IMMICH_QUICK_REFERENCE.md` | MD | ~12KB | Quick commands |
| `IMMICH_SETUP_SUMMARY.md` | MD | ~10KB | Setup details |

**Total**: 11 files, ~102KB, production-ready

---

## ✨ What You Have Now

✅ **Production-ready deployment** with two configuration options  
✅ **Automated management tools** for daily operations  
✅ **Health monitoring system** with reporting  
✅ **Backup/restore utilities** for disaster recovery  
✅ **Comprehensive documentation** for all skill levels  
✅ **Database optimization** for performance  
✅ **Security best practices** built-in  
✅ **Scalable architecture** for growth  

---

## 🎉 You're Ready!

Everything is configured and ready to use. Start with:

```bash
cd /Users/notuser/GUA/program/server/server-setup
cp .env.immich .env
nano .env  # Set your DB_PASSWORD
./immich-manage.sh start
```

Then open http://localhost:3000 in your browser.

For any questions, refer to the documentation files or consult the official Immich resources.

**Happy backing up your photos! 📸**

---

**Setup completed**: 2026-09-13  
**Status**: ✅ Ready for deployment  
**Next action**: Run `./immich-manage.sh start`
