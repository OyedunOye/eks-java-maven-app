#!/usr/bin/env groovy

library identifier: 'jenkins-shared-lib@master', retriever: modernSCM(
    [$class: 'GitSCMSource',
    remote: 'https://github.com/OyedunOye/jenkins-shared-library.git',
    credentialsId: 'd333e4b1-eb71-43bf-8485-7f068c14b823'
    ]
)

pipeline {   
    agent any

    tools {
        maven 'maven-3.9'
    }

    environment {
        IMAGE_NAME = 'oluwasade/demo-app:jma-2.0.0'
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
                script {
                    echo "Building the docker image..."
                    buildImage(env.IMAGE_NAME)
                    dockerLogin()
                    pushImage(env.IMAGE_NAME)
                }
            }
        }

        stage("deploy") {
            steps {
                script {
                    echo 'deploying docker image to EC2'
                    def dockerCmd = "docker run -d -p 8080:8080 ${env.IMAGE_NAME}"
                    sshagent(credentials: ['ec2-server-key'], executable: '') {
                        sh "ssh -o StrictHostKeyChecking=no ec2-user@13.218.153.53 ${dockerCmd}"
                    }
                }
            }
        }               
    }
} 
