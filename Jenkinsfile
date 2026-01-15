pipeline {
    agent any

    parameters {
        string(name: 'DOCKER_REPO', defaultValue: 'yourusername/nodejs-ci-cd-demo', description: 'Docker Hub Repository Name')
        string(name: 'IMAGE_TAG', defaultValue: 'latest', description: 'The Docker image tag to deploy (typically the Commit SHA)')
    }

    environment {
        // You must define these credentials in Jenkins
        DOCKER_CREDENTIALS_ID = 'docker-hub-creds' 
    }

    stages {
        stage('Checkout') {
            steps {
                // Essential: We need the source code for:
                // 1. db/migration/*.sql files (used by Flyway)
                // 2. run-hub.sh script
                checkout scm
            }
        }

        stage('Deploy (CD)') {
            steps {
                script {
                    echo "Deploying version: ${params.IMAGE_TAG}"
                    
                    // Ensure script is executable
                    sh 'chmod +x run-hub.sh'
                    
                    // Run the deployment script with the providing tag
                    // DETACHED=true ensures it runs in background and doesn't block the Jenkins job
                    withEnv(['DETACHED=true']) {
                         sh "./run-hub.sh ${params.IMAGE_TAG} ${params.DOCKER_REPO}"
                    }
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
    }
}
