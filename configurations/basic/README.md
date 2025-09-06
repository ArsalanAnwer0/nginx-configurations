# Basic Nginx Configuration

## Files in this directory

- `nginx.conf` - Production-ready main configuration
- `default-site.conf` - Basic server block template

## Usage

### Replace main configuration
```bash
sudo cp nginx.conf /etc/nginx/nginx.conf
sudo nginx -t
sudo systemctl reload nginx
```

### Add new site
```bash
sudo cp default-site.conf /etc/nginx/sites-available/mysite
sudo ln -s /etc/nginx/sites-available/mysite /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## Configuration Structure

### Main Configuration (nginx.conf)
The main configuration file controls global settings that affect the entire Nginx server:

```nginx
# Global settings
user www-data;
worker_processes auto;
pid /run/nginx.pid;

# Events block - connection processing
events {
    worker_connections 1024;
    use epoll;
}

# HTTP block - web server settings
http {
    # Basic settings
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    
    # MIME types
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    # Logging
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;
    
    # Gzip compression
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
    
    # Include site configurations
    include /etc/nginx/sites-enabled/*;
}
```

### Server Block Template (default-site.conf)
Server blocks define individual websites or applications:

```nginx
server {
    # Listen on port 80
    listen 80;
    listen [::]:80;
    
    # Server name (domain)
    server_name example.com www.example.com;
    
    # Document root
    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;
    
    # Main location block
    location / {
        try_files $uri $uri/ =404;
    }
    
    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    
    # Access and error logs
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;
}
```

## Common Configuration Patterns

### Static Website
```nginx
server {
    listen 80;
    server_name mysite.com;
    root /var/www/mysite;
    index index.html;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    # Cache static assets
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

### Reverse Proxy
```nginx
server {
    listen 80;
    server_name api.mysite.com;
    
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

### HTTPS with SSL
```nginx
server {
    listen 443 ssl http2;
    server_name secure.mysite.com;
    
    # SSL configuration
    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    ssl_prefer_server_ciphers off;
    
    # HSTS header
    add_header Strict-Transport-Security "max-age=63072000" always;
    
    root /var/www/secure-site;
    index index.html;
    
    location / {
        try_files $uri $uri/ =404;
    }
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name secure.mysite.com;
    return 301 https://$server_name$request_uri;
}
```

## Configuration Management

### Testing Configuration
```bash
# Test syntax
sudo nginx -t

# Test and show configuration
sudo nginx -T

# Check configuration files
sudo nginx -t -c /etc/nginx/nginx.conf
```

### Reloading Configuration
```bash
# Graceful reload (recommended)
sudo systemctl reload nginx

# Alternative reload methods
sudo nginx -s reload
sudo service nginx reload
```

### Managing Sites
```bash
# Enable a site
sudo ln -s /etc/nginx/sites-available/mysite /etc/nginx/sites-enabled/

# Disable a site
sudo rm /etc/nginx/sites-enabled/mysite

# List available sites
ls -la /etc/nginx/sites-available/

# List enabled sites
ls -la /etc/nginx/sites-enabled/
```

## Performance Optimization

### Worker Configuration
```nginx
# Automatically set based on CPU cores
worker_processes auto;

# Increase worker connections
events {
    worker_connections 2048;
    use epoll;
    multi_accept on;
}
```

### Buffer Settings
```nginx
http {
    # Client request buffers
    client_body_buffer_size 128k;
    client_max_body_size 10m;
    client_header_buffer_size 1k;
    large_client_header_buffers 4 4k;
    
    # Proxy buffers
    proxy_buffering on;
    proxy_buffer_size 128k;
    proxy_buffers 4 256k;
    proxy_busy_buffers_size 256k;
}
```

### Caching Configuration
```nginx
# Proxy cache path
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=STATIC:10m inactive=7d use_temp_path=off;

server {
    location / {
        proxy_cache STATIC;
        proxy_cache_valid 200 1d;
        proxy_cache_valid 404 1m;
        proxy_cache_use_stale error timeout invalid_header updating;
        proxy_pass http://backend;
        
        # Cache bypass for dynamic content
        proxy_cache_bypass $http_cache_control;
        add_header X-Proxy-Cache $upstream_cache_status;
    }
}
```

## Security Configuration

### Basic Security Headers
```nginx
# Security headers
add_header X-Frame-Options DENY;
add_header X-Content-Type-Options nosniff;
add_header X-XSS-Protection "1; mode=block";
add_header Referrer-Policy "strict-origin-when-cross-origin";
add_header Content-Security-Policy "default-src 'self'; script-src 'self'";

# Hide server version
server_tokens off;
```

### Rate Limiting
```nginx
# Define rate limit zones
http {
    limit_req_zone $binary_remote_addr zone=login:10m rate=1r/m;
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
}

server {
    # Apply rate limiting
    location /login {
        limit_req zone=login burst=3 nodelay;
        # ... other directives
    }
    
    location /api/ {
        limit_req zone=api burst=20 nodelay;
        # ... other directives
    }
}
```

### Access Control
```nginx
# IP-based access control
location /admin {
    allow 192.168.1.0/24;
    allow 10.0.0.0/8;
    deny all;
    
    # ... other directives
}

# Password protection
location /private {
    auth_basic "Restricted Area";
    auth_basic_user_file /etc/nginx/.htpasswd;
    
    # ... other directives
}
```

## Logging Configuration

### Custom Log Formats
```nginx
http {
    # Custom log format
    log_format detailed '$remote_addr - $remote_user [$time_local] '
                       '"$request" $status $bytes_sent '
                       '"$http_referer" "$http_user_agent" '
                       '$request_time $upstream_response_time';
    
    # JSON log format
    log_format json_combined escape=json
        '{'
            '"time_local":"$time_local",'
            '"remote_addr":"$remote_addr",'
            '"remote_user":"$remote_user",'
            '"request":"$request",'
            '"status": "$status",'
            '"body_bytes_sent":"$body_bytes_sent",'
            '"request_time":"$request_time",'
            '"http_referrer":"$http_referer",'
            '"http_user_agent":"$http_user_agent"'
        '}';
}
```

### Log Management
```bash
# View real-time logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# Rotate logs manually
sudo nginx -s reopen

# Check log sizes
du -sh /var/log/nginx/
```

## Troubleshooting

### Common Configuration Errors
```bash
# Check for syntax errors
sudo nginx -t

# Common issues and solutions:
# 1. Missing semicolon at end of directive
# 2. Unmatched braces { }
# 3. Invalid directive name or context
# 4. File permissions on configuration files
```

### Testing Configuration Changes
```bash
# Test configuration before applying
sudo nginx -t

# If test passes, reload
sudo nginx -t && sudo systemctl reload nginx

# If test fails, check error details
sudo nginx -t 2>&1 | grep -i error
```

### Debugging
```nginx
# Enable debug logging temporarily
error_log /var/log/nginx/debug.log debug;

# Check which configuration file is being used
nginx -V 2>&1 | grep -o '\-\-conf-path=\S*'
```

## Best Practices

### Configuration Organization
- Keep main `nginx.conf` clean and modular
- Use separate files for different sites in `sites-available/`
- Create reusable configuration snippets in `conf.d/`
- Comment your configuration files thoroughly

### Security Practices
- Always test configuration changes before applying
- Use strong SSL configurations
- Implement appropriate rate limiting
- Hide server version information
- Regularly update Nginx

### Performance Guidelines
- Use appropriate worker process and connection settings
- Enable gzip compression for text content
- Implement caching where appropriate
- Monitor performance metrics regularly

---


