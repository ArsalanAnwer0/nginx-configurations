# Static Website Example

## Quick Setup

```bash
# Copy files to web directory
sudo mkdir -p /var/www/static-website
sudo cp index.html /var/www/static-website/
sudo chown -R www-data:www-data /var/www/static-website

# Configure Nginx
sudo cp nginx.conf /etc/nginx/sites-available/static-website
sudo ln -s /etc/nginx/sites-available/static-website /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
