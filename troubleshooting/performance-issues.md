# Performance Troubleshooting Guide

## Common Performance Issues

### Slow Response Times

**Symptoms**: Website loads slowly, timeouts, poor user experience

**Diagnosis**:
```bash
# Test response times
curl -w "@curl-format.txt" -o /dev/null -s http://yoursite.com

# Create curl-format.txt:
echo "Time: %{time_total}s\nDNS: %{time_namelookup}s\nConnect: %{time_connect}s\nTransfer: %{time_starttransfer}s\n" > curl-format.txt

# Check server resources
htop
free -h
iostat -x 1 5
```

**Solutions**:
```nginx
# Optimize worker settings
worker_processes auto;
worker_connections 2048;

# Enable compression
gzip on;
gzip_comp_level 6;
gzip_min_length 1024;

# Optimize buffers
client_body_buffer_size 128k;
proxy_buffer_size 128k;
proxy_buffers 4 256k;
```

### High Memory Usage

**Symptoms**: Server runs out of memory, processes killed, swap usage

**Diagnosis**:
```bash
# Check memory usage
free -h
ps aux --sort=-%mem | head -10

# Check nginx memory usage
ps aux | grep nginx | awk '{sum+=$6} END {print "Nginx memory: " sum/1024 "MB"}'

# Check for memory leaks
valgrind --tool=memcheck --leak-check=full nginx -t
```

**Solutions**:
```nginx
# Reduce worker connections if memory is limited
worker_connections 1024;

# Optimize buffer sizes
client_max_body_size 10m;
client_body_buffer_size 16k;
large_client_header_buffers 4 8k;

# Disable unnecessary modules
# Remove unused modules during compilation
```

### High CPU Usage

**Symptoms**: Server becomes unresponsive, high load average

**Diagnosis**:
```bash
# Monitor CPU usage
top -p $(pgrep nginx | tr '\n' ',' | sed 's/,$//')
iotop -o

# Check nginx processes
ps aux | grep nginx | wc -l

# Monitor system load
uptime
vmstat 1 5
```

**Solutions**:
```nginx
# Optimize worker processes
worker_processes auto;  # Matches CPU cores

# Use efficient connection handling
events {
    use epoll;  # Linux
    multi_accept on;
}

# Enable efficient file serving
sendfile on;
tcp_nopush on;
tcp_nodelay on;
```

### Connection Issues

**Symptoms**: Connection refused, timeouts, 502 errors

**Diagnosis**:
```bash
# Check connection limits
netstat -an | grep :80 | wc -l
ss -s

# Check file descriptor limits
ulimit -n
lsof | wc -l

# Monitor connections
watch 'netstat -an | grep :80 | head -20'
```

**Solutions**:
```nginx
# Increase connection limits
events {
    worker_connections 4096;
}

# Optimize keepalive
keepalive_timeout 30;
keepalive_requests 100;

# System-level limits
# Add to /etc/security/limits.conf:
# nginx soft nofile 65536
# nginx hard nofile 65536
```

## Performance Optimization Checklist

### Server Level
- [ ] Adequate RAM (minimum 2GB for production)
- [ ] Fast SSD storage
- [ ] Sufficient CPU cores
- [ ] Network bandwidth adequate
- [ ] System limits properly configured

### Nginx Configuration
- [ ] Worker processes set to auto or CPU count
- [ ] Worker connections optimized (1024-4096)
- [ ] Gzip compression enabled
- [ ] Static file caching configured
- [ ] Buffer sizes appropriate for workload
- [ ] Keepalive connections enabled

### Application Level
- [ ] Backend applications optimized
- [ ] Database queries optimized
- [ ] Caching implemented (Redis, Memcached)
- [ ] CDN configured for static assets
- [ ] Code profiling completed

## Benchmarking Tools

### Apache Bench (ab)
```bash
# Install
sudo apt install apache2-utils

# Basic test
ab -n 1000 -c 10 http://yoursite.com/

# Advanced test with cookies
ab -n 1000 -c 10 -C "session=abc123" http://yoursite.com/

# POST request test
ab -n 100 -c 5 -p data.json -T application/json http://yoursite.com/api/
```

### wrk (Modern HTTP benchmarking tool)
```bash
# Install
sudo apt install wrk

# Basic test
wrk -t12 -c400 -d30s http://yoursite.com/

# Custom script test
wrk -t12 -c400 -d30s -s script.lua http://yoursite.com/
```

### Load Testing with Docker
```bash
# Run multiple concurrent tests
docker run --rm -i loadimpact/k6 run - <script.js
```

## Monitoring During Load Tests

### Real-time Monitoring
```bash
# Monitor nginx status
watch 'curl -s http://localhost/nginx_status'

# Monitor system resources
watch 'free -h && echo "---" && iostat -x 1 1'

# Monitor error logs
tail -f /var/log/nginx/error.log
```

### Log Analysis
```bash
# Response time analysis
awk '{print $(NF-1)}' /var/log/nginx/access.log | sort -n | tail -10

# Top slow requests
awk '$NF > 1.0 {print $7, $NF}' /var/log/nginx/access.log | sort -k2 -n

# Request rate per minute
awk '{print $4}' /var/log/nginx/access.log | cut -c 14-20 | sort | uniq -c
```

## Quick Performance Fixes

### Immediate Impact
```nginx
# Enable compression (instant improvement)
gzip on;
gzip_types text/plain text/css application/json application/javascript;

# Static file caching
location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}

# Optimize worker settings
worker_processes auto;
worker_connections 2048;
```

### Medium-term Improvements
- Implement reverse proxy caching
- Add CDN for static assets
- Optimize database queries
- Implement application-level caching

### Long-term Optimization
- Implement microservices architecture
- Add auto-scaling capabilities
- Use containerization (Docker/Kubernetes)
- Implement comprehensive monitoring
