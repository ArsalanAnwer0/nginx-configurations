# Let's Encrypt SSL Certificate Setup

## Install Certbot

### Ubuntu/Debian
```bash
sudo apt update
sudo apt install certbot python3-certbot-nginx -y
```

### CentOS/RHEL
```bash
sudo yum install epel-release -y
sudo yum install certbot python3-certbot-nginx -y
```

## Get SSL Certificate

### Automatic Setup (Easiest)
```bash
# Replace yourdomain.com with your actual domain
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

**What happens:**
1. Certbot asks for your email
2. You agree to terms
3. It automatically configures SSL
4. Your site is now HTTPS

## Test Your SSL
```bash
# Check if it worked
curl -I https://yourdomain.com

# Should show: HTTP/2 200
```

## Auto-Renewal
```bash
# Test auto-renewal (won't actually renew)
sudo certbot renew --dry-run

# Should show: "Congratulations, all renewals succeeded"
```

## Troubleshooting

### If certificate fails:
```bash
# Make sure domain points to your server
dig yourdomain.com

# Make sure port 80 is open
curl -I http://yourdomain.com
```

### If renewal fails:
```bash
# Check certbot status
sudo systemctl status certbot.timer

# Manual renewal
sudo certbot renew
```
