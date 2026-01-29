pipeline {
    agent any

    parameters {
        string(name: 'DOCKER_REPO', defaultValue: 'yourusername/mono-repo', description: 'Docker Hub Repository Name')
        string(name: 'IMAGE_TAG', defaultValue: 'latest', description: 'The Docker image tag to deploy')
    }

    environment {
        // You must define these credentials in Jenkins
        DOCKER_CREDENTIALS_ID = 'docker-hub-creds' 
        PREVIOUS_VERSION_FILE = 'current_version.txt'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Deploy (CD)') {
            steps {
                script {
                    def newTag = params.IMAGE_TAG
                    def repo = params.DOCKER_REPO
                    def versionFile = env.PREVIOUS_VERSION_FILE
                    
                    try {
                        // Delegate Logic to Bash Script
                        // We map stdout to Jenkins console automatically
                        // If script exits with 0 -> Success
                        // If script exits with 1 -> Failure (Rollback happened)
                        
                        // Ensure script is executable
                        sh "chmod +x scripts/deploy.sh"
                        
                        if (isUnix()) {
                            sh "./scripts/deploy.sh ${newTag} ${repo} ${versionFile}"
                        } else {
                            // Windows fallback - assuming Git Bash or similar environment available to Jenkins
                            bat "bash scripts/deploy.sh ${newTag} ${repo} ${versionFile}"
                        }
                        
                    } catch (Exception e) {
                        // The Script exits with 1 if rollback occurred
                        echo "Deployment Pipeline Failed (Handled by Bash Script)"
                        
                        slackSend (
                            color: '#ff0000', 
                            message: "⚠️ DEPLOYMENT FAILED for ${newTag}. Rolled back. Check logs."
                        )
                        
                        error "Deployment Failed."
                    }
                }
            }
        }
    }
    
    post {
        success {
            cleanWs()
            slackSend (
                color: '#36a64f', 
                message: "SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})"
            )
        }
        failure {
            echo "Pipeline failed. Check logs."
            slackSend (
                color: '#dc3545', 
                message: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})"
            )
        }
    }
}
