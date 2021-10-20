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
        stage('Build Docker Image') {
            when {
                branch 'master'
            }
            steps {
                Script {
                    app = docker.build("travelopiajonathan/train-schedule")
                    app.inside {
                        sh 'echo $(curl localhost:8080')
                    }
                }
            }
        }
    }
}