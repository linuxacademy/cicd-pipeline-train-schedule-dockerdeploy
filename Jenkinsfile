pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                echo 'Running build automation'
                sh './gradlew build --no-daemon'
                archiveArtifacts artifacts: 'dist/trainSchedule.zip'
            }
        }
          stage('Build Image') {
            when {
                branch 'master'
            }
            steps {
                script {
                    app = docker.build("ikant3922/train-schedule")
                    app.inside {
                        sh 'echo $(curl localhost:8080)'
                    }
                }
            }
        }
        stage('Push Image') {
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
stage ('Deploy to staging') {
    when {
        branch 'master'
    }
    steps {
        withCredentials ([usernamePassword(credentialsId: 'webserver_login', usernameVariable: 'USERNAME', passwordVariable: 'USERPASS')]) {
            script {
                sh "sshpass -p '$USERPASS' -v ssh -o StrictHostKeyChecking=no $USERNAME@${env.stage_ip} \"docker pull ikant3922/train-schedule:${env.BUILD_NUMBER}\""
                try {
                   sh "sshpass -p '$USERPASS' -v ssh -o StrictHostKeyChecking=no $USERNAME@${env.stage_ip} \"docker stop train-schedule\""
                   sh "sshpass -p '$USERPASS' -v ssh -o StrictHostKeyChecking=no $USERNAME@${env.stage_ip} \"docker rm train-schedule\""
                } catch (err) {
                    echo: 'caught error: $err'
                }
                sh "sshpass -p '$USERPASS' -v ssh -o StrictHostKeyChecking=no $USERNAME@${env.stage_ip} \"docker run --restart always --name train-schedule -p 80:8080 -d ikant3922/train-schedule:${env.BUILD_NUMBER}\""
            }
        }
    }
}
stage ('Deploy to production') {
    when {
        branch 'master'
    }
    steps {
        input 'Deploy to Production'
        milestone(1)
        withCredentials ([usernamePassword(credentialsId: 'webserver_login', usernameVariable: 'USERNAME', passwordVariable: 'USERPASS')]) {
            script {
                sh "sshpass -p '$USERPASS' -v ssh -o StrictHostKeyChecking=no $USERNAME@${env.prod_ip} \"docker pull ikant3922/train-schedule:${env.BUILD_NUMBER}\""
                try {
                   sh "sshpass -p '$USERPASS' -v ssh -o StrictHostKeyChecking=no $USERNAME@${env.prod_ip} \"docker stop train-schedule\""
                   sh "sshpass -p '$USERPASS' -v ssh -o StrictHostKeyChecking=no $USERNAME@${env.prod_ip} \"docker rm train-schedule\""
                } catch (err) {
                    echo: 'caught error: $err'
                }
                sh "sshpass -p '$USERPASS' -v ssh -o StrictHostKeyChecking=no $USERNAME@${env.prod_ip} \"docker run --restart always --name train-schedule -p 80:8080 -d ikant3922/train-schedule:${env.BUILD_NUMBER}\""
            }
        }
    }
}

}
}
