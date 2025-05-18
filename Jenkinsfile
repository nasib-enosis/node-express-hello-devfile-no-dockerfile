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

    stage('Cleanup Existing Containers') {
        steps {
            sh '''
                CONTAINERS=$(docker ps -a --format '{{.ID}} {{.Image}}' | grep "${IMAGE_NAME}" | awk '{print $1}')
                if [ -n "$CONTAINERS" ]; then
                    docker rm -f $CONTAINERS
                else
                    echo "No containers to remove for image ${IMAGE_NAME}"
                fi
            '''
        }
    }

    stage('Run Container (Verify)') {
        steps {
            sh """
                docker run -d --rm -p 8888:8888 ${IMAGE_NAME}:${env.BUILD_NUMBER}
                for i in {1..10}; do
                    curl -f http://localhost:8888 && break
                    echo "Waiting for app to be ready..."
                    sleep 2
                done
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
