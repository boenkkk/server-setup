#!/bin/bash

# Immich Docker Compose Startup Script
# This script helps manage Immich deployment with common operations

set -e

COMPOSE_FILE="${1:-docker-compose_immich.yml}"
COMMAND="${2:-help}"
ENV_FILE=".env.immich"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if docker and docker-compose are installed
check_requirements() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose is not installed"
        exit 1
    fi
    
    log_success "Docker and Docker Compose are installed"
}

# Initialize environment file
init_env() {
    if [ ! -f "$ENV_FILE" ]; then
        log_warn "Environment file not found, copying from template..."
        cp .env.immich "$ENV_FILE" 2>/dev/null || {
            log_error "Could not find .env.immich template"
            exit 1
        }
        log_info "Please edit $ENV_FILE and set secure values"
        log_info "Generated secure password for you to use"
        SECURE_PASS=$(openssl rand -base64 32)
        log_info "DB_PASSWORD: $SECURE_PASS"
    fi
}

# Start services
start_services() {
    log_info "Starting Immich services..."
    init_env
    
    docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d
    
    log_success "Immich services started"
    
    # Wait for services to be healthy
    log_info "Waiting for services to be healthy..."
    sleep 10
    
    check_health
}

# Stop services
stop_services() {
    log_info "Stopping Immich services..."
    docker-compose -f "$COMPOSE_FILE" stop
    log_success "Immich services stopped"
}

# Restart services
restart_services() {
    log_info "Restarting Immich services..."
    docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" restart
    log_success "Immich services restarted"
}

# Remove everything
remove_services() {
    log_warn "This will remove all containers and volumes!"
    read -p "Are you sure? (yes/no): " confirm
    
    if [ "$confirm" = "yes" ]; then
        log_info "Removing Immich services..."
        docker-compose -f "$COMPOSE_FILE" down -v
        log_success "Immich services removed"
    else
        log_info "Cancelled"
    fi
}

# Check service health
check_health() {
    log_info "Checking service health..."
    
    # Check database
    if docker exec immich-db pg_isready -U immich &> /dev/null; then
        log_success "Database: OK"
    else
        log_error "Database: FAILED"
    fi
    
    # Check Redis
    if docker exec immich-redis redis-cli ping &> /dev/null; then
        log_success "Redis: OK"
    else
        log_error "Redis: FAILED"
    fi
    
    # Check API + Web UI (served on the same port since Immich v1.106+)
    if curl -s http://localhost:${IMMICH_PORT:-2283}/api/server/ping &> /dev/null; then
        log_success "API Server: OK"
    else
        log_error "API Server: FAILED"
    fi
    
    # Check Web UI
    if curl -s -o /dev/null http://localhost:${IMMICH_PORT:-2283} &> /dev/null; then
        log_success "Web UI: OK"
    else
        log_error "Web UI: FAILED"
    fi
}

# View logs
view_logs() {
    local service="${3:-}"
    if [ -z "$service" ]; then
        log_info "Showing logs from all services (Ctrl+C to exit)..."
        docker-compose -f "$COMPOSE_FILE" logs -f
    else
        log_info "Showing logs from $service (Ctrl+C to exit)..."
        docker-compose -f "$COMPOSE_FILE" logs -f "$service"
    fi
}

# Backup database
backup_database() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="immich-db-backup-${timestamp}.sql"
    
    log_info "Backing up database to $backup_file..."
    docker exec immich-db pg_dump -U immich immich > "$backup_file"
    log_success "Database backed up to $backup_file"
}

# Restore database
restore_database() {
    local backup_file="${3:-}"
    
    if [ -z "$backup_file" ]; then
        log_error "Please provide backup file path"
        exit 1
    fi
    
    if [ ! -f "$backup_file" ]; then
        log_error "Backup file not found: $backup_file"
        exit 1
    fi
    
    log_warn "This will restore the database from backup!"
    read -p "Are you sure? (yes/no): " confirm
    
    if [ "$confirm" = "yes" ]; then
        log_info "Restoring database from $backup_file..."
        docker exec -i immich-db psql -U immich immich < "$backup_file"
        log_success "Database restored"
    else
        log_info "Cancelled"
    fi
}

# View status
view_status() {
    log_info "Immich Services Status:"
    docker-compose -f "$COMPOSE_FILE" ps
}

# Update images
update_images() {
    log_info "Pulling latest images..."
    docker-compose -f "$COMPOSE_FILE" pull
    log_success "Images updated"
    
    log_info "Restarting services with new images..."
    docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d
    log_success "Services restarted"
}

# Show help
show_help() {
    cat << EOF
${BLUE}Immich Docker Compose Manager${NC}

Usage: $0 [COMPOSE_FILE] [COMMAND]

COMPOSE_FILE (default: docker-compose_immich.yml):
  docker-compose_immich.yml        - Standard setup
  docker-compose_immich-advanced.yml - Advanced setup with ML support

COMMANDS:
  start              Start Immich services
  stop               Stop Immich services
  restart            Restart Immich services
  status             Show service status
  logs [SERVICE]     View service logs (SERVICE optional)
  health             Check service health
  backup             Backup database
  restore [FILE]     Restore database from backup
  update             Update Docker images and restart
  remove             Remove all services and volumes (DESTRUCTIVE)
  help               Show this help message

EXAMPLES:
  $0 start
  $0 docker-compose_immich-advanced.yml start
  $0 logs immich-server
  $0 backup
  $0 restore immich-db-backup-20260913_120000.sql

SERVICES:
  immich-db
  immich-redis
  immich-server
  immich-microservices
  immich-machine-learning (advanced, ml profile)

URLS:
  Web UI + API: http://<server-ip>:${IMMICH_PORT:-2283}

EOF
}

# Main
case "$COMMAND" in
    start)
        check_requirements
        start_services
        ;;
    stop)
        stop_services
        ;;
    restart)
        restart_services
        ;;
    status)
        view_status
        ;;
    logs)
        view_logs "$@"
        ;;
    health)
        check_health
        ;;
    backup)
        backup_database
        ;;
    restore)
        restore_database "$@"
        ;;
    update)
        update_images
        ;;
    remove)
        remove_services
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
