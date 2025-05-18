pipeline {
  agent any

  environment {
    IMAGE_NAME = "localhost:5000/node-hello"
  }

  stages {
    stage('Clean Workspace') {
      steps {
        deleteDir()  // wipes the entire workspace
      }
    }

    stage('Clone') {
      steps {
        git branch: 'main', url: 'https://github.com/nasib-enosis/node-express-hello-devfile-no-dockerfile.git'
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          dockerImage = docker.build("${IMAGE_NAME}:${env.BUILD_NUMBER}")
        }
      }
    }

    stage('Push to Local Registry') {
      steps {
        script {
          docker.withRegistry('http://localhost:5000', '') {
            dockerImage.push()
          }
        }
      }
    }

    stage('Cleanup Existing Container') {
        steps {
            script {
                def imageNoTag = IMAGE_NAME.split(':')[0]
                sh """
                    CONTAINER_ID=\$(docker ps -q -f ancestor=${imageNoTag})
                    if [ -n "\$CONTAINER_ID" ]; then
                    docker rm -f \$CONTAINER_ID
                    fi
                """
            }
        }
    }

    stage('Run Container (Verify)') {
      steps {
        sh """
          docker run -d --rm -p 3000:3000 ${IMAGE_NAME}:${env.BUILD_NUMBER}
          sleep 5
          curl -f http://localhost:3000 || exit 1
        """
      }
    }
  }

  post {
    failure {
      echo 'Build failed!'
    }
    success {
      echo 'CI/CD pipeline completed successfully!'
    }
  }
}
