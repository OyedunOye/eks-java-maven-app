# Deploy Application to Akamai's LKE Cluster from Jenkins Pipeline

This project set up configurations that enable Jenkins to run kubectl commands to deploy app into set up Akamai LKE cluster. Steps to accomplish this include:
- Install `Kubernetes CLI` plugin in Jenkins: this enables the execution of kubectl commands with kubeconfig credentials.
- Create a global `secret file` type credential within the jenkins-pipeline workflow. Upload the `kubeconfig` file downloaded from the LKE cluster and set an id for this credential.

- Configure Jenkinsfile to deploy app to LKE cluster using `withKubeConfig` method which is provided by the installed plugin to reference LKE credential configured in Jenkins plus LKE's k8s API endpoint. This allows the execution of kubectl command to deploy application into LKE cluster by Jenkins.