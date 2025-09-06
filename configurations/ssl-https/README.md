# SSL/HTTPS Configuration

This folder contains everything you need to add SSL certificates to your website.

## What's in this folder

- `ssl-basic.conf` - Ready-to-use SSL configuration
- `letsencrypt-setup.md` - Step-by-step SSL setup guide

## Quick Start

### 1. Get a free SSL certificate
```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d yourdomain.com
```

### 2. Or use our template
```bash
# Copy our SSL template
sudo cp ssl-basic.conf /etc/nginx/sites-available/mysite-ssl

# Edit the domain name
sudo nano /etc/nginx/sites-available/mysite-ssl
# Change "example.com" to your domain

# Enable the site
sudo ln -s /etc/nginx/sites-available/mysite-ssl /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## What you get
* HTTPS encryption
* A+ security rating
* Automatic HTTP to HTTPS redirect
* Security headers to protect users
* Fast loading with HTTP/2

## Test your SSL
Visit: https://www.ssllabs.com/ssltest/

Enter your domain to check your SSL rating.
