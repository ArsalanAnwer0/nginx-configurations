#!/bin/bash
# Nginx Health Monitoring Script

set -euo pipefail

# Configuration
LOG_FILE="/var/log/nginx-health.log"
ERROR_LOG="/var/log/nginx/error.log"
ACCESS_LOG="/var/log/nginx/access.log"
ALERT_EMAIL="" # Set email for alerts (optional)

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Function to log with timestamp
log_with_time() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >>"$LOG_FILE"
}

# Check if nginx service is running
check_nginx_service() {
  log_info "Checking Nginx service status..."

  if systemctl is-active --quiet nginx; then
    log_success "Nginx service is running"
    log_with_time "OK: Nginx service is running"
    return 0
  else
    log_error "Nginx service is not running"
    log_with_time "ERROR: Nginx service is not running"
    return 1
  fi
}

# Check nginx configuration
check_nginx_config() {
  log_info "Checking Nginx configuration..."

  if nginx -t &>/dev/null; then
    log_success "Nginx configuration is valid"
    log_with_time "OK: Nginx configuration is valid"
    return 0
  else
    log_error "Nginx configuration has errors"
    log_with_time "ERROR: Nginx configuration has errors"
    nginx -t 2>&1 | head -5 >>"$LOG_FILE"
    return 1
  fi
}

# Check HTTP response
check_http_response() {
  log_info "Checking HTTP response..."

  if curl -f -s http://localhost >/dev/null; then
    log_success "HTTP is responding"
    log_with_time "OK: HTTP is responding"
    return 0
  else
    log_error "HTTP is not responding"
    log_with_time "ERROR: HTTP is not responding"
    return 1
  fi
}

# Check HTTPS response (if SSL is configured)
check_https_response() {
  log_info "Checking HTTPS response..."

  if curl -f -s -k https://localhost >/dev/null 2>&1; then
    log_success "HTTPS is responding"
    log_with_time "OK: HTTPS is responding"
    return 0
  else
    log_warning "HTTPS is not responding (may not be configured)"
    log_with_time "WARNING: HTTPS is not responding"
    return 1
  fi
}

# Check disk space
check_disk_space() {
  log_info "Checking disk space..."

  # Check log directory disk usage
  LOG_USAGE=$(df /var/log | awk 'NR==2 {print $5}' | sed 's/%//')

  if [[ $LOG_USAGE -lt 80 ]]; then
    log_success "Disk space OK (${LOG_USAGE}% used)"
    log_with_time "OK: Disk space ${LOG_USAGE}% used"
    return 0
  elif [[ $LOG_USAGE -lt 90 ]]; then
    log_warning "Disk space getting low (${LOG_USAGE}% used)"
    log_with_time "WARNING: Disk space ${LOG_USAGE}% used"
    return 1
  else
    log_error "Disk space critical (${LOG_USAGE}% used)"
    log_with_time "ERROR: Disk space critical ${LOG_USAGE}% used"
    return 1
  fi
}

# Check memory usage
check_memory_usage() {
  log_info "Checking memory usage..."

  # Get nginx memory usage
  NGINX_MEM=$(ps aux | grep nginx | grep -v grep | awk '{sum+=$6} END {print sum/1024}')
  NGINX_MEM=${NGINX_MEM:-0}

  # Get total memory usage
  TOTAL_MEM=$(free | awk 'NR==2{printf "%.1f", $3*100/$2}')

  log_success "Memory usage: ${TOTAL_MEM}% total, Nginx: ${NGINX_MEM}MB"
  log_with_time "OK: Memory usage ${TOTAL_MEM}% total, Nginx ${NGINX_MEM}MB"

  return 0
}

# Check for recent errors
check_recent_errors() {
  log_info "Checking for recent errors..."

  if [[ -f "$ERROR_LOG" ]]; then
    # Count errors in last 5 minutes
    ERROR_COUNT=$(grep "$(date '+%Y/%m/%d %H:%M' -d '5 minutes ago')" "$ERROR_LOG" 2>/dev/null | wc -l || echo 0)

    if [[ $ERROR_COUNT -gt 10 ]]; then
      log_warning "High error rate: $ERROR_COUNT errors in last 5 minutes"
      log_with_time "WARNING: High error rate $ERROR_COUNT errors"
      return 1
    else
      log_success "Error rate normal: $ERROR_COUNT errors in last 5 minutes"
      log_with_time "OK: Error rate normal $ERROR_COUNT errors"
      return 0
    fi
  else
    log_warning "Error log not found: $ERROR_LOG"
    return 1
  fi
}

