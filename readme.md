# Node.js App with Jenkins CI/CD and Local Docker Registry

## Overview

This project demonstrates how to:

* Containerize a Node.js app using Docker.
* Push and pull Docker images from a local Docker registry.
* Set up Jenkins inside Docker.
* Automate build, test, and deployment using Jenkins Pipelines.
* Troubleshoot and resolve issues that arise during CI/CD automation.

---

## Dockerfile Explained

```Dockerfile
FROM node:18            # Base image
COPY . .                # Copy all app files into the container
RUN npm install         # Install dependencies
CMD ["node", "app.js"]   # Default command to run the app
```

[Full Dockerfile Reference](https://docs.docker.com/reference/dockerfile/)

---

## Building and Running Docker Container

```bash
docker build -t node-app-local .
```

* `-t node-app-local`: Tags the image.
* `.`: Current directory used as build context.

### Running the App on Port 8888

```bash
docker run -d -p 8888:8888 -e PORT=8888 localhost:5000/node-app-local
```

If 8888 is unavailable, use:

```bash
docker run -d -p 8080:8888 -e PORT=8888 localhost:5000/node-app-local
```

> Note: Setting `-e PORT=8888` in the `docker run` command is one way to configure the application port. However, in our setup, we opted to set the `PORT` environment variable directly in the Dockerfile as another option.

### Docker Run Syntax

```
docker run [OPTIONS] IMAGE [COMMAND] [ARG...]
```

---

## Local Docker Registry Setup

```bash
docker run -d -p 5000:5000 --name registry registry:2
```

* Maps port 5000 and names the container `registry`.

### Push and Pull

```bash
docker tag node-app-local localhost:5000/node-app-local
docker push localhost:5000/node-app-local
docker pull localhost:5000/node-app-local
```

### View Local Registry Images

```bash
curl http://localhost:5000/v2/_catalog
```

---

## Jenkins Setup Options

### Option 1: Run Jenkins Inside Docker

```bash
docker run -d \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  --name jenkins-server \
  jenkins/jenkins:lts
```

### Option 2: Run Jenkins via .war File in WSL2

```bash
wget https://get.jenkins.io/war-stable/2.440.2/jenkins.war
nohup java -jar jenkins.war > jenkins.log 2>&1 &
```

Get password from:

```
/home/<user>/.jenkins/secrets/initialAdminPassword
```

### Necessary Plugins

* Git Plugin
* Docker Pipeline
* Pipeline
* Credentials Plugin
* Docker API
* Docker Credentials Plugin
* (Optional) Slack Notification Plugin
* (Optional) Email Extension Plugin

[Official Jenkins Documentation](https://www.jenkins.io/doc/)

---

## Jenkins Pipeline Configuration

### Creating Pipeline Job

1. Dashboard > New Item > Choose **Pipeline**
2. GitHub URL: `https://github.com/nasib-enosis/node-express-hello-devfile-no-dockerfile`
3. Pipeline Script from SCM > Git > main branch > `Jenkinsfile`

### Jenkinsfile Sample

```groovy
pipeline {
    agent any

    stages {
        stage('Clean Workspace') {
            steps {
                deleteDir()
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
                    docker.build('localhost:5000/node-app-local')
                }
            }
        }
        stage('Push to Local Registry') {
            steps {
                script {
                    docker.image('localhost:5000/node-app-local').push()
                }
            }
        }
        stage('Run Container (Verify)') {
            steps {
                script {
                    sh 'docker run -d -p 8888:8888 -e PORT=8888 --name node-test localhost:5000/node-app-local'

                    // Wait for the app to initialize
                    retry(5) {
                        sleep(time: 5, unit: 'SECONDS')
                        sh 'curl -f http://localhost:8888'
                    }
                }
            }
        }
    }
}
```

---

## Common Issues and Fixes

| Issue                             | Cause                               | Fix                                                         |
| --------------------------------- | ----------------------------------- | ----------------------------------------------------------- |
| Jenkins tries to fetch `master`   | Default branch mismatch             | Set `branch: 'main'` in `git` step                          |
| Docker not found                  | Jenkins container lacks Docker      | Run Jenkins with Docker socket access & install `docker.io` |
| Git not in valid repo             | Manual git clone conflicts with SCM | Avoid using both SCM and manual git clone                   |
| Git error: not in a git directory | .git directory missing              | Clean workspace using `deleteDir()` before checkout         |
| Port conflict                     | Jenkins uses 8080                   | Change app port to 8888 via env and map 8888:8888           |
| curl fails                        | App not ready                       | Use retry with sleep before curl                            |

---

## Final Thoughts

* Jenkins was successfully set up in Docker with local Docker registry integration.
* Multiple issues were resolved through environment understanding and Jenkins pipeline debugging.
* This setup provides a solid foundation for local CI/CD experimentation.

---

## Repo URL

[GitHub - node-express-hello-devfile-no-dockerfile](https://github.com/nasib-enosis/node-express-hello-devfile-no-dockerfile)
