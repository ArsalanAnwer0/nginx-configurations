#!/bin/bash
# SSL Certificate Setup Script with Let's Encrypt

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Functions for colored output
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

# Install Certbot
install_certbot() {
  log_info "Installing Certbot..."

  if command -v apt >/dev/null 2>&1; then
    # Ubuntu/Debian
    apt update
    apt install -y certbot python3-certbot-nginx
  elif command -v yum >/dev/null 2>&1; then
    # CentOS/RHEL
    yum install -y epel-release
    yum install -y certbot python3-certbot-nginx
  else
    log_error "Unsupported operating system"
  fi

  log_success "Certbot installed successfully"
}

# Get domain input from user
get_domain() {
  echo
  log_info "SSL Certificate Setup"
  echo
  read -p "Enter your domain name (e.g., example.com): " DOMAIN
  read -p "Include www.${DOMAIN}? (y/n): " INCLUDE_WWW
  read -p "Enter your email address: " EMAIL

  if [[ -z "$DOMAIN" ]]; then
    log_error "Domain name is required"
  fi

  if [[ -z "$EMAIL" ]]; then
    log_error "Email address is required"
  fi
}

# Check if domain points to this server
check_domain() {
  log_info "Checking domain configuration..."

  # Get server's public IP
  SERVER_IP=$(curl -s http://checkip.amazonaws.com/ || curl -s http://ipinfo.io/ip)

  # Check if domain resolves to this server
  DOMAIN_IP=$(dig +short $DOMAIN | tail -n1)

  if [[ "$DOMAIN_IP" != "$SERVER_IP" ]]; then
    log_warning "Domain $DOMAIN resolves to $DOMAIN_IP but server IP is $SERVER_IP"
    read -p "Continue anyway? (y/n): " CONTINUE
    if [[ "$CONTINUE" != "y" ]]; then
      log_error "Please update your DNS records first"
    fi
  else
    log_success "Domain points to this server correctly"
  fi
}

# Test HTTP connectivity
test_http() {
  log_info "Testing HTTP connectivity..."

  if curl -f -s http://$DOMAIN >/dev/null; then
    log_success "HTTP is working"
  else
    log_warning "HTTP test failed - this might cause SSL generation to fail"
    read -p "Continue anyway? (y/n): " CONTINUE
    if [[ "$CONTINUE" != "y" ]]; then
      log_error "Please fix HTTP connectivity first"
    fi
  fi
}

# Generate SSL certificate
generate_ssl() {
  log_info "Generating SSL certificate..."

  # Build certbot command
  CERTBOT_CMD="certbot --nginx --non-interactive --agree-tos --email $EMAIL"

  if [[ "$INCLUDE_WWW" == "y" ]]; then
    CERTBOT_CMD="$CERTBOT_CMD -d $DOMAIN -d www.$DOMAIN"
  else
    CERTBOT_CMD="$CERTBOT_CMD -d $DOMAIN"
  fi

  # Run[48;33;136;1023;1904t certbot
  if $CERTBOT_CMD; then
    log_success "SSL certificate generated successfully"
  else
    log_error "SSL certificate generation failed"
  fi
}

# Test SSL certificate
test_ssl() {
  log_info "Testing SSL certificate..."

  sleep 5 # Wait for nginx reload

  if curl -f -s https://$DOMAIN >/dev/null; then
    log_success "HTTPS is working correctly"
  else
    log_warning "HTTPS test failed"
  fi

  # Check certificate expiry
  EXPIRY=$(echo | openssl s_client -connect $DOMAIN:443 -servername $DOMAIN 2>/dev/null | openssl x509 -noout -enddate | cut -d= -f2)
  log_info "Certificate expires: $EXPIRY"
}

# Setup auto-renewal
setup_renewal() {
  log_info "Setting up automatic renewal..."

  # Check if systemd timer exists
  if systemctl list-timers | grep -q certbot; then
    log_success "Certbot timer already configured"
  else
    # Create manual cron job
    log_info "Setting up cron job for renewal..."

    # Add to root crontab if not exists
    if ! crontab -l 2>/dev/null | grep -q certbot; then
      (
        crontab -l 2>/dev/null
        echo "0 12 * * * /usr/bin/certbot renew --quiet --deploy-hook 'systemctl reload nginx'"
      ) | crontab -
      log_success "Cron job added for automatic renewal"
    fi
  fi

  # Test renewal
  log_info "Testing renewal process..."
  if certbot renew --dry-run; then
    log_success "Renewal test passed"
  else
    log_warning "Renewal test failed"
  fi
}

# Display summary
show_summary() {
  echo
  log_success "SSL setup completed successfully!"
  echo
  echo "Domain: $DOMAIN"
  echo "Certificate location: /etc/letsencrypt/live/$DOMAIN/"
  echo "Auto-renewal: Configured"
  echo
  echo "Test your SSL:"
  echo "https://www.ssllabs.com/ssltest/analyze.html?d=$DOMAIN"
  echo
  echo "Useful commands:"
  echo "  certbot certificates                    # List certificates"
  echo "  certbot renew                         # Manual renewal"
  echo "  certbot renew --dry-run               # Test renewal"
  echo
}

# Main execution
main() {
  log_info "Starting SSL certificate setup..."

  check_root
  install_certbot
  get_domain
  check_domain
  test_http
  generate_ssl
  test_ssl
  setup_renewal
  show_summary
}

# Run main function
main "$@"
