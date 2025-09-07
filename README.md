# Nginx

A comprehensive, production-ready guide to Nginx configuration and deployment for DevOps and Cloud Engineering workflows. From basic setup to advanced microservices architecture.

## What's Included

**Installation & Setup**
- AWS EC2 deployment guide with security groups and SSL
- Ubuntu/Debian installation procedures  
- Automated installation script for multiple platforms

**Core Configurations**
- Production-ready nginx.conf templates
- SSL/HTTPS setup with Let's Encrypt automation
- Reverse proxy configurations for Node.js applications
- Load balancing with health checks and failover
- Security hardening and performance optimization

**Automation & Scripts**
- Automated nginx installation (`install-nginx.sh`)
- SSL certificate setup automation (`ssl-setup.sh`)
- Configuration backup system (`backup-config.sh`)
- Health monitoring and alerting (`monitoring.sh`)

**Production Examples**
- Complete static website hosting example
- Microservices API Gateway with Docker testing
- Production security configurations
- Real-world load balancing scenarios

**Troubleshooting & Debugging**
- Common issues and solutions
- Performance optimization techniques
- Advanced debugging methodologies
- Production monitoring strategies

## Quick Start Paths

### Path 1: Basic Web Hosting
```bash
# 1. Install nginx on AWS EC2
# Follow: installation/aws-ec2.md

# 2. Use basic configuration  
sudo cp configurations/basic/nginx.conf /etc/nginx/nginx.conf

# 3. Set up SSL
sudo ./scripts/ssl-setup.sh

# 4. Deploy static site
# Follow: examples/static-website/README.md
```

### Path 2: Reverse Proxy Setup
```bash
# 1. Install nginx
sudo ./scripts/install-nginx.sh

# 2. Configure reverse proxy
sudo cp configurations/reverse-proxy/nodejs-app.conf /etc/nginx/sites-available/myapp

# 3. Enable and test
sudo ln -s /etc/nginx/sites-available/myapp /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

### Path 3: Production Deployment
```bash
# 1. Use production configuration
sudo cp configurations/production/production.conf /etc/nginx/sites-available/production

# 2. Set up monitoring
sudo cp scripts/monitoring.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/monitoring.sh

# 3. Configure backups
sudo cp scripts/backup-config.sh /usr/local/bin/
# Add to crontab: 0 2 * * * /usr/local/bin/backup-config.sh
```

### Path 4: Microservices Architecture
```bash
# 1. Test with Docker
cd examples/microservices/
docker-compose up -d

# 2. Production deployment
sudo cp examples/microservices/nginx.conf /etc/nginx/sites-available/api-gateway
# Edit upstream server IPs and enable
```

## Key Features for DevOps

### Security First
- A+ SSL configuration with modern TLS
- Comprehensive security headers
- Rate limiting and DDoS protection
- Access control and authentication
- Security scanning and hardening

### High Availability
- Multi-server load balancing
- Health checks and automatic failover
- Zero-downtime deployments
- Backup and disaster recovery
- Connection pooling and optimization

### Production Ready
- Detailed logging and monitoring
- Performance optimization
- Resource limit management
- Error handling and custom pages
- Scalability planning

### DevOps Integration
- Infrastructure as Code ready
- CI/CD pipeline compatible
- Container deployment examples
- Monitoring and alerting setup
- Automated backup procedures

## Directory Structure

```
nginx-devops/
├── README.md                          # This file
├── installation/                      # Platform-specific guides
│   ├── aws-ec2.md                     # AWS EC2 setup guide
│   ├── ubuntu-debian.md               # Ubuntu installation
│   └── centos-rhel.md                 # CentOS/RHEL setup
├── configurations/                    # Production configs
│   ├── basic/                         # Foundation templates
│   ├── ssl-https/                     # SSL/TLS setup
│   ├── reverse-proxy/                 # Application proxying
│   ├── load-balancing/                # High availability
│   └── production/                    # Security & performance
├── scripts/                           # Automation tools
│   ├── install-nginx.sh               # Automated installation
│   ├── ssl-setup.sh                   # SSL automation
│   ├── backup-config.sh               # Backup system
│   └── monitoring.sh                  # Health monitoring
├── examples/                          # Working examples
│   ├── static-website/                # Static hosting
│   └── microservices/                 # API Gateway
└── troubleshooting/                   # Debug guides
    ├── README.md                      # Common issues
    ├── performance-issues.md          # Performance tuning
    └── debugging.md                   # Advanced debugging
```

## Use Cases

### Small to Medium Websites
- Static website hosting with CDN integration
- WordPress and CMS reverse proxy
- SSL certificate management
- Basic security and performance optimization

### Enterprise Applications
- Microservices API Gateway
- Multi-tier application architecture
- Load balancing across data centers
- Advanced security and compliance

### Cloud Native Deployments
- Kubernetes ingress controller
- Docker container load balancing
- Auto-scaling integration
- Multi-cloud deployments

### High Traffic Applications
- Advanced caching strategies
- Geographic load balancing
- DDoS protection and rate limiting
- Performance monitoring and optimization

## Testing Your Setup

### Basic Functionality
```bash
# Test nginx installation
curl -I http://localhost

