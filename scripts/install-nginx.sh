#!/bin/bash
# Nginx Installation Script for Cloud Environments

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
  exit 1
}

detect_os() {
  if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    OS=$ID
  else
    log_error "Cannot detect operating system"
  fi
  log_info "Detected OS: $OS"
}

check_root() {
  if [[ $EUID -ne 0 ]]; then
    log_error "This script must be run as root (use sudo)"
  fi
}

install_nginx() {
  log_info "Installing Nginx..."

  case $OS in
  ubuntu | debian)
    apt update
    apt install -y nginx certbot python3-certbot-nginx
    ;;
  centos | rhel | rocky | almalinux)
    yum install -y epel-release
    yum install -y nginx certbot python3-certbot-nginx
    ;;
  *)
    log_error "Unsupported OS: $OS"
    ;;
  esac
}

start_nginx() {
  log_info "Starting Nginx..."
  systemctl enable nginx
  systemctl start nginx

  if systemctl is-active --quiet nginx; then
    log_success "Nginx installed and started successfully"
  else
    log_error "Failed to start Nginx"
  fi
}

main() {
  log_info "Starting Nginx installation..."
  check_root
  detect_os
  install_nginx
  start_nginx

  log_success "Installation complete!"
  echo "Configuration: /etc/nginx/nginx.conf"
  echo "Test: curl http://localhost"
}

main "$@"
