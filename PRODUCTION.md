# Production Deployment with Nginx

This guide helps you set up a production-ready deployment with Nginx as a reverse proxy.

## Architecture

```
Internet
   ↓
Nginx (Reverse Proxy, Port 80/443)
   ↓
Spring Boot App (Docker, Port 8080)
   ↓
H2 Database / PostgreSQL
```

## Docker Compose with Nginx (Production Setup)

Create `docker-compose.prod.yml`:

```yaml
version: '3.9'

services:
  nginx:
    image: nginx:alpine
    container_name: springboot-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
      - ./html:/usr/share/nginx/html:ro
    depends_on:
      - springboot-app
    networks:
      - app-network
    restart: unless-stopped

  springboot-app:
    build:
      context: ./app
      dockerfile: Dockerfile
    container_name: springboot-app-prod
    environment:
      - SPRING_PROFILES_ACTIVE=production
      - JAVA_OPTS=-Xmx1024m -Xms512m
    volumes:
      - app-logs:/app/logs
    networks:
      - app-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/api/tasks"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

volumes:
  app-logs:

networks:
  app-network:
    driver: bridge
```

## Nginx Configuration

Create `nginx.conf`:

```nginx
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    client_max_body_size 20M;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript 
               application/json application/javascript application/xml+rss 
               application/atom+xml image/svg+xml;

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=general_limit:10m rate=30r/s;

    # Upstream
    upstream springboot {
        server springboot-app:8080;
        keepalive 32;
    }

    # HTTP to HTTPS redirect
    server {
        listen 80;
        server_name _;
        return 301 https://$host$request_uri;
    }

    # HTTPS server
    server {
        listen 443 ssl http2;
        server_name _;

        # SSL certificates
        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;

        # SSL configuration
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 10m;

        # Security headers
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header Referrer-Policy "strict-origin-when-cross-origin" always;

        # Root location
        location / {
            limit_req zone=general_limit burst=20 nodelay;
            
            proxy_pass http://springboot;
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # Timeouts
            proxy_connect_timeout 60s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
        }

        # API rate limiting
        location /api/ {
            limit_req zone=api_limit burst=5 nodelay;
            
            proxy_pass http://springboot;
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # Health check endpoint
        location /health {
            access_log off;
            proxy_pass http://springboot/api/tasks;
        }

        # Static files caching
        location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
            proxy_pass http://springboot;
            expires 30d;
            add_header Cache-Control "public, immutable";
        }

        # Deny access to sensitive files
        location ~ /\. {
            deny all;
            access_log off;
            log_not_found off;
        }

        # Custom 404 page
        error_page 404 /404.html;
        location = /404.html {
            root /usr/share/nginx/html;
        }
    }
}
```

## SSL Certificate Generation

For self-signed certificate (development):
```bash
openssl req -x509 -newkey rsa:4096 -keyout ssl/key.pem -out ssl/cert.pem -days 365 -nodes
```

For production, use Let's Encrypt:
```bash
certbot certonly --standalone -d yourdomain.com
```

## Deployment Commands

```bash
# Start production environment
docker-compose -f docker-compose.prod.yml up -d

# View logs
docker-compose -f docker-compose.prod.yml logs -f

# Stop
docker-compose -f docker-compose.prod.yml down

# Scale application (if needed)
docker-compose -f docker-compose.prod.yml up -d --scale springboot-app=3
```

## Monitoring

### Health Check
```bash
curl https://localhost/health
```

### View Nginx Logs
```bash
docker exec springboot-nginx tail -f /var/log/nginx/access.log
```

### Performance Monitoring
```bash
docker stats springboot-nginx springboot-app
```

## Security Best Practices

✅ HTTPS/SSL enabled
✅ Rate limiting configured
✅ Security headers added
✅ Static file caching
✅ Gzip compression
✅ X-Frame-Options
✅ HSTS enabled
✅ XSS protection

## Load Balancing

For multiple application instances:

```nginx
upstream springboot {
    least_conn;  # Load balancing strategy
    server springboot-app-1:8080 weight=1;
    server springboot-app-2:8080 weight=1;
    server springboot-app-3:8080 weight=1;
    keepalive 32;
}
```

## Troubleshooting

### 502 Bad Gateway
- Check if Spring Boot app is running: `docker ps`
- Check app logs: `docker logs springboot-app`
- Verify upstream: `docker exec springboot-nginx curl http://springboot-app:8080`

### SSL Certificate Errors
- Regenerate certificate
- Check certificate paths in nginx.conf
- Verify permissions: `chmod 644 ssl/cert.pem`

### High CPU Usage
- Check worker_processes setting
- Monitor with: `docker stats`
- Enable gzip compression

---

For more information, see [README.md](./README.md)
