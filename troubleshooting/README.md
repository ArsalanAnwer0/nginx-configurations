# Nginx Troubleshooting Guide

## Common Issues

### Nginx Won't Start

#### Check what's using port 80
```bash
sudo netstat -tlnp | grep :80
sudo lsof -i :80
sudo ss -tlnp | grep :80
```

#### Stop conflicting services
```bash
sudo systemctl stop apache2  # If Apache is running
sudo systemctl stop httpd    # If httpd is running
```

#### Check Nginx service status
```bash
sudo systemctl status nginx
sudo journalctl -u nginx.service
```

#### Check permissions
```bash
sudo chown -R nginx:nginx /var/log/nginx/
sudo chmod -R 755 /var/log/nginx/
sudo chown -R www-data:www-data /var/www/
```

### Configuration Errors

#### Test configuration
```bash
sudo nginx -t
sudo nginx -T  # Show full configuration
```

#### Common syntax issues
- Missing semicolons after directives
- Unmatched curly braces `{}`
- Invalid file paths
- Incorrect directive names
- Wrong context for directives

#### Configuration validation examples
```bash
# Check specific configuration file
sudo nginx -t -c /etc/nginx/nginx.conf

# Check configuration and quit
sudo nginx -t -q
```

### SSL Certificate Issues

#### Check certificate files
```bash
sudo ls -la /etc/letsencrypt/live/your-domain.com/
sudo ls -la /etc/ssl/certs/
sudo ls -la /etc/ssl/private/
```

#### Fix certificate permissions
```bash
sudo chmod 644 /etc/letsencrypt/live/your-domain.com/fullchain.pem
sudo chmod 600 /etc/letsencrypt/live/your-domain.com/privkey.pem
sudo chown root:root /etc/letsencrypt/live/your-domain.com/*
```

#### Test SSL configuration
```bash
# Test SSL connection
openssl s_client -connect your-domain.com:443 -servername your-domain.com

# Check certificate expiration
openssl x509 -in /path/to/certificate.crt -text -noout | grep "Not After"

# Verify certificate chain
openssl verify -CAfile /etc/ssl/certs/ca-certificates.crt /path/to/certificate.crt
```

#### Let's Encrypt certificate renewal
```bash
sudo certbot renew --dry-run
sudo certbot certificates
sudo systemctl status certbot.timer
```

### Performance Issues

#### Check system resources
```bash
htop
top
free -h
df -h
iostat -x 1
```

#### Monitor Nginx processes
```bash
ps aux | grep nginx
pstree -p `pidof nginx`
```

#### Check connection limits
```bash
# Current connections
ss -s
netstat -an | grep :80 | wc -l

# Nginx worker connections
ps aux | grep "nginx: worker"
```

#### Check file descriptor limits
```bash
# System limits
ulimit -n
cat /proc/sys/fs/file-max

# Nginx limits
cat /proc/$(pgrep nginx | head -1)/limits | grep "Max open files"
```

### File Permission Issues

#### Check web directory permissions
```bash
ls -la /var/www/
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/
```

#### Check Nginx configuration file permissions
```bash
ls -la /etc/nginx/
sudo chmod 644 /etc/nginx/nginx.conf
sudo chmod 644 /etc/nginx/sites-available/*
```

#### SELinux issues (if enabled)
```bash
# Check SELinux status
sestatus

# Check SELinux denials
sudo ausearch -m avc -ts recent

# Set SELinux contexts for web files
sudo setsebool -P httpd_can_network_connect 1
sudo chcon -R -t httpd_exec_t /var/www/html/
```

## Debugging Commands

### Service Management
```bash
# Service status
sudo systemctl status nginx
sudo systemctl is-active nginx
sudo systemctl is-enabled nginx

# Start/stop/restart
sudo systemctl start nginx
sudo systemctl stop nginx
sudo systemctl restart nginx
sudo systemctl reload nginx
```

### Configuration Testing
```bash
# Test configuration
sudo nginx -t

# Test and show configuration
sudo nginx -T

# Check configuration file syntax
sudo nginx -t -c /path/to/nginx.conf
```

### Log Analysis
```bash
# View real-time logs
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log

# Search for specific errors
sudo grep -i "error" /var/log/nginx/error.log
sudo grep "404" /var/log/nginx/access.log

# View systemd logs
sudo journalctl -u nginx.service -f
sudo journalctl -u nginx.service --since "1 hour ago"
```

### Process and Network Monitoring
```bash
# Check Nginx processes
ps aux | grep nginx
pgrep nginx

# Check listening ports
sudo netstat -tlnp | grep nginx
sudo ss -tlnp | grep nginx
sudo lsof -i :80,443

# Check open files
sudo lsof -p $(pgrep nginx)
```

