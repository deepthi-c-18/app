pipeline{
    agent any
    parameters{
        choice(
        name: 'PLAYBOOK',
        choices: [
            'update.yml','remove_db.yml','remove_app.yml','deploydb.yml','deploy_app.yml'
        ],
        description: 'Select and execute the playbook'
    )
    }
    tools{
        jdk 'jdk17'
        maven 'maven3'
    }
    stages{
        stage("Build"){
            steps{
                sh '''
                mvn clean package -DskipTests
                '''
            }
            post{
                success{
                    echo "Build Stage Completed"
                }
                failure{
                    echo "Failure to Build"
                }
            }
        }
        stage("Docker build and Run"){
            steps{
                sh '''
                docker compose up -d --build
                '''
            }
            post{
                success{
                    echo "Docker Build Stage Completed"
                }
                failure{
                    echo "Failure to Docker Build and Run"
                }
            }  
        }
        stage("Docker tag and Push into DockerHub"){
            steps{
            sh '''
                docker commit crud dhaya
                docker commit empdata sanjai
                docker tag dhaya dhayananthd/app
                docker tag sanjai dhayananthd/db
                sleep 1
                docker login -u dhayananthd -pDhaya9578@
                sleep 1
                docker push dhayananthd/app
                docker push dhayananthd/db
            '''
            }
        
        post{
                success{
                    echo "Snapshot successfully Taken"
                }
                failure{
                    echo "Failed To Take a snapshot"
                }
            }
        }
            stage("Remove img in Master Node"){
                steps{
                sh '''
                docker compose down -v
                docker system prune -af
                '''
                }
                post{
                success{
                    echo "Docker img successfully Removed"
                }
                failure{
                    echo "Failed To Remove docker img"
                }
            }
            }
           stage("Run Selected Playbook"){
    steps{
        sshagent(['kkk-kkk']){
            sh """
            ansible-playbook ${params.PLAYBOOK}
            """
        }
    }
    post{
        success{
            echo "Playbook Executed Successfully"
        }
        failure{
            echo "Failed To Execute Playbook"
        }
    }
}
            }
    }
