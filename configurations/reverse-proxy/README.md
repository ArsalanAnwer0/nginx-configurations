# Reverse Proxy Configuration

## Files

- `nodejs-app.conf` - Complete Node.js reverse proxy setup

## Usage

```bash
# Copy configuration
sudo cp nodejs-app.conf /etc/nginx/sites-available/myapp

# Update server_name and ssl paths
sudo nano /etc/nginx/sites-available/myapp

# Enable site
sudo ln -s /etc/nginx/sites-available/myapp /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
