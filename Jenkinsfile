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
                    echo 'deploying docker image '
                }
            }
        }

    }
} 
