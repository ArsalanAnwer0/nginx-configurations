# Nginx for DevOps and Cloud Engineers

A practical guide to Nginx configuration and deployment for DevOps and Cloud Engineering workflows.

## Current Status

-  AWS EC2 Installation Guide
-  Basic Production Configuration
-  Reverse Proxy Setup
-  Installation Automation Script
-  Static Website Example
-  Troubleshooting Guide
-  SSL/HTTPS Configuration (Coming Soon)
-  Load Balancing Setup (Coming Soon)
-  Microservices Example (Coming Soon)

## Quick Start

1. **Install Nginx on AWS EC2**: Follow [AWS EC2 Setup](installation/aws-ec2.md)
2. **Use Basic Configuration**: Check [Basic Config](configurations/basic/)
3. **Set up Reverse Proxy**: See [Reverse Proxy](configurations/reverse-proxy/)
4. **Automate Installation**: Use [install script](scripts/install-nginx.sh)

## What's Working Now

- Complete AWS EC2 installation guide
- Production-ready nginx.conf template
- Node.js reverse proxy configuration
- Automated installation script
- Static website example
- Basic troubleshooting guide

## Next Steps

- SSL/HTTPS with Let's Encrypt
- Load balancing configuration
- Microservices API gateway example
- Container deployment examples

## Quick Test

```bash
# Clone and test
git clone your-repo-url
cd nginx-devops

# Run installation (on Ubuntu/EC2)
sudo ./scripts/install-nginx.sh

# Deploy static example
sudo cp examples/static-website/* /var/www/html/