# Verify SSL setup
curl -I https://yourdomain.com

# Check health monitoring
sudo /usr/local/bin/monitoring.sh --report
```

### Load Testing
```bash
# Install testing tools
sudo apt install apache2-utils

# Basic load test
ab -n 1000 -c 10 http://yourdomain.com/

# Monitor during test
watch 'curl -s http://localhost/nginx_status'
```

### Security Validation
```bash
# SSL rating (should be A+)
# Visit: https://www.ssllabs.com/ssltest/

# Security headers (should be A+)  
# Visit: https://securityheaders.com/

# Configuration test
sudo nginx -t
```

## Production Checklist

### Before Going Live:
- [ ] SSL certificates installed and auto-renewal configured
- [ ] Security headers implemented and tested
- [ ] Rate limiting configured for your traffic patterns
- [ ] Monitoring and alerting set up
- [ ] Log rotation and backup procedures implemented
- [ ] Load testing completed successfully
- [ ] Security scan passed
- [ ] Documentation updated for your specific setup
- [ ] Team trained on operational procedures
- [ ] Rollback procedures tested

## Contributing

This repository represents production-tested configurations used in real DevOps environments. Contributions should:

- Include production use case justification
- Provide complete, working examples
- Follow security best practices
- Include appropriate documentation

## Support and Resources

### Official Documentation
- [Nginx Official Docs](https://nginx.org/en/docs/)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)

### Community Resources
- [Nginx Community Forum](https://forum.nginx.org/)
- [DevOps Stack Overflow](https://stackoverflow.com/questions/tagged/nginx+devops)

### Professional Services
For enterprise deployments, consider professional nginx consulting and support services.

## Repository Statistics

- **Total Files**: 25+ configuration files and guides
- **Lines of Code**: 3000+ lines of production-ready configurations
- **Documentation**: Comprehensive guides for all skill levels
- **Examples**: Working examples for immediate deployment
- **Scripts**: Full automation for installation and maintenance

**Perfect for**: DevOps Engineers, Cloud Architects, Site Reliability Engineers, System Administrators, and Development Teams deploying production web applications.

---

## Automation Scripts

Production-ready scripts for nginx deployment and maintenance.

### Available Scripts

#### install-nginx.sh
**Purpose**: Automated nginx installation across multiple platforms

```bash
sudo ./install-nginx.sh
```

Features:
- Detects OS automatically (Ubuntu, CentOS, etc.)
- Installs nginx and certbot
- Configures firewall
- Sets up basic configuration
- Starts and enables service

#### ssl-setup.sh
**Purpose**: Automated SSL certificate setup with Let's Encrypt

```bash
sudo ./ssl-setup.sh
```

Features:
- Interactive domain configuration
- Automatic certificate generation
- Sets up auto-renewal
- Tests SSL configuration
- Provides security recommendations

#### backup-config.sh
**Purpose**: Complete nginx configuration and content backup

```bash
sudo ./backup-config.sh
```

Features:
- Backs up nginx configurations
- Backs up website content
- Backs up SSL certificates
- Creates restore instructions
- Manages backup retention

#### monitoring.sh
**Purpose**: Health monitoring and alerting

```bash
sudo ./monitoring.sh --report
./monitoring.sh --quiet     # For cron jobs
```

Features:
- Checks service status
- Validates configuration
- Monitors performance
- Tests connectivity
- Generates health reports

### Setup Instructions

#### Make scripts executable
```bash
chmod +x scripts/*.sh
```

#### Install to system path (optional)
```bash
sudo cp scripts/*.sh /usr/local/bin/
```

#### Set up monitoring cron job
```bash
# Add to crontab
sudo crontab -e

# Check every 5 minutes
*/5 * * * * /usr/local/bin/monitoring.sh --quiet

# Daily backup at 2 AM
0 2 * * * /usr/local/bin/backup-config.sh
```

### Usage Examples

#### Quick nginx setup on new server
```bash
# 1. Install nginx
sudo ./scripts/install-nginx.sh

# 2. Set up SSL for domain
sudo ./scripts/ssl-setup.sh

# 3. Set up monitoring
sudo cp scripts/monitoring.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/monitoring.sh
```

#### Production maintenance routine
```bash
# Daily health check
sudo /usr/local/bin/monitoring.sh --report

# Weekly backup
sudo /usr/local/bin/backup-config.sh

# Monthly SSL renewal test
sudo certbot renew --dry-run
```

All scripts include comprehensive error handling, logging, and safety checks for production use.

####  Happy Learning! 
