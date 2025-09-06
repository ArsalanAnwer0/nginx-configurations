#!/bin/bash
# Nginx Configuration Backup Script

set -euo pipefail

# Configuration
BACKUP_DIR="/backup/nginx"
DATE=$(date +%Y%m%d_%H%M%S)
NGINX_CONFIG_DIR="/etc/nginx"
WEB_DIR="/var/www"
KEEP_DAYS=30

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
  exit 1
}

# Check if running as root
check_root() {
  if [[ $EUID -ne 0 ]]; then
    log_error "This script must be run as root (use sudo)"
  fi
}

# Create backup directory
create_backup_dir() {
  log_info "Creating backup directory..."
  mkdir -p "$BACKUP_DIR"
  log_success "Backup directory: $BACKUP_DIR"
}

# Backup nginx configuration
backup_nginx_config() {
  log_info "Backing up Nginx configuration..."

  if [[ -d "$NGINX_CONFIG_DIR" ]]; then
    tar -czf "$BACKUP_DIR/nginx-config-$DATE.tar.gz" -C /etc nginx/
    log_success "Nginx config backed up: nginx-config-$DATE.tar.gz"
  else
    log_warning "Nginx config directory not found: $NGINX_CONFIG_DIR"
  fi
}

# Backup website content
backup_web_content() {
  log_info "Backing up website content..."

  if [[ -d "$WEB_DIR" ]]; then
    tar -czf "$BACKUP_DIR/web-content-$DATE.tar.gz" -C /var www/
    log_success "Web content backed up: web-content-$DATE.tar.gz"
  else
    log_warning "Web directory not found: $WEB_DIR"
  fi
}

# Backup SSL certificates
backup_ssl_certs() {
  log_info "Backing up SSL certificates..."

  if [[ -d "/etc/letsencrypt" ]]; then
    tar -czf "$BACKUP_DIR/ssl-certs-$DATE.tar.gz" -C /etc letsencrypt/
    log_success "SSL certificates backed up: ssl-certs-$DATE.tar.gz"
  else
    log_warning "Let's Encrypt directory not found"
  fi
}

# Create backup info file
create_backup_info() {
  log_info "Creating backup information file..."

  cat >"$BACKUP_DIR/backup-info-$DATE.txt" <<EOF
Nginx Backup Information
========================
Date: $(date)
Server: $(hostname)
Nginx Version: $(nginx -v 2>&1)
Backup Files:
- nginx-config-$DATE.tar.gz
- web-content-$DATE.tar.gz
- ssl-certs-$DATE.tar.gz

Restore Instructions:
1. Stop nginx: systemctl stop nginx
2. Extract config: tar -xzf nginx-config-$DATE.tar.gz -C /etc/
3. Extract content: tar -xzf web-content-$DATE.tar.gz -C /var/
4. Extract SSL: tar -xzf ssl-certs-$DATE.tar.gz -C /etc/
5. Test config: nginx -t
6. Start nginx: systemctl start nginx
EOF

  log_success "Backup info created: backup-info-$DATE.txt"
}

# Clean old backups
cleanup_old_backups() {
  log_info "Cleaning up old backups (older than $KEEP_DAYS days)..."

  find "$BACKUP_DIR" -name "*.tar.gz" -mtime +$KEEP_DAYS -delete
  find "$BACKUP_DIR" -name "backup-info-*.txt" -mtime +$KEEP_DAYS -delete

  log_success "Old backups cleaned up"
}

# Show backup summary
show_summary() {
  log_success "Backup completed successfully!"
  echo
  echo "Backup location: $BACKUP_DIR"
  echo "Backup date: $DATE"
  echo
  echo "Files created:"
  ls -lh "$BACKUP_DIR"/*$DATE*
  echo
  echo "Total backup size:"
  du -sh "$BACKUP_DIR"/*$DATE* | awk '{sum+=$1} END {print sum " total"}'
}

# Main execution
main() {
  log_info "Starting Nginx backup..."

  check_root
  create_backup_dir
  backup_nginx_config
  backup_web_content
  backup_ssl_certs
  create_backup_info
  cleanup_old_backups
  show_summary
}

# Show usage if help requested
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
  echo "Nginx Configuration Backup Script"
  echo
  echo "Usage: sudo $0"
  echo
  echo "This script backs up:"
  echo "- Nginx configuration files"
  echo "- Website content"
  echo "- SSL certificates"
  echo
  echo "Backups are stored in: $BACKUP_DIR"
  echo "Old backups (>$KEEP_DAYS days) are automatically removed"
  exit 0
fi

# Run main function
main "$@"
