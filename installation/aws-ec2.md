# AWS EC2 Nginx Installation

## Prerequisites

- AWS account with EC2 access
- SSH key pair configured
- Security groups allowing HTTP (80) and HTTPS (443)

## Launch EC2 Instance

### Recommended Configuration
```bash
AMI: Ubuntu 22.04 LTS
Instance Type: t3.medium (minimum for production)
Storage: 20GB gp3 SSD
Security Group: HTTP, HTTPS, SSH access
```

### Security Group Rules
```bash
Type: SSH, Protocol: TCP, Port: 22, Source: Your IP
Type: HTTP, Protocol: TCP, Port: 80, Source: 0.0.0.0/0
Type: HTTPS, Protocol: TCP, Port: 443, Source: 0.0.0.0/0
```

## Installation Steps

### 1. Connect and Update
```bash
ssh -i your-key.pem ubuntu@your-ec2-public-ip
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget unzip htop
```

### 2. Install Nginx
```bash
sudo apt install nginx -y
nginx -v
sudo systemctl start nginx
sudo systemctl enable nginx
```

### 3. Configure Firewall
```bash
sudo ufw allow 'Nginx Full'
sudo ufw allow OpenSSH
sudo ufw --force enable
```

### 4. Test Installation
```bash
curl http://localhost
curl http://your-ec2-public-ip
```

## Basic Configuration

### Directory Structure
```bash
/etc/nginx/nginx.conf              # Main configuration
/etc/nginx/sites-available/        # Available sites
/etc/nginx/sites-enabled/          # Active sites
/var/www/html/                     # Default web root
/var/log/nginx/                    # Log files
```

### Create First Site
```bash
sudo mkdir -p /var/www/mysite
sudo chown -R $USER:$USER /var/www/mysite

cat > /var/www/mysite/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>Nginx Test</title></head>
<body>
    <h1>Nginx is working on AWS EC2</h1>
    <p>Server: AWS EC2 Instance</p>
</body>
</html>
EOF
```

### Configure Server Block
```bash
sudo nano /etc/nginx/sites-available/mysite
```

Add this configuration:
```nginx
server {
    listen 80;
    server_name your-domain.com;
    root /var/www/mysite;
    index index.html;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
}
```

### Enable Site
```bash
sudo ln -s /etc/nginx/sites-available/mysite /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## SSL Setup with Let's Encrypt

```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d your-domain.com
sudo certbot renew --dry-run
```

## Advanced Configuration

### Performance Optimization
```nginx
# Add to /etc/nginx/nginx.conf
worker_processes auto;
worker_connections 1024;

# Enable gzip compression
gzip on;
gzip_vary on;
gzip_min_length 1024;
gzip_types
    text/plain
    text/css
    text/xml
    text/javascript
    application/javascript
    application/xml+rss
    application/json;
