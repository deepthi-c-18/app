#!/bin/bash

# Build script for Spring Boot Application

set -e

echo "================================"
echo "Spring Boot App - Build Script"
echo "================================"

# Variables
APP_DIR="app"
DOCKER_IMAGE="springboot-app:latest"
DOCKER_DEV_CONTAINER="springboot-app-dev"

# Check prerequisites
check_prerequisites() {
    echo "✓ Checking prerequisites..."
    
    if ! command -v java &> /dev/null; then
        echo "✗ Java is not installed"
        exit 1
    fi
    
    if ! command -v mvn &> /dev/null; then
        echo "✗ Maven is not installed"
        exit 1
    fi
    
    if ! command -v docker &> /dev/null; then
        echo "✗ Docker is not installed"
        exit 1
    fi
    
    echo "✓ All prerequisites are installed"
}

# Build with Maven
build_maven() {
    echo ""
    echo "🔨 Building Spring Boot application with Maven..."
    cd $APP_DIR
    mvn clean package -DskipTests
    cd ..
    echo "✓ Maven build completed"
}

# Run tests
run_tests() {
    echo ""
    echo "🧪 Running tests..."
    cd $APP_DIR
    mvn test
    cd ..
    echo "✓ Tests completed"
}

# Build Docker image
build_docker() {
    echo ""
    echo "🐳 Building Docker image..."
    cd $APP_DIR
    docker build -t $DOCKER_IMAGE .
    cd ..
    echo "✓ Docker image built successfully"
}

# Run Docker container
run_docker() {
    echo ""
    echo "🚀 Running Docker container..."
    
    # Stop existing container
    docker stop $DOCKER_DEV_CONTAINER 2>/dev/null || true
    docker rm $DOCKER_DEV_CONTAINER 2>/dev/null || true
    
    docker run -d \
        --name $DOCKER_DEV_CONTAINER \
        -p 8080:8080 \
        $DOCKER_IMAGE
    
    echo "✓ Container started. Waiting for application..."
    sleep 5
    
    # Check if application is running
    if curl -f http://localhost:8080 > /dev/null 2>&1; then
        echo "✓ Application is running at http://localhost:8080"
    else
        echo "✗ Application failed to start"
        docker logs $DOCKER_DEV_CONTAINER
        exit 1
    fi
}

# Show help
show_help() {
    cat << EOF
Usage: ./build.sh [OPTION]

Options:
    build       Build Maven project only
    test        Run tests
    docker      Build Docker image
    run         Run Docker container
    full        Full build and run (Maven + Docker + Run)
    clean       Clean Docker container
    help        Show this help message

Examples:
    ./build.sh build          # Build with Maven
    ./build.sh full           # Build and run everything
    ./build.sh docker         # Build Docker image
    ./build.sh run            # Run Docker container
EOF
}

# Main script
main() {
    check_prerequisites
    
    case "${1:-help}" in
        build)
            build_maven
            ;;
        test)
            run_tests
            ;;
        docker)
            build_maven
            build_docker
            ;;
        run)
            run_docker
            ;;
        full)
            build_maven
            run_tests
            build_docker
            run_docker
            echo ""
            echo "================================"
            echo "✅ Build completed successfully!"
            echo "================================"
            ;;
        clean)
            echo "Cleaning up Docker container..."
            docker stop $DOCKER_DEV_CONTAINER 2>/dev/null || true
            docker rm $DOCKER_DEV_CONTAINER 2>/dev/null || true
            echo "✓ Cleanup completed"
            ;;
        help|*)
            show_help
            ;;
    esac
}

main "$@"
