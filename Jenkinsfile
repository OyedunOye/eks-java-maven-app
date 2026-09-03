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
            steps {
                script {
                    echo 'deploying docker image to LKE cluster'
                    withKubeConfig([credentialsId: 'lke-credentials', serverUrl: 'https://612a8560-e4d0-4374-b22d-eafedcf3b5e2.eu-central-1-gw.linodelke.net']) {
                        sh 'kubectl create deployment nginx-deployment --image=nginx'
                    }
                }
            }
        }

    }
} 
