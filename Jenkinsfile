pipeline {
    agent any
    stages {
        stage('Build') {
            echo 'Running build automation'
            sh './gradlew build --no-daemon'
            archiveArtifacts artifacts: 'dist/trainSchedule.zip'
        }
    }
    stage('Build Docker image') {
        when {
            branch 'master'
        }
        steps {
            script {
                app = docker.build("azamatus/train-schedule")
                app.inside {
                    sh 'echo $(curl localhost:8080)'
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
    stage('DeployToStage') {
        when {
            branch 'master'
        }
        steps {
            input 'Deploy to Stage'
            milestone(1)
            withCredentials([usernamePassword(credentialsId: 'webserver_login', usernameVarible: 'USERNAME', passwordVarible: 'USERPASS')]) {
                script {
                    sh "sshpass -p '$USERPASS' -v ssh -o StrictHostKeyChecking=no $USERNAME@$stage_ip \"docker pull azamatus/train-schedule:${env.BUILD_NUMBER}\""
                    try {
                        sh "sshpass -p '$USERPASS' -v ssh -o StrictHostKeyChecking=no $USERNAME@$stage_ip \"docker stop train-schedule\""
                        sh "sshpass -p '$USERPASS' -v ssh -o StrictHostKeyChecking=no $USERNAME@$stage_ip \"docker rm train-schedule\""
                    } catch (err) {
                        echo: 'caught error: $err'
                    }
                    sh "sshpass -p '$USERPASS' -v ssh -o StrictHostKeyChecking=no $USERNAME@$stage_ip \"docker run --restart always --name train-schedule -p 3000:8080 -d azamatus/train-schedule:${env.BUILD_NUMBER}\""
                }
            }
        }
    }
}
