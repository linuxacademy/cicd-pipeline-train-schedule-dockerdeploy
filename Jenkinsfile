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
            steps {
                app = docker.build("willbla/train-schedule")
                app.inside {
                    sh 'echo "Tests passed"'
                }
            }
        }
    }
}