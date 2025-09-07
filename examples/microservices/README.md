# Microservices API Gateway Example

This example shows how to use Nginx as an API Gateway for microservices architecture.

## Architecture

```
Client Request → Nginx (API Gateway) → Microservice 1 (Users)
                                    → Microservice 2 (Orders)
                                    → Microservice 3 (Payments)
```

## What's included

- `nginx.conf` - Complete API Gateway configuration
- `docker-compose.yml` - Test setup with mock microservices
- Complete routing, load balancing, and security

## Quick Test with Docker

### 1. Start the test environment
```bash
# Start all services
docker-compose up -d

# Check if services are running
docker-compose ps
```

### 2. Test the API Gateway
```bash
# Test user service
curl http://localhost/api/users

# Test order service  
curl http://localhost/api/orders

# Test payment service
curl http://localhost/api/payments

# Check health endpoints
curl http://localhost/health/users
curl http://localhost/health/orders
curl http://localhost/health/payments
```

### 3. Stop the test environment
```bash
docker-compose down
```

## Production Setup

### 1. Copy the configuration
```bash
# Copy nginx configuration
sudo cp nginx.conf /etc/nginx/sites-available/api-gateway

# Edit the upstream server IPs
sudo nano /etc/nginx/sites-available/api-gateway
# Change the server IPs to your actual microservice servers
```

### 2. Enable the API Gateway
```bash
sudo ln -s /etc/nginx/sites-available/api-gateway /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## Features

### Routing
* `/api/users/*` → User microservice
* `/api/orders/*` → Order microservice
* `/api/payments/*` → Payment microservice

### Security
* Rate limiting per endpoint
* CORS headers for web apps
* Security headers
* SSL/HTTPS support

### Monitoring
* Health checks for each service
* Detailed logging with service information
* Load balancer status endpoint

### Load Balancing
* Automatic failover between service instances
* Health-aware routing
* Connection pooling

## Customization

### Add a new microservice
```nginx
# 1. Add upstream definition
upstream new_service {
    server 10.0.1.20:3000;
    server 10.0.1.21:3000;
}

# 2. Add routing
location /api/newservice/ {
    proxy_pass http://new_service;
    include /etc/nginx/proxy_params;
}

# 3. Add health check
location /health/newservice {
    proxy_pass http://new_service/health;
    access_log off;
}
```

### Modify rate limits
```nginx
# Change rate limiting
limit_req_zone $binary_remote_addr zone=api:10m rate=200r/s;  # Increase from 100r/s
limit_req zone=api burst=400 nodelay;  # Increase burst
```

## Real-world Usage

This configuration is suitable for:
* Kubernetes ingress controller
* Docker Swarm load balancing
* Cloud microservices (AWS, GCP, Azure)
* Container orchestration platforms
