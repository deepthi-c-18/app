# Spring Boot Application Docker Compose Configuration

## Prerequisites:
- Docker installed and running
- Docker Compose installed

## Usage:

### Build and start the application:
```bash
docker-compose up --build
```

### Access the application:
- Web UI: http://localhost:8080
- Health Check: http://localhost:8080/api/tasks

### View logs:
```bash
docker-compose logs -f springboot-app
```

### Stop the application:
```bash
docker-compose down
```

### Remove volumes:
```bash
docker-compose down -v
```

## Services:

### springboot-app
- **Port**: 8080
- **Image**: springboot-app (built from Dockerfile)
- **Restart Policy**: unless-stopped
- **Health Check**: Enabled with 30s interval

## Environment Variables:

Edit `docker-compose.yml` to modify:
- Port mappings
- Memory settings (JAVA_OPTS)
- Database credentials (when enabled)

## Notes:

1. The Dockerfile uses a multi-stage build for smaller image sizes
2. Non-root user (appuser) is used for security
3. Health checks are configured to monitor application status
4. Logs are persisted in the `app-logs` volume
5. Uncomment database service for PostgreSQL integration
