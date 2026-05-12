# Architecture Overview

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                          CLIENT LAYER                            │
├─────────────────────────────────────────────────────────────────┤
│                    Beautiful Frontend UI                          │
│  • HTML5, CSS3, Vanilla JavaScript                               │
│  • Responsive Design, Mobile-Friendly                            │
│  • Real-time Task Management Interface                           │
│  • Dashboard with Statistics                                     │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           │ HTTP(S)
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                      API GATEWAY LAYER                           │
├─────────────────────────────────────────────────────────────────┤
│              Nginx (Reverse Proxy & Load Balancer)               │
│  • SSL/TLS Termination                                           │
│  • Rate Limiting & Compression                                   │
│  • Static File Caching                                           │
│  • Security Headers                                              │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           │ HTTP
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                    APPLICATION LAYER                             │
├─────────────────────────────────────────────────────────────────┤
│                 Spring Boot Application                           │
│  • Spring Web (REST API)                                         │
│  • Spring Data JPA (ORM)                                         │
│  • Thymeleaf (Template Engine)                                   │
│  • Spring Validation (Input Validation)                          │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Controllers                                             │  │
│  │  • HomeController (Template Rendering)                   │  │
│  │  • TaskController (REST API - CRUD Operations)           │  │
│  └──────────────────────┬───────────────────────────────────┘  │
│                         │                                        │
│  ┌──────────────────────▼───────────────────────────────────┐  │
│  │  Services/Business Logic                                 │  │
│  │  • Task Management Logic                                 │  │
│  │  • Validation & Error Handling                           │  │
│  └──────────────────────┬───────────────────────────────────┘  │
│                         │                                        │
│  ┌──────────────────────▼───────────────────────────────────┐  │
│  │  Repositories (Data Access)                              │  │
│  │  • TaskRepository (JPA)                                  │  │
│  │  • Entity Mapping                                        │  │
│  └──────────────────────┬───────────────────────────────────┘  │
│                         │                                        │
└─────────────────────────┼────────────────────────────────────────┘
                          │
                          │ SQL Queries
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                    DATA ACCESS LAYER                             │
├─────────────────────────────────────────────────────────────────┤
│                  Database Options                                │
│  • H2 In-Memory (Development/Testing)                            │
│  • PostgreSQL (Production)                                       │
│  • MySQL (Alternative)                                           │
└─────────────────────────────────────────────────────────────────┘
```

## Component Breakdown

### 1. Frontend Layer
```
index.html
├── HTML Structure
├── CSS Styling
│   ├── Responsive Layout
│   ├── Gradient Backgrounds
│   ├── Animations & Transitions
│   └── Mobile Optimization
└── JavaScript Functionality
    ├── Task CRUD Operations
    ├── Modal Management
    ├── API Communication
    └── Real-time UI Updates
```

### 2. Backend Layer
```
Spring Boot Application
├── Controllers
│   ├── HomeController (GET / → Templates)
│   └── TaskController (REST API)
├── Models (Entities)
│   └── Task Entity
├── Repositories
│   └── TaskRepository (JPA)
├── Configuration
│   └── Application Properties
└── Resources
    └── Static Content & Templates
```

### 3. REST API Endpoints
```
/api/tasks
├── GET    /             → Get all tasks
├── GET    /{id}         → Get single task
├── POST   /             → Create task
├── PUT    /{id}         → Update task
└── DELETE /{id}         → Delete task
```

### 4. Database Schema
```
TASKS Table
├── id (PK, AUTO_INCREMENT)
├── title (VARCHAR, NOT NULL)
├── description (TEXT)
├── completed (BOOLEAN, DEFAULT: false)
└── created_at (TIMESTAMP)
```

## Deployment Architecture

### Local Development
```
Your Machine
├── Maven
├── Spring Boot Development Server
└── H2 In-Memory Database
```

### Docker Development
```
Docker Engine
├── Spring Boot Container
│   ├── Application JAR
│   ├── JRE 17
│   └── H2 Database
└── Volume Mounts
    └── Logs Volume
```

### Production Environment
```
Production Server
├── Nginx Container
│   ├── Reverse Proxy
│   ├── SSL/TLS
│   ├── Load Balancing
│   └── Compression & Caching
├── Spring Boot Containers (1-N)
│   ├── Application Instances
│   ├── Health Checks
│   └── Auto-restart
└── Database Container
    └── PostgreSQL
