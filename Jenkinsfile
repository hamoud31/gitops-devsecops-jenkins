pipeline {
    agent any

    parameters {
        string(name: 'IMAGE_TAG', defaultValue: 'latest', description: 'Docker image tag')
    }

    tools {
        maven 'maven3'
        jdk 'jdk17'
    }

    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        MAVEN_HOME   = tool 'maven3'
        JAVA_HOME    = tool 'jdk17'
    }

    stages {

        stage('Git Checkout') {
            steps {
                git branch: 'main', credentialsId: 'github-creds', url: 'https://github.com/hamoud31/gitops-devsecops-jenkins.git'
            }
        }

        stage('Compile') {
            steps {
                dir('Multi-Tier-BankApp') {
                    sh "${MAVEN_HOME}/bin/mvn clean compile"
                }
            }
        }

        stage('Filesystem Scan (Trivy)') {
            steps {
                dir('Multi-Tier-BankApp') {
                    sh "trivy fs --format table -o ../fs.html ."
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh """
                        ${SCANNER_HOME}/bin/sonar-scanner \
                        -Dsonar.projectKey=bankapp \
                        -Dsonar.projectName=Multi-Tier-BankApp \
                        -Dsonar.sources=Multi-Tier-BankApp \
                        -Dsonar.java.binaries=Multi-Tier-BankApp/target \
                        -Dsonar.sourceEncoding=UTF-8
                    """
                }
            }
        }

        stage('Build & Publish to Nexus') {
            steps {
                dir('Multi-Tier-BankApp') {
                    withMaven(globalMavenSettingsConfig: 'GlobalConfMaven', jdk: 'jdk17', maven: 'maven3', traceability: true) {
                        sh "mvn deploy -DskipTests"
                    }
                }
            }
        }

        stage('Docker Build & Tag') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker_creds') {
                        dir('Multi-Tier-BankApp'){
                            sh "docker build -t hamoud07/bankapp:${params.IMAGE_TAG} ."
                        }
                    }
                }
            }
        }

        stage('Docker Image Scan') {
            steps {
                sh "trivy image --format table -o dimage.html hamoud07/bankapp:${params.IMAGE_TAG}"
            }
        }

        stage('Docker Push') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker_creds') {
                        sh "docker push hamoud07/bankapp:${params.IMAGE_TAG}"
                    }
                }
            }
        }

        stage('Update Kubernetes Manifests (GitOps)') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'github-creds', usernameVariable: 'USER', passwordVariable: 'TOKEN')]) {

                    sh '''
                        rm -rf gitops
                        git clone https://$USER:$TOKEN@github.com/hamoud31/gitops-devsecops-jenkins.git gitops

                        cd gitops

                        sed -i "s|image: hamoud07/bankapp:.*|image: hamoud07/bankapp:'"${IMAGE_TAG}"'|g" k8s-manifests/bankapp/deployment-app.yaml

                        git config user.name "hamoud31"
                        git config user.email "hamoudblal@gmail.com"

                        git add k8s-manifests/bankapp/deployment-app.yaml
                        git commit -m "Update bankapp image to '"${IMAGE_TAG}"'"
                        git push
                    '''
                }
            }
        }
    }
}
