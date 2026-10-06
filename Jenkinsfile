#!/usr/bin/env groovy

library identifier: 'jenkins-shared-lib@master', retriever: modernSCM(
    [$class: 'GitSCMSource',
    remote: 'https://github.com/OyedunOye/jenkins-shared-library.git',
    credentialsId: 'd333e4b1-eb71-43bf-8485-7f068c14b823'
    ]
)

pipeline {   
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('jenkins-aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('jenkins-secret-access-key')
        AWS_ACCOUNT_ID        = credentials('aws_account_id')
        AWS_REGION            = 'us-east-1'
        ECR_REGISTRY          = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    }

    tools {
        maven 'maven-3.9'
    }


    stages {
        stage("test") {
            steps {
                script {
                    echo "Testing the application..."
                    testSourceCode()

                }
            }
        }

        stage("increment version") {
            steps {
                script {
                    echo 'incrementing app version'
                    sh 'mvn build-helper:parse-version versions:set -DnewVersion=\\${parsedVersion.majorVersion}.\\${parsedVersion.minorVersion}.\\${parsedVersion.nextIncrementalVersion} versions:commit'
                    def matcher = readFile('pom.xml')=~'<version>(.+)</version>'
                    def version = matcher[0][1]
                    env.IMAGE_NAME = "${ECR_REGISTRY}/java-maven-app:$version-$BUILD_NUMBER"
                }
            }
        }

        stage("build app") {
            steps {
                script {
                    echo "Building the application..."
                    buildJar()
                }
            }
        }

        stage("build image") {
            steps {
                // script {

                    // withCredentials([usernamePassword(credentialsId: 'ecr-credentials', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    //     sh "docker build -t ${IMAGE_NAME} ."
                    //     sh 'echo $PASS | docker login -u $USER --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com'
                    //     sh "docker push ${IMAGE_NAME}"
                    // }
                // }

                sh '''#!/bin/bash
                    set -euo pipefail

                    echo "Building the docker image..."

                    aws ecr get-login-password --region "$AWS_REGION" \
                    | docker login --username AWS --password-stdin "$ECR_REGISTRY"

                    docker build -t "$IMAGE_NAME" .
                    docker push "$IMAGE_NAME"
                '''
            }
        }

        stage("deploy") {
             environment {
                KUBECONFIG   = "${WORKSPACE}/.kube/config"
                APP_NAME = 'java-maven-app'
                CLUSTER_NAME = "my-app-eks-cluster"
            }
            steps {
                // script {
                //     echo 'deploying docker image to AWS EKS cluster'
                //     sh 'envsubst < kubernetes/deployment.yaml | kubectl apply -f -'
                //     sh 'envsubst < kubernetes/service.yaml | kubectl apply -f -'
                // }

                sh '''#!/bin/bash
                    set -euo pipefail

                    aws eks update-kubeconfig --region "$AWS_REGION" --name "$CLUSTER_NAME"

                    ECR_TOKEN="$(aws ecr get-login-password --region "$AWS_REGION")"

                    # create or refresh the pull secret with a fresh ECR token (replaces the manually created secret)
                    # Not needed if the node IAM role has AmazonEC2ContainerRegistryReadOnly.
                    kubectl create secret docker-registry aws-registry-key \
                      --docker-server="$ECR_REGISTRY" \
                      --docker-username=AWS \
                      --docker-password="$ECR_TOKEN" \
                      --dry-run=client -o yaml | kubectl apply -f -

                    # the manifests go through envsubst first to substitute the value of ${APP_NAME} and ${IMAGE_NAME} in the manifests.
                    envsubst < kubernetes/deployment.yaml | kubectl apply -f -
                    envsubst < kubernetes/service.yaml | kubectl apply -f -

                    kubectl rollout status deployment/"$APP_NAME" --timeout=180s
                '''
            }
        }

        stage('commit version update') {
            steps {
                script {
//                 this is my github login global cred id auto generated since I didn't provide one on creation and can't edit this id later
                    withCredentials([usernamePassword(credentialsId: 'd333e4b1-eb71-43bf-8485-7f068c14b823', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        sh 'git config --global user.email "jenkins@example.com"'
                        sh 'git config --global user.name "Jenkins"'

                        sh 'git remote set-url origin https://${USER}:${PASS}@github.com/OyedunOye/eks-java-maven-app.git'
                        sh 'git add pom.xml'
                        sh 'git commit -m "ci:version bump from successful Jenkins build"'
                        sh "git push origin HEAD:${BRANCH_NAME}"
                    }
                }
            }
        }
    }
} 
