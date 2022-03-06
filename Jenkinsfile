pipeline {
    agent any
    stages {
          stage('Build Docker image') {
        steps {
            echo 'Running build Docker image'
            // tag DockerHubAccountName/RepoName:tag(semver)
            sh 'pwd'
            sh 'whoami'
            sh 'docker build -t cloudtesttt/docker-image-guru:v1.0.2 .'
            

        }
    }
          stage('Push Docker image') {
        steps {
            echo 'Pushing Docker image'
            withCredentials([usernamePassword(credentialsId: 'docker_hub_login', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                
            sh '''
            docker login --username=$USERNAME --password=$PASSWORD
            docker push cloudtesttt/docker-image-guru:v1.0.2
            '''
            }

        }
          }



            stage('DeployToProduction') {
                when {
                    branch 'ayman'
                }
                steps {
                    input 'Deploy to Production?'
                    milestone(1)
                    withCredentials([usernamePassword(credentialsId: 'webserver_login', usernameVariable: 'USERNAME', passwordVariable: 'USERPASS')]) {
                        script {
                            sh "sshpass -p '$USERPASS' -v ssh -o StrictHostKeyChecking=no $USERNAME@$prod_ip \"cloudtesttt/docker-image-guru:v1.0.2:${env.BUILD_NUMBER}\""
                         
                            sh "sshpass -p '$USERPASS' -v ssh -o StrictHostKeyChecking=no $USERNAME@$prod_ip \"docker run --restart always --name train-schedule -p 8080:8080 -d cloudtesttt/docker-image-guru:v1.0.2:${env.BUILD_NUMBER}\""
                        }
                    }
                }
            }

    }
}