# Check nginx processes
check_nginx_processes() {
  log_info "Checking Nginx processes..."

  PROCESS_COUNT=$(ps aux | grep nginx | grep -v grep | wc -l)

  if [[ $PROCESS_COUNT -gt 0 ]]; then
    log_success "$PROCESS_COUNT Nginx processes running"
    log_with_time "OK: $PROCESS_COUNT Nginx processes running"
    return 0
  else
    log_error "No Nginx processes found"
    log_with_time "ERROR: No Nginx processes found"
    return 1
  fi
}

# Check port availability
check_ports() {
  log_info "Checking port availability..."

  # Check port 80
  if netstat -tlnp | grep -q ":80 "; then
    log_success "Port 80 is listening"
    log_with_time "OK: Port 80 is listening"
    PORT_80_OK=1
  else
    log_error "Port 80 is not listening"
    log_with_time "ERROR: Port 80 is not listening"
    PORT_80_OK=0
  fi

  # Check port 443
  if netstat -tlnp | grep -q ":443 "; then
    log_success "Port 443 is listening"
    log_with_time "OK: Port 443 is listening"
    PORT_443_OK=1
  else
    log_warning "Port 443 is not listening (SSL may not be configured)"
    log_with_time "WARNING: Port 443 is not listening"
    PORT_443_OK=0
  fi

  if [[ $PORT_80_OK -eq 1 ]]; then
    return 0
  else
    return 1
  fi
}

# Send alert (if email is configured)
send_alert() {
  local message="$1"

  if [[ -n "$ALERT_EMAIL" ]] && command -v mail >/dev/null; then
    echo "$message" | mail -s "Nginx Health Alert - $(hostname)" "$ALERT_EMAIL"
    log_info "Alert sent to $ALERT_EMAIL"
  fi
}

# Generate health report
generate_report() {
  echo
  log_info "Health Check Summary"
  echo "=========================="

  # Count successful checks
  local total_checks=8
  local passed_checks=0

  # Run all checks and count results
  check_nginx_service && ((passed_checks++)) || true
  check_nginx_config && ((passed_checks++)) || true
  check_http_response && ((passed_checks++)) || true
  check_https_response && ((passed_checks++)) || true
  check_disk_space && ((passed_checks++)) || true
  check_memory_usage && ((passed_checks++)) || true
  check_recent_errors && ((passed_checks++)) || true
  check_nginx_processes && ((passed_checks++)) || true
  check_ports && ((passed_checks++)) || true

  echo
  if [[ $passed_checks -eq $total_checks ]]; then
    log_success "All health checks passed ($passed_checks/$total_checks)"
    log_with_time "SUMMARY: All health checks passed"
    exit 0
  elif [[ $passed_checks -ge 6 ]]; then
    log_warning "Most health checks passed ($passed_checks/$total_checks)"
    log_with_time "SUMMARY: Most health checks passed"
    exit 1
  else
    log_error "Multiple health checks failed ($passed_checks/$total_checks)"
    log_with_time "SUMMARY: Multiple health checks failed"
    send_alert "Nginx health check failed: $passed_checks/$total_checks checks passed"
    exit 2
  fi
}

# Show usage
show_usage() {
  echo "Nginx Health Monitoring Script"
  echo
  echo "Usage: $0 [options]"
  echo
  echo "Options:"
  echo "  --help, -h     Show this help message"
  echo "  --quiet, -q    Quiet mode (minimal output)"
  echo "  --report       Generate detailed report"
  echo
  echo "Exit codes:"
  echo "  0 = All checks passed"
  echo "  1 = Some warnings found"
  echo "  2 = Critical issues found"
}

# Main execution
main() {
  local quiet_mode=false
  local report_mode=false

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
    --help | -h)
      show_usage
      exit 0
      ;;
    --quiet | -q)
      quiet_mode=true
      shift
      ;;
    --report)
      report_mode=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      show_usage
      exit 1
      ;;
    esac
  done

  # Create log file if it doesn't exist
  sudo touch "$LOG_FILE"

  if [[ $quiet_mode == false ]]; then
    log_info "Starting Nginx health check..."
    echo
  fi

  if [[ $report_mode == true ]]; then
    generate_report
  else
    # Quick health check
    if check_nginx_service && check_nginx_config && check_http_response; then
      if [[ $quiet_mode == false ]]; then
        log_success "Nginx is healthy"
      fi
      exit 0
    else
      if [[ $quiet_mode == false ]]; then
        log_error "Nginx health check failed"
      fi
      exit 2
    fi
  fi
}

# Run main function
main "$@"