```

### Security Headers
```nginx
# Add to server block
add_header X-Frame-Options DENY;
add_header X-Content-Type-Options nosniff;
add_header X-XSS-Protection "1; mode=block";
add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";
add_header Referrer-Policy "strict-origin-when-cross-origin";
```

### Reverse Proxy Configuration
```nginx
server {
    listen 80;
    server_name api.example.com;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

## Monitoring and Logging

### Check Nginx Status
```bash
sudo systemctl status nginx
sudo nginx -t
sudo nginx -s reload
```

### View Logs
```bash
# Access logs
sudo tail -f /var/log/nginx/access.log

# Error logs
sudo tail -f /var/log/nginx/error.log

# Check specific site logs
sudo tail -f /var/log/nginx/mysite.access.log
```

### Log Rotation
```bash
# Nginx log rotation is handled by logrotate
sudo cat /etc/logrotate.d/nginx

# Manual log rotation
sudo nginx -s reopen
```

## Backup and Maintenance

### Backup Configuration
```bash
# Backup nginx configuration
sudo tar -czf nginx-backup-$(date +%Y%m%d).tar.gz /etc/nginx/

# Backup website files
sudo tar -czf website-backup-$(date +%Y%m%d).tar.gz /var/www/
```

### Regular Maintenance
```bash
# Update system and nginx
sudo apt update && sudo apt upgrade -y

# Check disk space
df -h

# Monitor resource usage
htop
sudo netstat -tulpn | grep :80
```

## Troubleshooting

### Common Issues

#### Nginx Won't Start
```bash
# Check configuration syntax
sudo nginx -t

# Check if port 80 is already in use
sudo netstat -tulpn | grep :80

# Check nginx error logs
sudo journalctl -u nginx.service
```

#### Permission Denied Errors
```bash
# Check file permissions
ls -la /var/www/mysite/

# Fix ownership
sudo chown -R www-data:www-data /var/www/mysite/

# Check SELinux (if enabled)
sudo sestatus
```

#### SSL Certificate Issues
```bash
# Check certificate status
sudo certbot certificates

# Test certificate renewal
sudo certbot renew --dry-run

# Manual certificate renewal
sudo certbot renew
```

## Security Best Practices

### Hide Nginx Version
```nginx
# Add to http block in nginx.conf
server_tokens off;
```

### Rate Limiting
```nginx
# Add to http block
limit_req_zone $binary_remote_addr zone=one:10m rate=1r/s;

# Add to server block
location / {
    limit_req zone=one burst=5;
    try_files $uri $uri/ =404;
}
```

### Block Malicious IPs
```nginx
# Create blocklist
sudo nano /etc/nginx/conf.d/blocklist.conf

# Add IPs to block
deny 192.168.1.100;
deny 10.0.0.0/8;
```

## Performance Monitoring

### Server Metrics
```bash
# CPU and memory usage
top
htop

# Network connections
ss -tulpn

# Disk I/O
iostat -x 1

# Nginx status (requires stub_status module)
curl http://localhost/nginx_status
```

### Application Performance
```bash
# Test website speed
curl -w "@curl-format.txt" -o /dev/null -s http://your-domain.com

# Create curl timing format file
cat > curl-format.txt << 'EOF'
     time_namelookup:  %{time_namelookup}\n
        time_connect:  %{time_connect}\n
     time_appconnect:  %{time_appconnect}\n
    time_pretransfer:  %{time_pretransfer}\n
       time_redirect:  %{time_redirect}\n
  time_starttransfer:  %{time_starttransfer}\n
                     ----------\n
          time_total:  %{time_total}\n
EOF
```

## Scaling Considerations

### Load Balancing
```nginx
upstream backend {
    server 10.0.1.10:3000;
    server 10.0.1.11:3000;
    server 10.0.1.12:3000;
}

server {
    location / {
        proxy_pass http://backend;
    }
}
```

### Caching
```nginx
# Proxy caching
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=STATIC:10m inactive=7d use_temp_path=off;

location / {
    proxy_cache STATIC;
    proxy_cache_valid 200 1d;
    proxy_cache_use_stale error timeout invalid_header updating;
    proxy_pass http://backend;
}
```

## Cost Optimization

### Instance Right-Sizing
- Monitor CPU and memory usage
- Use CloudWatch metrics
- Consider spot instances for non-critical workloads
- Implement auto-scaling groups

### Storage Optimization
```bash
# Clean up logs
sudo find /var/log -name "*.log" -type f -mtime +30 -delete

# Compress old files
sudo gzip /var/log/nginx/*.log.1

# Monitor disk usage
du -sh /var/log/nginx/
```

## Next Steps

1. **SSL/HTTPS Setup** - Implement Let's Encrypt certificates
2. **Reverse Proxy** - Configure proxy for backend applications
3. **Monitoring** - Set up CloudWatch or external monitoring
4. **Auto Scaling** - Implement AWS Auto Scaling Groups
5. **CDN** - Consider CloudFront for static content delivery

---