```

## CI/CD Pipeline Architecture

```
Git Repository
       ↓
   [Webhook]
       ↓
Jenkins Pipeline
│
├─→ Stage: Checkout
│   └─→ Clone Repository
│
├─→ Stage: Build
│   └─→ Maven: mvn clean package
│
├─→ Stage: Test
│   └─→ Maven: mvn test
│
├─→ Stage: Code Quality
│   └─→ SonarQube Analysis
│
├─→ Stage: Docker Build
│   └─→ Build Image: docker build
│
├─→ Stage: Registry Push
│   └─→ Push to Docker Hub
│
├─→ Stage: Deploy (Dev/Prod)
│   └─→ Run Container: docker run
│
└─→ Stage: Post-Build
    └─→ Archive & Cleanup
```

## Technology Stack

### Frontend
- **HTML5** - Markup
- **CSS3** - Styling (Flexbox, Gradients, Animations)
- **JavaScript (ES6+)** - Interactivity & API Calls

### Backend
- **Spring Boot 3.3.0** - Application Framework
- **Spring Web** - REST API & Web Support
- **Spring Data JPA** - Database Access
- **Thymeleaf** - Template Engine
- **H2 Database** - Development Database

### DevOps
- **Docker** - Containerization
- **Docker Compose** - Container Orchestration
- **Nginx** - Reverse Proxy (Production)
- **Jenkins** - CI/CD Automation

### Build Tools
- **Maven 3.9** - Dependency Management & Build
- **Java 17** - JDK

## Data Flow

### Create Task Flow
```
1. User enters task title in UI
2. Clicks "Add Task" button
3. JavaScript sends POST /api/tasks
4. TaskController.createTask() receives request
5. Task entity saved to database
6. JSON response returned
7. Frontend updates UI with new task
```

### Update Task Flow
```
1. User clicks "Edit" button
2. Modal opens with current task data
3. User modifies and saves
4. JavaScript sends PUT /api/tasks/{id}
5. TaskController.updateTask() processes
6. Database updated with new values
7. Frontend refreshes task list
```

### Delete Task Flow
```
1. User clicks "Delete" button
2. Confirmation dialog shown
3. JavaScript sends DELETE /api/tasks/{id}
4. TaskController.deleteTask() processes
5. Task removed from database
6. Frontend updates UI
```

## Security Features

```
┌─────────────────────────────────────┐
│  Security Layers                    │
├─────────────────────────────────────┤
│ Layer 1: HTTPS/SSL (Nginx)          │
│ Layer 2: Rate Limiting              │
│ Layer 3: CORS Configuration         │
│ Layer 4: Input Validation           │
│ Layer 5: SQL Injection Prevention   │
│          (Via JPA Parameterized)    │
│ Layer 6: XSS Protection             │
│ Layer 7: Security Headers           │
│ Layer 8: Non-root Docker User       │
└─────────────────────────────────────┘
```

## Scalability Considerations

### Horizontal Scaling
```
Load Balancer (Nginx)
│
├─→ Instance 1 (Port 8081)
├─→ Instance 2 (Port 8082)
├─→ Instance 3 (Port 8083)
└─→ Instance N (Port 808N)
     │
     └─→ Shared Database (PostgreSQL)
```

### Vertical Scaling
- Increase JVM Heap Size: `-Xmx2048m`
- Increase Worker Threads
- Increase Database Connection Pool
- Add Caching Layer (Redis)

## Performance Optimization

1. **Frontend**
   - Minified CSS & JavaScript
   - Browser caching headers
   - Gzip compression

2. **Backend**
   - Connection pooling
   - Query optimization
   - Lazy loading

3. **Database**
   - Index optimization
   - Query caching
   - Prepared statements

4. **Infrastructure**
   - CDN for static content
   - Load balancing
   - Multi-instance deployment

## Monitoring & Observability

```
┌──────────────────────────────┐
│  Monitoring Stack            │
├──────────────────────────────┤
│ • Application Logs           │
│ • Docker Container Logs      │
│ • Health Check Endpoints     │
│ • Nginx Access Logs          │
│ • SonarQube Code Quality     │
│ • JVM Metrics                │
└──────────────────────────────┘
```

---

For deployment and configuration details, see:
- [QUICKSTART.md](./QUICKSTART.md) - Quick setup guide
- [README.md](./README.md) - Full documentation
- [PRODUCTION.md](./PRODUCTION.md) - Production setup
