@echo off
REM Build script for Spring Boot Application (Windows)

setlocal enabledelayedexpansion

echo ================================
echo Spring Boot App - Build Script
echo ================================

REM Variables
set APP_DIR=app
set DOCKER_IMAGE=springboot-app:latest
set DOCKER_DEV_CONTAINER=springboot-app-dev

REM Check if argument provided
if "%1%"=="" (
    call :show_help
    exit /b 0
)

if /i "%1%"=="build" (
    call :build_maven
) else if /i "%1%"=="test" (
    call :run_tests
) else if /i "%1%"=="docker" (
    call :build_maven
    call :build_docker
) else if /i "%1%"=="run" (
    call :run_docker
) else if /i "%1%"=="full" (
    call :build_maven
    call :run_tests
    call :build_docker
    call :run_docker
    echo.
    echo ================================
    echo Build completed successfully!
    echo ================================
) else if /i "%1%"=="clean" (
    call :cleanup
) else if /i "%1%"=="help" (
    call :show_help
) else (
    echo Unknown option: %1%
    call :show_help
    exit /b 1
)

goto :eof

:build_maven
echo.
echo [*] Building Spring Boot application with Maven...
cd %APP_DIR%
call mvn clean package -DskipTests
cd ..
echo [+] Maven build completed
exit /b 0

:run_tests
echo.
echo [*] Running tests...
cd %APP_DIR%
call mvn test
cd ..
echo [+] Tests completed
exit /b 0

:build_docker
echo.
echo [*] Building Docker image...
cd %APP_DIR%
call docker build -t %DOCKER_IMAGE% .
cd ..
echo [+] Docker image built successfully
exit /b 0

:run_docker
echo.
echo [*] Running Docker container...
docker stop %DOCKER_DEV_CONTAINER% 2>nul || true
docker rm %DOCKER_DEV_CONTAINER% 2>nul || true
docker run -d --name %DOCKER_DEV_CONTAINER% -p 8080:8080 %DOCKER_IMAGE%
timeout /t 5 /nobreak
echo [+] Container started at http://localhost:8080
exit /b 0

:cleanup
echo Cleaning up Docker container...
docker stop %DOCKER_DEV_CONTAINER% 2>nul || true
docker rm %DOCKER_DEV_CONTAINER% 2>nul || true
echo [+] Cleanup completed
exit /b 0

:show_help
echo.
echo Usage: build.bat [OPTION]
echo.
echo Options:
echo     build       Build Maven project only
echo     test        Run tests
echo     docker      Build Docker image
echo     run         Run Docker container
echo     full        Full build and run
echo     clean       Clean Docker container
echo     help        Show this help message
echo.
echo Examples:
echo     build.bat build          ^# Build with Maven
echo     build.bat full           ^# Build and run everything
echo     build.bat docker         ^# Build Docker image
echo.
exit /b 0
