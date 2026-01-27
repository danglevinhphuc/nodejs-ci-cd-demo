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
                    
                    // 1. Read Previous Version
                    def previousTag = "latest" // Default fallback
                    if (fileExists(env.PREVIOUS_VERSION_FILE)) {
                        previousTag = readFile(env.PREVIOUS_VERSION_FILE).trim()
                    }
                    echo "Current running version: ${previousTag}"
                    echo "Attempting to deploy: ${newTag}"

                    try {
                        // 2. Deploy New Version
                        deployVersion(newTag, repo)

                        // 3. Health Check
                        echo "Waiting for application to start..."
                        sleep(time: 15, unit: "SECONDS") 
                        
                        // DEBUG: Check if containers are actually running
                        sh "docker ps -a"

                        // Health check using a transient container on the same network
                        // Jenkins container cannot see 'localhost' of the host, so we use a sidecar curl.
                        sh "docker run --rm --network my-network curlimages/curl -f http://frontend-container/health" 
                        
                        echo "Health check passed!"
                        
                        // 4. Update State
                        writeFile file: env.PREVIOUS_VERSION_FILE, text: newTag

                    } catch (Exception e) {
                        echo "Deployment failed or Health check failed! Error: ${e.message}"
                        echo "Rolling back to version: ${previousTag}"
                        
                        // 5. Rollback
                        try {
                            deployVersion(previousTag, repo)
                            echo "Rollback successful."
                            
                            slackSend (
                                color: '#ff0000', 
                                message: "⚠️ DEPLOYMENT FAILED for ${newTag}. Rolled back to ${previousTag}. Check logs."
                            )
                            
                            // Re-throw so the build is marked as failure
                            error "Deployment Failed and Rolled Back."
                        } catch (Exception rollbackError) {
                            echo "CRITICAL: Rollback failed!"
                            error "Rollback Failed: ${rollbackError.message}"
                        }
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

def deployVersion(tag, repo) {
    sh 'chmod +x run-hub.sh'
    withEnv(['DETACHED=true']) {
         sh "./run-hub.sh ${tag} ${repo}"
    }
}
