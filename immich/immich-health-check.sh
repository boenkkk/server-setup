#!/bin/bash

# Immich Health Check and Monitoring Script (v3)
# Monitors Immich services and generates health reports

set -e

COMPOSE_FILE="${1:-docker-compose_immich.yml}"
REPORT_DIR="immich-reports"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="$REPORT_DIR/health-report-${TIMESTAMP}.txt"
IMMICH_PORT="${IMMICH_PORT:-2283}"

# Create report directory
mkdir -p "$REPORT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Initialize report
init_report() {
    cat > "$REPORT_FILE" << EOF
================================================================================
Immich Health Check Report
Generated: $(date)
Compose File: $COMPOSE_FILE
================================================================================

EOF
}

# Check container status
check_containers() {
    log_info "Checking container status..."
    
    {
        echo "### Container Status"
        echo ""
        docker-compose -f "$COMPOSE_FILE" ps
        echo ""
    } >> "$REPORT_FILE"
    
    # Verify all containers are running
    RUNNING=$(docker-compose -f "$COMPOSE_FILE" ps -q | wc -l)
    EXPECTED=3  # immich-server, immich-db, immich-redis
    
    if [ "$RUNNING" -ge "$EXPECTED" ]; then
        log_success "All containers running ($RUNNING)"
    else
        log_warn "Only $RUNNING/$EXPECTED containers running"
    fi
}

# Check database health
check_database() {
    log_info "Checking database..."
    
    {
        echo "### Database Health"
        echo ""
        
        if docker exec immich-db pg_isready -U postgres > /dev/null 2>&1; then
            echo "Status: OK"
            
            # Get database size
            DB_SIZE=$(docker exec immich-db psql -U postgres -d immich -t -c "SELECT pg_size_pretty(pg_database_size('immich'));")
            echo "Size: $DB_SIZE"
            
            # Get connection count
            CONNECTIONS=$(docker exec immich-db psql -U postgres -d immich -t -c "SELECT count(*) FROM pg_stat_activity;")
            echo "Active Connections: $CONNECTIONS"
            
            # Get table count
            TABLES=$(docker exec immich-db psql -U postgres -d immich -t -c "SELECT count(*) FROM information_schema.tables WHERE table_schema='public';")
            echo "Tables: $TABLES"
        else
            echo "Status: FAILED"
        fi
        echo ""
    } >> "$REPORT_FILE"
}

# Check Redis (Valkey) health
check_redis() {
    log_info "Checking Redis (Valkey)..."
    
    {
        echo "### Redis Health"
        echo ""
        
        if docker exec immich-redis redis-cli ping > /dev/null 2>&1; then
            echo "Status: OK"
            
            # Get Redis info
            INFO=$(docker exec immich-redis redis-cli info stats)
            echo "Stats:"
            echo "$INFO" | grep -E "(total_connections_received|total_commands_processed|used_memory_human)" | sed 's/^/  /'
        else
            echo "Status: FAILED"
        fi
        echo ""
    } >> "$REPORT_FILE"
}

# Check API server + Web UI (same port in v3)
check_api() {
    log_info "Checking API server..."
    
    {
        echo "### API Server Health"
        echo ""
        
        if curl -s "http://localhost:${IMMICH_PORT}/api/server/ping" > /dev/null 2>&1; then
            echo "Status: OK"
            
            # Get server info
            RESPONSE=$(curl -s "http://localhost:${IMMICH_PORT}/api/server/info" || echo "{}")
            echo "Response: $(echo $RESPONSE | head -c 100)..."
        else
            echo "Status: FAILED"
        fi
        echo ""
    } >> "$REPORT_FILE"
}

# Check Web UI
check_web() {
    log_info "Checking Web UI..."
    
    {
        echo "### Web UI Health"
        echo ""
        
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${IMMICH_PORT}")
        if [ "$HTTP_CODE" = "200" ]; then
            echo "Status: OK (HTTP $HTTP_CODE)"
        else
            echo "Status: FAILED (HTTP $HTTP_CODE)"
        fi
        echo ""
    } >> "$REPORT_FILE"
}

