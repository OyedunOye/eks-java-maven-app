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
                    env.IMAGE_NAME = "oluwasade/demo-app:jma-$version-$BUILD_NUMBER"
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
                    def shellCmd = "bash ./server-cmds.sh ${IMAGE_NAME}"
                    def ec2Instance = "ec2-user@13.218.153.53"
                    sshagent(credentials: ['ec2-server-key'], executable: '') {
                        sh "scp docker-compose.yaml ${ec2Instance}:/home/ec2-user"
                        sh "scp server-cmds.sh ${ec2Instance}:/home/ec2-user"
                        sh "ssh -o StrictHostKeyChecking=no ${ec2Instance} ${shellCmd}"
                    }
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

                        sh "git remote set-url origin https://${USER}:${PASS}@github.com/OyedunOye/aws-java-maven-app.git"
                        sh 'git add .'
                        sh 'git commit -m "ci:version bump from successful Jenkins build"'
                        sh "git push origin HEAD:${BRANCH_NAME}"
                    }
                }
            }
        }
    }
} 
