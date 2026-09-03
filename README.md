# Complete CI/CD Pipeline with EKS and DockerHub
This project focuses on incorporating all build stages plus configuration of deploy stage to target EKS cluster.
## Steps
- Set access and secret keys as environment variable in deploy stage
- Create a Deployment and a Service configuration for the deployment of app image pushed to DockerHub private repo in the `build image` stage of this pipeline. The files are in `kubernetes` directory.
- Variables are referenced in the both yaml config files above, there is need to get the actual files for the templates before running `kubectl apply` command on them. To do this, `envsubst` should be available from within `deploy stage`. Install `gettext-base` tool in Jenkins container to get the needed `envsubst`.
```bash
# while in server hosting Jenkins
docker exec -it -u 0 <jenkins_container_id> bash
apt-get install gettext-base

# no error in the below command signifies success
envsubst
```
- Create Secret of type `docker-registry` for DockerHub registry credentials from terminal with EKS cluster context as the current context
```bash
kubectl create secret docker-registry my-registry-key \
> --docker-server=docker.io \
> --docker-username=<docker_login_username> \
> --docker-password=<docker_login_password>

# confirm secret creation
kubectl get secret
```
- Make use of the secret created in deployment file in spec.template.spec by adding an `imagePullSecrets` block.
```yaml
imagePullSecrets:
    - name: my-registry-key
```
- Commit all changes to git and execute Jenkins pipeline.