# Check disk usage
check_disk() {
    log_info "Checking disk usage..."
    
    {
        echo "### Disk Usage"
        echo ""
        
        # Check upload location
        if [ -d "$PWD/library" ]; then
            UPLOAD_SIZE=$(du -sh "$PWD/library" 2>/dev/null | cut -f1)
            echo "Upload Library ($PWD/library): $UPLOAD_SIZE"
        else
            echo "Upload Library: not found ($PWD/library)"
        fi
        
        # Check database location
        if [ -d "$PWD/postgres-data" ]; then
            DB_SIZE=$(du -sh "$PWD/postgres-data" 2>/dev/null | cut -f1)
            echo "Database Data ($PWD/postgres-data): $DB_SIZE"
        else
            echo "Database Data: not found ($PWD/postgres-data)"
        fi
        echo ""
    } >> "$REPORT_FILE"
}

# Check container logs for errors
check_logs() {
    log_info "Checking logs for errors..."
    
    {
        echo "### Recent Errors in Logs"
        echo ""
        
        SERVICES=("immich-server" "immich-db" "immich-redis")
        
        for SERVICE in "${SERVICES[@]}"; do
            ERRORS=$(docker logs --tail 100 "$SERVICE" 2>&1 | grep -i "error\|failed\|exception" | tail -5 || true)
            
            if [ -n "$ERRORS" ]; then
                echo "[$SERVICE]"
                echo "$ERRORS" | sed 's/^/  /'
                echo ""
            fi
        done
        echo ""
    } >> "$REPORT_FILE"
}

# Check container resource usage
check_resources() {
    log_info "Checking resource usage..."
    
    {
        echo "### Resource Usage"
        echo ""
        
        docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" | grep immich >> "$REPORT_FILE" || true
        echo ""
    } >> "$REPORT_FILE"
}

# Generate recommendations
generate_recommendations() {
    log_info "Generating recommendations..."
    
    {
        echo "### Recommendations"
        echo ""
        
        # Check database size
        DB_SIZE_BYTES=$(docker exec immich-db psql -U postgres -d immich -t -c "SELECT pg_database_size('immich');" 2>/dev/null || echo "0")
        if [ "$DB_SIZE_BYTES" -gt 5368709120 ]; then
            echo "⚠️  Large database (>5GB) - consider archiving old records"
        fi
        
        # Check upload location disk usage
        if [ -d "$PWD/library" ]; then
            UPLOAD_KB=$(du -sk "$PWD/library" 2>/dev/null | cut -f1)
            if [ "$UPLOAD_KB" -gt 104857600 ]; then
                echo "⚠️  Large upload library (>100GB) - consider cleanup or archival"
            fi
        fi
        
        # Check connection count
        CONNECTIONS=$(docker exec immich-db psql -U postgres -d immich -t -c "SELECT count(*) FROM pg_stat_activity;" 2>/dev/null || echo "0")
        if [ "$CONNECTIONS" -gt 50 ]; then
            echo "⚠️  High connection count ($CONNECTIONS) - consider connection pooling"
        fi
        
        echo "✅ System appears healthy" || true
        echo ""
    } >> "$REPORT_FILE"
}

# Display summary
display_summary() {
    {
        echo "### Summary"
        echo ""
        echo "Report saved to: $REPORT_FILE"
        echo "For detailed information, view the report file."
    } >> "$REPORT_FILE"
    
    echo ""
    log_info "Report saved to: $REPORT_FILE"
}

# Main execution
main() {
    echo ""
    log_info "Starting Immich Health Check..."
    echo ""
    
    init_report
    check_containers
    check_database
    check_redis
    check_api
    check_web
    check_disk
    check_logs
    check_resources
    generate_recommendations
    display_summary
    
    echo ""
    log_success "Health check complete!"
    echo ""
    
    # Display report summary
    tail -30 "$REPORT_FILE"
}

main