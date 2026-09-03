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
                    env.IMAGE_NAME = "207567759818.dkr.ecr.us-east-1.amazonaws.com/java-maven-app:$version-$BUILD_NUMBER"
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
                    withCredentials([usernamePassword(credentialsId: 'ecr-credentials', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        sh "docker build -t ${IMAGE_NAME} ."
                        sh "echo $PASS | docker login -u $USER --password-stdin 207567759818.dkr.ecr.us-east-1.amazonaws.com"
                        sh "docker push ${IMAGE_NAME}"
                    }
                }
            }
        }

        stage("deploy") {
             environment {
                AWS_ACCESS_KEY_ID = credentials('jenkins-aws-access-key-id')
                AWS_SECRET_ACCESS_KEY = credentials('jenkins-secret-access-key')
                APP_NAME = 'java-maven-app'
            }
            steps {
                script {
                    echo 'deploying docker image to AWS EKS cluster'
                    sh 'envsubst < kubernetes/deployment.yaml | kubectl apply -f -'
                    sh 'envsubst < kubernetes/service.yaml | kubectl apply -f -'
                }
            }
        }

        stage('commit version update') {
            steps {
                script {
//                 this is my github login global cred id auto generated since I didn't provide one on creation and can't edit this id later
                    withCredentials([usernamePassword(credentialsId: 'd333e4b1-eb71-43bf-8485-7f068c14b823', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        sh 'git config --global user.email "jenkins@example.com"'
                        sh 'git config --global user.name "Jenkins"'

                        sh "git remote set-url origin https://${USER}:${PASS}@github.com/OyedunOye/eks-java-maven-app.git"
                        sh 'git add .'
                        sh 'git commit -m "ci:version bump from successful Jenkins build"'
                        sh "git push origin HEAD:${BRANCH_NAME}"
                    }
                }
            }
        }
    }
} 
