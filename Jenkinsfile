pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "springboot-app:${BUILD_NUMBER}"
        DOCKER_REGISTRY = "docker.io"
        DOCKER_REPO = "your-docker-username"
        JAVA_HOME = "/usr/lib/jvm/java-17-openjdk"
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        disableConcurrentBuilds()
        timeout(time: 30, unit: 'MINUTES')
        timestamps()
    }

    stages {
        stage('Checkout') {
            steps {
                echo '🔄 Checking out source code...'
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '${GIT_BRANCH}']],
                    userRemoteConfigs: [[url: '${GIT_REPO}']]
                ])
            }
        }

        stage('Build') {
            steps {
                echo '🔨 Building Spring Boot application...'
                sh '''
                    cd app
                    mvn clean package -DskipTests
                '''
            }
        }

        stage('Test') {
            steps {
                echo '🧪 Running unit tests...'
                sh '''
                    cd app
                    mvn test
                '''
            }
        }

        stage('Code Quality Analysis') {
            steps {
                echo '📊 Running SonarQube analysis...'
                sh '''
                    cd app
                    mvn sonar:sonar \
                        -Dsonar.projectKey=springboot-app \
                        -Dsonar.sources=src \
                        -Dsonar.host.url=${SONAR_HOST_URL} \
                        -Dsonar.login=${SONAR_TOKEN} || true
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo '🐳 Building Docker image...'
                sh '''
                    cd app
                    docker build -t ${DOCKER_IMAGE} .
                    docker tag ${DOCKER_IMAGE} ${DOCKER_REPO}/${DOCKER_IMAGE}
                    docker tag ${DOCKER_IMAGE} ${DOCKER_REPO}/springboot-app:latest
                '''
            }
        }

        stage('Push to Registry') {
            when {
                branch 'main'
            }
            steps {
                echo '📤 Pushing image to Docker Registry...'
                withCredentials([usernamePassword(credentialsId: 'docker-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin
                        docker push ${DOCKER_REPO}/${DOCKER_IMAGE}
                        docker push ${DOCKER_REPO}/springboot-app:latest
                        docker logout
                    '''
                }
            }
        }

        stage('Deploy to Dev') {
            when {
                branch 'develop'
            }
            steps {
                echo '🚀 Deploying to Dev environment...'
                sh '''
                    docker stop springboot-app-dev || true
                    docker rm springboot-app-dev || true
                    docker run -d \
                        --name springboot-app-dev \
                        -p 8080:8080 \
                        --restart unless-stopped \
                        ${DOCKER_IMAGE}
                    sleep 10
                    curl -f http://localhost:8080 || exit 1
                '''
            }
        }

        stage('Deploy to Prod') {
            when {
                branch 'main'
            }
            steps {
                echo '🚀 Deploying to Production...'
                input 'Proceed with Production Deployment?'
                sh '''
                    # Example: Deploy using docker-compose or kubectl
                    docker pull ${DOCKER_REPO}/springboot-app:latest
                    docker stop springboot-app-prod || true
                    docker rm springboot-app-prod || true
                    docker run -d \
                        --name springboot-app-prod \
                        -p 8080:8080 \
                        --restart unless-stopped \
                        -e ENVIRONMENT=production \
                        ${DOCKER_REPO}/springboot-app:latest
                    sleep 15
                    curl -f http://localhost:8080 || exit 1
                '''
            }
        }

        stage('Cleanup') {
            steps {
                echo '🧹 Cleaning up Docker resources...'
                sh '''
                    docker image prune -af --filter "until=240h" || true
                '''
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline completed successfully!'
            // Send success notification
        }
        failure {
            echo '❌ Pipeline failed!'
            // Send failure notification
        }
        always {
            echo '📋 Archiving results...'
            junit 'app/target/surefire-reports/*.xml' || true
            archiveArtifacts artifacts: 'app/target/*.jar', allowEmptyArchive: true
        }
    }
}
