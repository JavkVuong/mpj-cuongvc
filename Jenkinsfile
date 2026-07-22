pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '20'))
        timeout(time: 30, unit: 'MINUTES')
    }

    environment {
        AWS_REGION     = 'ap-southeast-1'
        AWS_ACCOUNT_ID = '527055790396'
        ECR_REPOSITORY = 'news-cms'
        ECR_REGISTRY   = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

        EKS_CLUSTER    = 'news-cms-cluster'
        K8S_NAMESPACE  = 'mpj-cuongvc'
        DEPLOYMENT     = 'news-cms'
        CONTAINER_NAME = 'news-cms'

        HEALTH_URL     = 'https://mpj-cuongvc.do2602.click/api/health'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    env.GIT_SHORT_SHA = sh(
                        script: 'git rev-parse --short=7 HEAD',
                        returnStdout: true
                    ).trim()

                    env.IMAGE_TAG = "${BUILD_NUMBER}-${GIT_SHORT_SHA}"
                    env.IMAGE_URI = "${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"
                }

                sh '''
                    echo "Commit: ${GIT_SHORT_SHA}"
                    echo "Image:  ${IMAGE_URI}"
                '''
            }
        }

        stage('Verify Environment') {
            steps {
                sh '''
                    set -eu

                    docker --version
                    aws --version
                    kubectl version --client

                    aws sts get-caller-identity

                    aws eks update-kubeconfig \
                      --region "${AWS_REGION}" \
                      --name "${EKS_CLUSTER}"

                    kubectl get deployment "${DEPLOYMENT}" \
                      -n "${K8S_NAMESPACE}"
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    set -eu

                    docker build \
                      --pull \
                      --tag "${IMAGE_URI}" \
                      .
                '''
            }
        }

        stage('Login to ECR') {
            steps {
                sh '''
                    set -eu

                    aws ecr get-login-password \
                      --region "${AWS_REGION}" \
                    | docker login \
                      --username AWS \
                      --password-stdin "${ECR_REGISTRY}"
                '''
            }
        }

        stage('Push Image') {
            steps {
                sh '''
                    set -eu
                    docker push "${IMAGE_URI}"
                '''
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh '''
                    set -eu

                    kubectl set image \
                      deployment/"${DEPLOYMENT}" \
                      "${CONTAINER_NAME}"="${IMAGE_URI}" \
                      -n "${K8S_NAMESPACE}"

                    kubectl rollout status \
                      deployment/"${DEPLOYMENT}" \
                      -n "${K8S_NAMESPACE}" \
                      --timeout=300s
                '''
            }
        }

        stage('Health Check') {
            steps {
                sh '''
                    set -eu

                    attempt=1
                    max_attempts=12

                    while [ "$attempt" -le "$max_attempts" ]; do
                        echo "Health check attempt ${attempt}/${max_attempts}"

                        if curl \
                          --fail \
                          --silent \
                          --show-error \
                          --connect-timeout 10 \
                          --max-time 20 \
                          "${HEALTH_URL}"; then
                            echo
                            echo "Health check passed"
                            exit 0
                        fi

                        attempt=$((attempt + 1))
                        sleep 10
                    done

                    echo "Health check failed"
                    kubectl get pods -n "${K8S_NAMESPACE}"
                    kubectl describe deployment "${DEPLOYMENT}" \
                      -n "${K8S_NAMESPACE}"

                    exit 1
                '''
            }
        }
    }

    post {
        success {
            echo "Deployment successful: ${IMAGE_URI}"
        }

        failure {
            echo "Pipeline failed."
            echo "Inspect the failed stage and Kubernetes pod logs."
        }

        always {
            sh '''
                docker logout "${ECR_REGISTRY}" || true
                docker image rm "${IMAGE_URI}" || true
                docker image prune -f || true
            '''
        }
    }
}
