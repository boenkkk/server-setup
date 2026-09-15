#!/bin/bash

# Immich Backup and Restore Utility
# Manages backups of database, volumes, and configuration

set -e

BACKUP_DIR="immich-backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
COMPOSE_FILE="${1:-docker-compose_immich.yml}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup database only
backup_database() {
    local backup_file="$BACKUP_DIR/immich-db-${TIMESTAMP}.sql"
    
    log_info "Starting database backup..."
    log_info "Backup file: $backup_file"
    
    if ! docker exec immich-db pg_isready -U postgres > /dev/null 2>&1; then
        log_error "Database is not ready"
        return 1
    fi
    
    docker exec immich-db pg_dump -U postgres immich > "$backup_file"
    
    local size=$(du -h "$backup_file" | cut -f1)
    log_success "Database backed up successfully (Size: $size)"
    echo "$backup_file"
}

# Backup database compressed
backup_database_compressed() {
    local backup_file="$BACKUP_DIR/immich-db-${TIMESTAMP}.sql.gz"
    
    log_info "Starting compressed database backup..."
    log_info "Backup file: $backup_file"
    
    if ! docker exec immich-db pg_isready -U postgres > /dev/null 2>&1; then
        log_error "Database is not ready"
        return 1
    fi
    
    docker exec immich-db pg_dump -U postgres immich | gzip > "$backup_file"
    
    local size=$(du -h "$backup_file" | cut -f1)
    log_success "Compressed database backup completed (Size: $size)"
    echo "$backup_file"
}

# Backup volumes
backup_volumes() {
    log_info "Starting volume backup..."
    
    local volumes=("immich-upload" "immich-thumbs" "immich-db-data")
    
    for volume in "${volumes[@]}"; do
        local backup_file="$BACKUP_DIR/immich-volume-${volume}-${TIMESTAMP}.tar.gz"
        
        log_info "Backing up volume: $volume"
        docker run --rm -v "$volume":/data -v "$(pwd)/$BACKUP_DIR":/backup \
            ubuntu tar czf "/backup/immich-volume-${volume}-${TIMESTAMP}.tar.gz" -C /data .
        
        local size=$(du -h "$backup_file" | cut -f1)
        log_success "Volume $volume backed up (Size: $size)"
    done
}

# Full backup (database + volumes + config)
backup_full() {
    log_info "Starting full Immich backup..."
    
    local backup_name="immich-full-backup-${TIMESTAMP}"
    local backup_dir="$BACKUP_DIR/$backup_name"
    
    mkdir -p "$backup_dir"
    
    # Backup database
    log_info "Backing up database..."
    docker exec immich-db pg_dump -U postgres immich | gzip > "$backup_dir/database.sql.gz"
    
    # Backup volumes
    log_info "Backing up volumes..."
    local volumes=("immich-upload" "immich-thumbs" "immich-db-data")
    
    for volume in "${volumes[@]}"; do
        log_info "Backing up volume: $volume"
        docker run --rm -v "$volume":/data -v "$(pwd)/$backup_dir":/backup \
            ubuntu tar czf "/backup/volume-${volume}.tar.gz" -C /data .
    done
    
    # Backup configuration
    log_info "Backing up configuration..."
    cp .env.immich "$backup_dir/.env.immich" 2>/dev/null || true
    cp "$COMPOSE_FILE" "$backup_dir/docker-compose.yml" 2>/dev/null || true
    
    # Create manifest
    cat > "$backup_dir/MANIFEST.txt" << EOF
Immich Full Backup
Created: $(date)
Compose File: $COMPOSE_FILE

Contents:
- database.sql.gz: PostgreSQL database dump
- volume-immich-upload.tar.gz: User uploads
- volume-immich-thumbs.tar.gz: Generated thumbnails
- volume-immich-db-data.tar.gz: Database volume snapshot
- .env.immich: Environment configuration (KEEP SAFE)
- docker-compose.yml: Service configuration

Restore Instructions:
1. Stop services: docker-compose down
2. Restore database: docker exec -i immich-db psql -U postgres immich < database.sql
3. Restore volumes: See immich-restore-backup.sh script
4. Start services: docker-compose up -d

Important:
- This backup contains sensitive configuration
- Keep it secure and encrypted
- Store copy in secure location
EOF
    
    # Create compressed archive of entire backup
    local archive_file="$BACKUP_DIR/${backup_name}.tar.gz"
    tar czf "$archive_file" -C "$BACKUP_DIR" "$backup_name"
    
    local size=$(du -h "$archive_file" | cut -f1)
    log_success "Full backup completed (Size: $size)"
    log_info "Backup location: $archive_file"
    
    # Cleanup uncompressed backup directory
    rm -rf "$backup_dir"
}