### Memory and Performance
```bash
# Memory usage
free -h
cat /proc/meminfo

# CPU usage
top -p $(pgrep nginx | tr '\n' ',' | sed 's/,$//')

# Disk usage
df -h
du -sh /var/log/nginx/
```

## Emergency Recovery

### Backup and Restore Configuration
```bash
# Create backup
sudo cp -r /etc/nginx/ /etc/nginx.backup.$(date +%Y%m%d)

# Restore from backup
sudo cp /etc/nginx/nginx.conf.backup /etc/nginx/nginx.conf
sudo nginx -t && sudo systemctl reload nginx
```

### Reset to Default Configuration
```bash
# Ubuntu/Debian
sudo apt-get purge nginx nginx-common
sudo apt-get install nginx

# CentOS/RHEL
sudo yum remove nginx
sudo yum install nginx
```

### Emergency Access Restoration
```bash
# Disable problematic site
sudo rm /etc/nginx/sites-enabled/problematic-site
sudo nginx -t && sudo systemctl reload nginx

# Use minimal configuration
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.broken
cat > /tmp/minimal.conf << 'EOF'
events {
    worker_connections 1024;
}
http {
    server {
        listen 80;
        location / {
            return 200 "Nginx is working\n";
            add_header Content-Type text/plain;
        }
    }
}
EOF
sudo cp /tmp/minimal.conf /etc/nginx/nginx.conf
sudo nginx -t && sudo systemctl reload nginx
```

## Advanced Troubleshooting

### Enable Debug Logging
```nginx
# Add to nginx.conf for detailed debugging
error_log /var/log/nginx/debug.log debug;
```

### Network Connectivity Testing
```bash
# Test from server
curl -I http://localhost
curl -I https://localhost
wget --spider http://your-domain.com

# Test DNS resolution
nslookup your-domain.com
dig your-domain.com

# Test firewall
sudo iptables -L
sudo ufw status
```

### Performance Debugging
```bash
# Check worker process limits
cat /proc/sys/kernel/pid_max
cat /proc/sys/fs/file-max

# Monitor real-time connections
watch 'ss -tuln | grep :80'

# Check for memory leaks
valgrind --tool=memcheck --leak-check=full nginx -t
```

### Common Error Messages and Solutions

#### "Permission denied" errors
```bash
# Check file ownership
ls -la /var/www/html/
sudo chown -R www-data:www-data /var/www/html/

# Check directory permissions
sudo chmod 755 /var/www/html/
sudo chmod 644 /var/www/html/index.html
```

#### "Address already in use" errors
```bash
# Find process using port
sudo lsof -i :80
sudo fuser -k 80/tcp  # Kill processes on port 80
```

#### "Could not build optimal types_hash" errors
```bash
# Add to nginx.conf http block
types_hash_max_size 2048;
types_hash_bucket_size 64;
```

#### "Too many open files" errors
```bash
# Increase file descriptor limits
echo "fs.file-max = 65536" | sudo tee -a /etc/sysctl.conf
echo "nginx soft nofile 65536" | sudo tee -a /etc/security/limits.conf
echo "nginx hard nofile 65536" | sudo tee -a /etc/security/limits.conf
sudo sysctl -p
```

## Monitoring and Prevention

### Regular Health Checks
```bash
# Create monitoring script
cat > /usr/local/bin/nginx-health-check.sh << 'EOF'
#!/bin/bash
if ! nginx -t; then
    echo "Nginx configuration error detected"
    exit 1
fi

if ! systemctl is-active nginx > /dev/null; then
    echo "Nginx service is not running"
    exit 1
fi

if ! curl -f http://localhost > /dev/null 2>&1; then
    echo "Nginx is not responding"
    exit 1
fi

echo "Nginx is healthy"
EOF

sudo chmod +x /usr/local/bin/nginx-health-check.sh
```

### Log Rotation
```bash
# Check logrotate configuration
cat /etc/logrotate.d/nginx

# Manual log rotation
sudo logrotate -f /etc/logrotate.d/nginx
```

### Automated Monitoring
```bash
# Setup simple monitoring with cron
echo "*/5 * * * * /usr/local/bin/nginx-health-check.sh || systemctl restart nginx" | sudo crontab -
```

## Best Practices for Avoiding Issues

### Configuration Management
- Always test configuration before reloading
- Keep backups of working configurations
- Use version control for configuration files
- Document all changes

### Security Practices
- Regularly update Nginx
- Monitor security advisories
- Use strong SSL configurations
- Implement proper access controls

### Performance Monitoring
- Set up proper monitoring and alerting
- Regular log analysis
- Monitor resource usage
- Plan for capacity growth

---
