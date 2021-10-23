pipeline {
    agent any
    environment {
        
        export SHIFTLEFT_REGION=eu1
       // SHIFTLEFT_REGION = 'eu'
        
        SG_CLIENT_ID = credentials("SG_CLIENT_ID")
        SG_SECRET_KEY = credentials("SG_SECRET_KEY")
        
     //  SG_CLIENT_ID='f112e396-cc24-41a7-965e-f4f6a15edc70'
     //  SG_SECRET_KEY='7357b344e7ca4169be3857807eabac46'
       // CHKP_CLOUDGUARD_ID = '313f4eed-5257-48bf-a139-9b5ebf37b093'
       // CHKP_CLOUDGUARD_SECRET = '4zf8mtdiw9xjicdszd3isgun'
    }
     stages {
         
        stage('Build') {
            steps {    
                echo 'Running build automation'
                sh './gradlew build --no-daemon'
            }
        }
             stage('SourceGuard Source Code Scan') {   
        steps {           
           script {      
               try {    
                  sh 'shiftleft –-version'
                  sh 'shiftleft code-scan -h .'      
              } catch (Exception e) {
                  echo "Stage failed, but we continue!"  
                   }
                 }
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
                  sh 'shiftleft image-scan -h /var/lib/jenkins/workspace/train-schedule_master/cicd-pipeline-train-schedule-dockerdeploy.tar'
              } catch (Exception e) {
                 // Optional Cleaning Workspace after failed build   
                //   sh rm -rf /var/lib/jenkins/workspace/train-schedule_master/train-schedule_master*
                       echo "Stage failed, but we continue! "
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
    stage('Secure WebApp in Production with Appsec') {   
        steps {    
            input 'Deploy with AppSec?'
            milestone(2)
            withCredentials([usernamePassword(credentialsId: 'CentOSprodForDocker', usernameVariable: 'USERNAME', passwordVariable: 'USERPASS')]) {
                script {      
                  sh "sshpass -p '$USERPASS' -v ssh -o StrictHostKeyChecking=no $USERNAME@$prod_ip_CentOS_for_Docker \"docker pull checkpoint/infinity-next-nginx\""
                  sh "sshpass -p '$USERPASS' -v ssh -o StrictHostKeyChecking=no $USERNAME@$prod_ip_CentOS_for_Docker \"docker run -d --name=agent-container${env.BUILD_NUMBER} --ipc=host -v=/etc/cp/conf -v=/etc/cp/data -v=/var/log/nano_agent -it checkpoint/infinity-next-nginx /cp-nano-agent --token cp-553df5cf-36c7-4fe6-9334-60b303cba808ca0535bf-e41c-4078-8efc-865b40b992aa\""         
                  }
            }
          }
    }
              }
         post {
            // Clean after build
            always {
                cleanWs(cleanWhenNotBuilt: false,
                        deleteDirs: true,
                        disableDeferredWipeout: true,
                        notFailBuild: true,
                        patterns: [[pattern: '.gitignore', type: 'INCLUDE'],
                                   [pattern: '.propsfile', type: 'EXCLUDE']])
            }
        }
}