# Restore database
restore_database() {
    local backup_file="${1:-}"
    
    if [ -z "$backup_file" ]; then
        log_error "Please provide backup file path"
        echo "Usage: $0 restore-db <backup_file>"
        return 1
    fi
    
    if [ ! -f "$backup_file" ]; then
        log_error "Backup file not found: $backup_file"
        return 1
    fi
    
    log_warn "This will overwrite the current database!"
    read -p "Are you sure? Type 'yes' to continue: " confirm
    
    if [ "$confirm" != "yes" ]; then
        log_info "Restore cancelled"
        return 0
    fi
    
    log_info "Stopping services..."
    docker-compose -f "$COMPOSE_FILE" stop immich-server || true
    
    log_info "Restoring database from: $backup_file"
    
    # Handle compressed backups
    if [[ "$backup_file" == *.gz ]]; then
        log_info "Decompressing backup..."
        gunzip -c "$backup_file" | docker exec -i immich-db psql -U postgres immich
    else
        docker exec -i immich-db psql -U postgres immich < "$backup_file"
    fi
    
    log_success "Database restored successfully"
    
    log_info "Starting services..."
    docker-compose -f "$COMPOSE_FILE" start immich-server
    
    log_success "Restore complete"
}

# Restore volume
restore_volume() {
    local volume_name="${1:-}"
    local backup_file="${2:-}"
    
    if [ -z "$volume_name" ] || [ -z "$backup_file" ]; then
        log_error "Usage: $0 restore-volume <volume_name> <backup_file>"
        return 1
    fi
    
    if [ ! -f "$backup_file" ]; then
        log_error "Backup file not found: $backup_file"
        return 1
    fi
    
    log_warn "This will overwrite the volume: $volume_name"
    read -p "Are you sure? Type 'yes' to continue: " confirm
    
    if [ "$confirm" != "yes" ]; then
        log_info "Restore cancelled"
        return 0
    fi
    
    log_info "Restoring volume: $volume_name"
    docker run --rm -v "$volume_name":/data -v "$(pwd)":/backup \
        ubuntu tar xzf "/backup/$backup_file" -C /data
    
    log_success "Volume restored successfully"
}

# List backups
list_backups() {
    log_info "Available backups:"
    echo ""
    
    if [ -d "$BACKUP_DIR" ]; then
        ls -lh "$BACKUP_DIR" | tail -n +2 | awk '{print $9, "(" $5 ")"}'
    else
        log_warn "No backups found"
    fi
    echo ""
}

# Cleanup old backups
cleanup_backups() {
    local keep_days="${1:-7}"
    
    log_info "Cleaning up backups older than $keep_days days..."
    
    find "$BACKUP_DIR" -type f -mtime +$keep_days -delete
    
    log_success "Cleanup complete"
}

# Show help
show_help() {
    cat << EOF
${BLUE}Immich Backup and Restore Utility${NC}

Usage: $0 [COMPOSE_FILE] [COMMAND] [ARGS]

COMMANDS:
  backup-db              Backup database only (uncompressed)
  backup-db-gz           Backup database (compressed with gzip)
  backup-volumes         Backup all volumes separately
  backup-full            Backup everything (db + volumes + config)
  restore-db <FILE>      Restore database from backup
  restore-volume <VOL>   Restore specific volume from backup
  list                   List available backups
  cleanup [DAYS]         Delete backups older than N days (default: 7)
  help                   Show this help message

EXAMPLES:
  $0 backup-db
  $0 backup-full
  $0 restore-db immich-backups/immich-db-20260913_150000.sql
  $0 restore-db immich-backups/immich-db-20260913_150000.sql.gz
  $0 list
  $0 cleanup 30

BACKUP DIRECTORY:
  $BACKUP_DIR/

NOTES:
  - Full backups create compressed archives of all data
  - Compressed backups use gzip and are restored transparently
  - Database backups can be restored even if containers are running
  - Volume restores require service stop
  - Always test restore procedures before relying on them

EOF
}

# Main
COMMAND="${2:-help}"

case "$COMMAND" in
    backup-db)
        backup_database
        ;;
    backup-db-gz)
        backup_database_compressed
        ;;
    backup-volumes)
        backup_volumes
        ;;
    backup-full)
        backup_full
        ;;
    restore-db)
        restore_database "$3"
        ;;
    restore-volume)
        restore_volume "$3" "$4"
        ;;
    list)
        list_backups
        ;;
    cleanup)
        cleanup_backups "$3"
        ;;
    help|--help|-h|"")
        show_help
        ;;
    *)
        log_error "Unknown command: $COMMAND"
        show_help
        exit 1
        ;;
esac
