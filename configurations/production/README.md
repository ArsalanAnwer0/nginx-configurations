# Production Configuration

Production-ready Nginx configurations with security hardening and performance optimizations.

## What's in this folder

- `production.conf` - Complete production server configuration
- `security-headers.conf` - Reusable security headers

## Quick Setup

### 1. Use the complete production config
```bash
# Copy production configuration
sudo cp production.conf /etc/nginx/sites-available/mysite-production

# Edit domain name and paths
sudo nano /etc/nginx/sites-available/mysite-production
# Change "production.example.com" to your domain
# Change "/var/www/production" to your web directory

# Enable the site
sudo ln -s /etc/nginx/sites-available/mysite-production /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 2. Or add security headers to existing site
```bash
# Copy security headers file
sudo cp security-headers.conf /etc/nginx/

# Add to your existing server block
sudo nano /etc/nginx/sites-available/yoursite

# Add this line inside your server block:
# include /etc/nginx/security-headers.conf;

sudo nginx -t
sudo systemctl reload nginx
```

## Production Features

### Security
* **A+ SSL rating** configuration
* **Security headers** to prevent attacks
* **Rate limiting** to prevent abuse
* **File access blocking** for sensitive files
* **CORS protection** for APIs
* **XSS and clickjacking protection**

### Performance
* **HTTP/2** for faster loading
* **Aggressive caching** for static files
* **Gzip compression** enabled
* **Connection pooling** optimized
* **Buffer sizes** tuned for production

### Monitoring
* **Detailed logging** for debugging
* **Health check endpoint** for monitoring
* **Error pages** for better user experience
* **Rate limit tracking** for security

## Security Headers Explained

```nginx
# Prevents clickjacking attacks
X-Frame-Options: DENY

# Stops MIME type confusion attacks
X-Content-Type-Options: nosniff

# Enables browser XSS protection
X-XSS-Protection: 1; mode=block

# Forces HTTPS for 1 year
Strict-Transport-Security: max-age=31536000

# Controls what content can load
Content-Security-Policy: default-src 'self'
```

## Rate Limiting
* **Login endpoints**: 1 request per minute (prevents brute force)
* **API endpoints**: 100 requests per second
* **General traffic**: 200 requests per second
* **Connection limit**: 20 connections per IP

## Testing Your Security

### SSL Test
Visit: https://www.ssllabs.com/ssltest/

Should show **A+** rating

### Security Headers Test
Visit: https://securityheaders.com/

Should show **A+** rating

### Performance Test
```bash
# Test page speed
curl -w "@curl-format.txt" -o /dev/null -s https://yourdomain.com

# Create curl-format.txt:
echo "Time: %{time_total}s\nSize: %{size_download} bytes\n" > curl-format.txt
```

## Troubleshooting

### If site doesn't load
```bash
# Check nginx configuration
sudo nginx -t

# Check error logs
sudo tail -f /var/log/nginx/production_error.log

# Check if SSL certificates exist
sudo ls -la /etc/letsencrypt/live/yourdomain.com/
```

### If getting too many rate limit errors
```bash
# Edit rate limits in production.conf
# Increase these values:
# limit_req zone=general burst=300 nodelay;  ← Increase 300 to 500
```

## Before Going Live
* SSL certificate installed and working
* Domain pointing to your server
* Rate limits tested and appropriate
* Error pages created and tested
* Backup procedures in place
* Monitoring setup and working
* Security headers verified
