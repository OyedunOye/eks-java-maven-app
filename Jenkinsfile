#!/usr/bin/env groovy

pipeline {   
    agent any

    tools {
        maven 'maven-3.9'
    }


    stages {
        stage("test") {
            steps {
                script {
                    echo "Testing the application..."
                }
            }
        }

        stage("build app") {
            steps {
                script {
                    echo "Building the application..."
                }
            }
        }

        stage("build image") {
            steps {
                script {
                    echo "Building the docker image..."
                }
            }
        }

        stage("deploy") {
            environment {
                AWS_ACCESS_KEY_ID = credentials('jenkins-aws-access-key-id')
                AWS_SECRET_ACCESS_KEY = credentials('jenkins-secret-access-key')
            }
            steps {
                script {
                    echo 'deploying docker image to AWS EKS'
                    sh 'kubectl create deployment nginx-deployment --image=nginx'
                }
            }
        }

    }
} 
