# SpringBoot Task Manager Application

A modern Spring Boot application with an attractive frontend for managing tasks efficiently.

## Features

✨ **Frontend**
- Beautiful, responsive UI with gradient design
- Real-time task management (Create, Read, Update, Delete)
- Task completion tracking
- Statistics dashboard (Total & Completed tasks)
- Modal-based task editing
- Smooth animations and transitions
- Mobile-friendly responsive design

🔧 **Backend**
- Spring Boot 3.3.0
- RESTful API with CORS support
- Spring Data JPA with H2 Database
- Input validation
- Clean architecture with controllers, repositories, and models

🐳 **DevOps**
- Multi-stage Docker build for optimized images
- Docker Compose for easy orchestration
- Health checks configured
- Non-root user for security
- JVM memory optimization

🔄 **CI/CD**
- Complete Jenkins pipeline configuration
- Automated build, test, and deployment stages
- SonarQube integration for code quality
- Docker registry push capabilities
- Environment-based deployments (Dev/Prod)

## Project Structure

```
app/
├── src/
│   ├── main/
│   │   ├── java/springboot/
│   │   │   ├── App.java              (Main Spring Boot class)
│   │   │   ├── controller/
│   │   │   │   ├── HomeController.java
│   │   │   │   └── TaskController.java
│   │   │   ├── model/
│   │   │   │   └── Task.java
│   │   │   └── repository/
│   │   │       └── TaskRepository.java
│   │   └── resources/
│   │       ├── application.properties
│   │       └── templates/
│   │           └── index.html
│   └── test/
│       └── java/springboot/
│           └── AppTest.java
├── pom.xml                  (Maven configuration)
├── Dockerfile              (Multi-stage Docker build)
├── docker-compose.yml      (Docker Compose setup)
├── Jenkinsfile             (CI/CD Pipeline)
└── README.md              (This file)
```

## Getting Started

### Prerequisites
- Java 17+
- Maven 3.9+
- Docker & Docker Compose (for containerized deployment)
- Jenkins (for CI/CD pipeline)

### Local Development

1. **Build the project:**
   ```bash
   cd app
   mvn clean package
   ```

2. **Run the application:**
   ```bash
   mvn spring-boot:run
   ```

3. **Access the application:**
   - Open your browser and navigate to: http://localhost:8080

### Docker Deployment

1. **Build and run with Docker Compose:**
   ```bash
   docker-compose up --build
   ```

2. **Access the application:**
   - Open your browser and navigate to: http://localhost:8080

3. **View logs:**
   ```bash
   docker-compose logs -f
   ```

4. **Stop the application:**
   ```bash
   docker-compose down
   ```

## API Endpoints

### Get all tasks
```
GET /api/tasks
```

### Get task by ID
```
GET /api/tasks/{id}
```

### Create a new task
```
POST /api/tasks
Content-Type: application/json

{
  "title": "Task Title",
  "description": "Task Description"
}
```

### Update a task
```
PUT /api/tasks/{id}
Content-Type: application/json

{
  "id": 1,
  "title": "Updated Title",
  "description": "Updated Description",
  "completed": false
}
```

### Delete a task
```
DELETE /api/tasks/{id}
```

## Technology Stack

- **Frontend**: HTML5, CSS3, Vanilla JavaScript
- **Backend**: Spring Boot 3.3.0, Spring Web, Spring Data JPA, Thymeleaf
- **Database**: H2 (In-memory, easily replaceable with PostgreSQL)
- **Build Tool**: Maven
- **Containerization**: Docker, Docker Compose
- **CI/CD**: Jenkins

## Jenkins Pipeline Stages

1. **Checkout** - Clone repository
2. **Build** - Compile with Maven
3. **Test** - Run unit tests
4. **Code Quality** - SonarQube analysis
5. **Build Docker Image** - Create container image
6. **Push to Registry** - Push to Docker Hub (main branch)
7. **Deploy to Dev** - Deploy to development (develop branch)
8. **Deploy to Prod** - Deploy to production (main branch, with approval)
9. **Cleanup** - Remove old Docker images

## Environment Setup

### Jenkins Configuration

1. Create Jenkins credentials:
   - Docker credentials (username/password)
   - Git credentials
   - SonarQube token

2. Create Jenkins pipeline job:
   - Point to your repository
   - Select "Pipeline script from SCM"
   - Choose Git and provide repository URL

3. Set environment variables:
   ```
   GIT_REPO: Your repository URL
   GIT_BRANCH: main or develop
   SONAR_HOST_URL: http://your-sonar-server:9000
   SONAR_TOKEN: Your SonarQube token
   ```

## Configuration

### Application Properties
Edit `src/main/resources/application.properties`:

```properties
spring.application.name=SpringBootApp
server.port=8080
spring.jpa.hibernate.ddl-auto=update
spring.datasource.url=jdbc:h2:mem:testdb
```

### Docker Environment
Edit `docker-compose.yml` for:
- Port mappings
- Memory allocation
- Database configuration
- Volume mounts

### Jenkins Pipeline
Edit `Jenkinsfile` for:
- Docker registry URL
- Deployment targets
- Notification settings
- Environment-specific configurations

## Database

### Current: H2 In-Memory
- No external database required
- Perfect for development and testing
- Data persists only during application runtime

### Switch to PostgreSQL (Optional)

1. Update `pom.xml`:
   ```xml
   <dependency>
     <groupId>org.postgresql</groupId>
     <artifactId>postgresql</artifactId>
   </dependency>
   ```

2. Update `application.properties`:
   ```properties
   spring.datasource.url=jdbc:postgresql://localhost:5432/springbootdb
   spring.datasource.username=dbuser
   spring.datasource.password=dbpassword
   spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect
   ```

3. Uncomment PostgreSQL service in `docker-compose.yml`

## Security Considerations

- ✅ Non-root Docker user
- ✅ Health checks configured
- ✅ Input validation on backend
- ✅ CORS configured for API access
- ⚠️ Add Spring Security for production use

## Performance Optimization

- Multi-stage Docker builds for smaller images
- JVM heap size optimization in docker-compose.yml
- Database connection pooling ready
- Caching headers configured in Dockerfile

## Troubleshooting

### Application won't start
```bash
# Check logs
docker-compose logs springboot-app

# Verify port availability
lsof -i :8080
```

### Maven build fails
```bash
# Clean and rebuild
mvn clean install -U

# Check Java version
java -version
```

### Docker build fails
```bash
# Clear Docker cache
docker system prune

# Rebuild without cache
docker-compose build --no-cache
```

## Contributing

1. Create a feature branch: `git checkout -b feature/amazing-feature`
2. Commit changes: `git commit -m 'Add amazing feature'`
3. Push to branch: `git push origin feature/amazing-feature`
4. Open a Pull Request

## License

This project is open source and available under the MIT License.

## Support

For issues or questions, please create an issue in the repository.

---

**Last Updated**: May 2026
**Version**: 1.0.0
**Author**: Your Name
