# Load Balancing Configuration

Load balancing distributes traffic across multiple servers for better performance and reliability.

## What's in this folder

- `basic-lb.conf` - Simple load balancer setup

## How Load Balancing Works

```
User Request → Load Balancer → Server 1
                            → Server 2
                            → Server 3
```

If Server 1 goes down, traffic automatically goes to Server 2 and 3.

## Quick Setup

### 1. Update server IPs
```bash
# Copy the configuration
sudo cp basic-lb.conf /etc/nginx/sites-available/loadbalancer

# Edit the file and change the server IPs
sudo nano /etc/nginx/sites-available/loadbalancer

# Change these lines to your actual server IPs:
# server 10.0.1.10:80 weight=1;  ← Change this IP
# server 10.0.1.11:80 weight=1;  ← Change this IP
# server 10.0.1.12:80 weight=1;  ← Change this IP
```

### 2. Enable the load balancer
```bash
sudo ln -s /etc/nginx/sites-available/loadbalancer /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## Load Balancing Methods

### Round Robin (Default)
Traffic goes: Server1 → Server2 → Server3 → Server1...

### Least Connections (Recommended)
```nginx
upstream web_servers {
    least_conn;  # Sends traffic to server with fewest connections
    server 10.0.1.10:80;
    server 10.0.1.11:80;
}
```

### Weighted Distribution
```nginx
upstream web_servers {
    server 10.0.1.10:80 weight=3;  # Gets 3x more traffic
    server 10.0.1.11:80 weight=1;  # Gets 1x traffic
}
```

## Testing

### Check if it's working
```bash
# Test the load balancer
curl -I http://lb.example.com

# Check status
curl http://lb.example.com/status
```

### Load testing
```bash
# Install testing tool
sudo apt install apache2-utils

# Send 100 requests to test distribution
ab -n 100 -c 10 http://lb.example.com/
```

## Benefits

* **High Availability**: If one server fails, others continue working
* **Better Performance**: Traffic is distributed across multiple servers
* **Scalability**: Easy to add more servers
* **Health Monitoring**: Automatically detects failed servers
