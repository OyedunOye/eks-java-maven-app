# Deploy Application to EKS Cluster from Jenkins Pipeline

This project set up configurations that enable Jenkins to run kubectl commands to deploy app into set up partially-managed AWS EKS cluster. Steps to accomplish this include:
- Install kubectl command line tool in Jenkins container: ssh into the server hosting Jenkins, and then access the shell of the Jenkins container as root user. Download kubectl with the curl command below:
```bash
# access Jenkins container bash
docker exec -it -u 0 <container_id> /bin/bash

# Download docker, update its permissions and move into appropriate directory with the below commands
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl; chmod +x ./kubectl; mv ./kubectl /usr/local/bin/kubectl

# Confirm successful installation
kubectl version
```
- Install aws-iam-authenticator tool inside Jenkins container: download the authenticator with curl command, set permissions and move to right directory
```bash
curl -Lo aws-iam-authenticator https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.7.20/aws-iam-authenticator_0.7.20_linux_amd64
chmod +x ./aws-iam-authenticator
mv ./aws-iam-authenticator /usr/local/bin
```
- Create kubeconfig file to connect to EKS cluster as an alternative to credentials creation in Jenkins UI: save `config` file in `/var/jenkins_home/.kube` directory in Jenkins container.
- Add AWS credentials on Jenkins for AWS account authentication: create a multibranch pipeline project for this repo in Jenkins. Within the pipeline, add 2 `secret text` type credentials for jenkins aws service account. One is for the access key and the other for secret key.
- Configure Jenkinsfile to deploy app to EKS cluster: in pipeline deploy stage configured in Jenkinsfile, set aws access key and secret key as environment variables and execute kubectl command to deploy application in shell.

