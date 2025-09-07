# Advanced Debugging Techniques

## Enable Debug Logging

### Temporary Debug Mode
```bash
# Enable debug logging for specific server
server {
    error_log /var/log/nginx/debug.log debug;
    # ... rest of config
}

# Or globally
error_log /var/log/nginx/debug.log debug;
```

### Debug Specific Issues
```nginx
# Debug upstream connections
upstream backend {
    server 192.168.1.10:3000;
}

server {
    error_log /var/log/nginx/upstream_debug.log debug;
    
    location / {
        proxy_pass http://backend;
        # Detailed upstream debugging will be logged
    }
}
```

## Network Debugging

### Connection Tracing
```bash
# Trace network connections
netstat -tlnp | grep nginx
ss -tlnp | grep nginx

# Monitor real-time connections
watch 'netstat -an | grep :80'

# Check listening ports
lsof -i :80
lsof -i :443
```

### Packet Capture
```bash
# Capture HTTP traffic
sudo tcpdump -i any port 80 -A

# Capture HTTPS handshake
sudo tcpdump -i any port 443 -X

# Save to file for analysis
sudo tcpdump -i any port 80 -w capture.pcap
```

### DNS Debugging
```bash
# Test DNS resolution
dig example.com
nslookup example.com

# Check DNS response time
dig example.com | grep "Query time"

# Test specific DNS server
dig @8.8.8.8 example.com
```

## Configuration Debugging

### Validate Configuration
```bash
# Test syntax
nginx -t

# Show complete configuration
nginx -T

# Test specific file
nginx -t -c /path/to/nginx.conf

# Check configuration hierarchy
nginx -T | grep -E "(server|location|upstream)" | head -20
```

### Find Configuration Issues
```bash
# Check for duplicate server names
nginx -T | grep server_name | sort | uniq -d

# Find all included files
nginx -T | grep include

# Check which modules are loaded
nginx -V 2>&1 | grep -o with-[a-z_]*
```

## SSL/TLS Debugging

### Certificate Validation
```bash
# Check certificate details
openssl x509 -in /etc/letsencrypt/live/domain.com/cert.pem -text -noout

# Verify certificate chain
openssl verify -CAfile /etc/ssl/certs/ca-certificates.crt /etc/letsencrypt/live/domain.com/cert.pem

# Test SSL handshake
openssl s_client -connect domain.com:443 -servername domain.com
```

### SSL Configuration Testing
```bash
# Test specific SSL version
openssl s_client -connect domain.com:443 -tls1_2
openssl s_client -connect domain.com:443 -tls1_3

# Check cipher suites
nmap --script ssl-enum-ciphers -p 443 domain.com

# Test OCSP stapling
openssl s_client -connect domain.com:443 -status
```

## Performance Debugging

### Request Analysis
```nginx
# Enable request tracing
log_format detailed '$remote_addr - $remote_user [$time_local] '
                   '"$request" $status $body_bytes_sent '
                   '"$http_referer" "$http_user_agent" '
                   'rt=$request_time uct="$upstream_connect_time" '
                   'uht="$upstream_header_time" urt="$upstream_response_time"';

access_log /var/log/nginx/detailed.log detailed;
```

### Slow Request Detection
```bash
# Find slow requests (>1 second)
awk '$NF > 1.0 {print}' /var/log/nginx/access.log

# Average response time
awk '{sum+=$(NF); count++} END {print "Average:", sum/count}' /var/log/nginx/access.log

# 95th percentile response time
awk '{print $(NF)}' /var/log/nginx/access.log | sort -n | awk 'END{print "95th percentile:", $(int(NR*0.95))}'
```

### Memory and CPU Profiling
```bash
# Profile nginx memory usage
valgrind --tool=massif nginx -g 'daemon off;'

# CPU profiling with perf
sudo perf record -g nginx
sudo perf report

# Memory maps
cat /proc/$(pgrep nginx | head -1)/maps
```

## Error Analysis

### Log Analysis Tools
```bash
# Real-time error monitoring
tail -f /var/log/nginx/error.log | grep -E "(error|critical|alert|emerg)"

# Error summary
grep "$(date '+%Y/%m/%d')" /var/log/nginx/error.log | cut -d' ' -f4 | sort | uniq -c

# Find memory issues
grep -i "memory" /var/log/nginx/error.log

# Connection errors
grep -i "connection" /var/log/nginx/error.log
```

### Common Error Patterns
```bash
# 502 Bad Gateway analysis
grep "502" /var/log/nginx/access.log | awk '{print $7}' | sort | uniq -c

# 404 Not Found analysis
grep "404" /var/log/nginx/access.log | awk '{print $7}' | sort | uniq -c

# Rate limiting analysis
grep "limiting requests" /var/log/nginx/error.log
```

## Debugging Tools and Scripts

### Custom Debug Script
```bash
#!/bin/bash
# nginx-debug.sh

echo "=== Nginx Debug Information ==="
echo "Date: $(date)"
echo

echo "=== Service Status ==="
systemctl status nginx --no-pager

echo "=== Configuration Test ==="
nginx -t

echo "=== Process Information ==="
ps aux | grep nginx

echo "=== Memory Usage ==="
ps aux | grep nginx | awk '{sum+=$6} END {print "Total Memory:", sum/1024, "MB"}'

echo "=== Connection Status ==="
netstat -an | grep :80 | wc -l | awk '{print "HTTP Connections:", $1}'
netstat -an | grep :443 | wc -l | awk '{print "HTTPS Connections:", $1}'

echo "=== Recent Errors ==="
tail -10 /var/log/nginx/error.log

echo "=== Disk Space ==="
df -h /var/log/nginx
```

### Log Monitoring Script
```bash
#!/bin/bash
# monitor-nginx-logs.sh

# Monitor for specific error patterns
tail -f /var/log/nginx/error.log | while read line; do
    if echo "$line" | grep -qi "error"; then
        echo "ERROR DETECTED: $line"
        # Send alert here
    fi
done
```

## Integration with Monitoring Tools

### Prometheus Metrics
```bash
# Install nginx-prometheus-exporter
docker run -p 9113:9113 nginx/nginx-prometheus-exporter:latest -nginx.scrape-uri=http://nginx:8080/stub_status
```

### ELK Stack Integration
```yaml
# Filebeat configuration for nginx logs
- type: log
  enabled: true
  paths:
    - /var/log/nginx/*.log
  fields:
    service: nginx
    environment: production
```

### Custom Alerting
```bash
# Simple alert script
#!/bin/bash
ERROR_COUNT=$(grep "$(date '+%Y/%m/%d %H:%M')" /var/log/nginx/error.log | wc -l)
if [ $ERROR_COUNT -gt 10 ]; then
    echo "High error rate detected: $ERROR_COUNT errors in last minute" | mail -s "Nginx Alert" admin@example.com
fi
```

## Production Debugging Best Practices

### Safe Debugging
- Always test configuration changes in staging first
- Use debug logging sparingly in production
- Monitor disk space when enabling debug logs
- Have rollback procedures ready

### Emergency Debugging
```bash
# Quick health check
curl -I http://localhost
systemctl status nginx
nginx -t

# Emergency restart
systemctl restart nginx

# Emergency rollback
cp /etc/nginx/nginx.conf.backup /etc/nginx/nginx.conf
systemctl reload nginx
```
