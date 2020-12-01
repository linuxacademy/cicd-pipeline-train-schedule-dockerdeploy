pipeline {
    agent any
    environment {
        SG_CLIENT_ID = '334bdb24-8166-4af2-a368-f3874b5c6aef'
        SG_SECREDT_KEY = '76f810b7274446c8ac94d8b8ca0d57cd'
    }
     stages {
         
        stage('Build') {
            steps {
                echo 'Running build automation'
                sh './gradlew build --no-daemon'
            }
        }
        stage('Build Docker Image') {
            when {
                branch 'master'
            }
            steps {
                script {
                    app = docker.build("martyre37/cicd-pipeline-train-schedule-dockerdeploy")
                    app.inside {
                        sh 'echo $(curl localhost:8080)'
                    }
                }
            }
        }
        stage('SourceGuard Container Image Scan') {   
        steps {   
                 
           script {      
               try {
                  sh 'docker save martyre37/cicd-pipeline-train-schedule-dockerdeploy > cicd-pipeline-train-schedule-dockerdeploy.tar'
                  sh 'export -p'
                  sh './sourceguard-cli --img /var/lib/jenkins/workspace/train-schedule_master/cicd-pipeline-train-schedule-dockerdeploy.tar'
         
              } catch (Exception e) {
  
                  echo "Stage failed, but we continue"  
                   }
              }
          }
       }
        stage('Push Docker Image') {
            when {
                branch 'master'
            }
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'docker_hub_login') {
                        app.push("${env.BUILD_NUMBER}")
                        app.push("latest")
                    }
                }
            }
        }
        stage('DeployToProduction') {
            when {
                branch 'master'
            }
            steps {
                input 'Deploy to Production?'
                milestone(1)
                withCredentials([usernamePassword(credentialsId: 'CentOSprodForDocker', usernameVariable: 'USERNAME', passwordVariable: 'USERPASS')]) {
                    script {
                        sh "sshpass -p '$USERPASS' -v ssh -o StrictHostKeyChecking=no $USERNAME@$prod_ip_CentOS_for_Docker \"docker pull martyre37/cicd-pipeline-train-schedule-dockerdeploy:${env.BUILD_NUMBER}\""
                        try {
                            sh "sshpass -p '$USERPASS' -v ssh -o StrictHostKeyChecking=no $USERNAME@$prod_ip_CentOS_for_Docker \"docker stop train-schedule\""
                            sh "sshpass -p '$USERPASS' -v ssh -o StrictHostKeyChecking=no $USERNAME@$prod_ip_CentOS_for_Docker \"docker rm train-schedule\""
                        } catch (err) {
                            echo: 'caught error: $err'
                        }
                        sh "sshpass -p '$USERPASS' -v ssh -o StrictHostKeyChecking=no $USERNAME@$prod_ip_CentOS_for_Docker \"docker run --restart always --name train-schedule -p 9090:8181 -d martyre37/cicd-pipeline-train-schedule-dockerdeploy:${env.BUILD_NUMBER}\""
                    }
                }
            }
        }
    }
}
