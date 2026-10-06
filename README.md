# Complete CI/CD Pipeline with EKS and ECR

This project focuses on pushing docker image to ECR in the `build image` stage and also pulling docker image from this same registry in the `deploy` stage instead of the DockerHub private registry used in the `complete-ci-cd-with-eks-and-docker` git branch.

## Tech Stack

**Cloud Infrastructure/Services:** AWS EKS, AWS ECR

**Tools:** Kubernetes, Jenkins, Java, Maven, Linux, Docker, Git

## Steps

- In AWS management console, go to ECR and create an ECR repo, named java-maven-app in my case.
- Create the following global credentials in Jenkins and load them as environment variables at the top of the pipeline:
  - `jenkins-aws-access-key-id` and `jenkins-secret-access-key` (secret text): access keys of an IAM user that can push to ECR and has access to the EKS cluster.
  - `aws_account_id` (secret text): used to build the registry URL `ECR_REGISTRY`.

```groovy
environment {
    AWS_ACCESS_KEY_ID     = credentials('jenkins-aws-access-key-id')
    AWS_SECRET_ACCESS_KEY = credentials('jenkins-secret-access-key')
    AWS_ACCOUNT_ID        = credentials('aws_account_id')
    AWS_REGION            = 'us-east-1'
    ECR_REGISTRY          = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
}
```

- Adjust increment version stage to use docker style naming for `IMAGE_NAME` env variable set in this stage

```groovy
env.IMAGE_NAME = "${ECR_REGISTRY}/java-maven-app:$version-$BUILD_NUMBER"
```

- In the `build image` stage, log in to ECR with a fresh token on every build instead of a token saved as a Jenkins credential. ECR tokens are only valid for 12 hours, so a saved token had to be renewed manually.

```bash
aws ecr get-login-password --region "$AWS_REGION" \
| docker login --username AWS --password-stdin "$ECR_REGISTRY"

docker build -t "$IMAGE_NAME" .
docker push "$IMAGE_NAME"
```

- Create a Deployment and a Service configuration for the deployment of app image pushed to ECR repo in the `build image` stage of this pipeline. The files are in `kubernetes` directory.
- Set resource requests and limits on the container in the deployment file to prevent the noisy neighbour problem. Requests reserve CPU and memory for each pod so the scheduler only places it on a node with enough capacity, and limits cap what the container can use so it can't starve other pods on the same node. A container that goes over its CPU limit is throttled, and one that goes over its memory limit is killed (OOMKilled) and restarted.

```yaml
resources:
  requests:
    cpu: "250m"
    memory: "256Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"
```

- Reference the image pull secret in the deployment file in spec.template.spec by adding an `imagePullSecrets` block.

```yaml
imagePullSecrets:
  - name: aws-registry-key
```

- In the `deploy` stage, point kubectl at the EKS cluster, then create or refresh the `aws-registry-key` secret with a fresh ECR token before applying the manifests. This replaces the secret that was previously created manually from the terminal. `kubectl create --dry-run=client -o yaml | kubectl apply -f -` creates the secret on the first run and updates it on later runs.

```bash
aws eks update-kubeconfig --region "$AWS_REGION" --name "$CLUSTER_NAME"

ECR_TOKEN="$(aws ecr get-login-password --region "$AWS_REGION")"

kubectl create secret docker-registry aws-registry-key \
  --docker-server="$ECR_REGISTRY" \
  --docker-username=AWS \
  --docker-password="$ECR_TOKEN" \
  --dry-run=client -o yaml | kubectl apply -f -

envsubst < kubernetes/deployment.yaml | kubectl apply -f -
envsubst < kubernetes/service.yaml | kubectl apply -f -

kubectl rollout status deployment/"$APP_NAME" --timeout=180s
```

> **Note:** the refreshed secret is still only valid for 12 hours after each deploy. If a pod restarts or is rescheduled after that, the image pull fails until the pipeline runs again. Attaching the `AmazonEC2ContainerRegistryReadOnly` policy to the node IAM role removes the need for the secret entirely.

- In the `commit version update` stage, only `pom.xml` is committed (`git add pom.xml`), so files generated in the workspace during the build, such as the kubeconfig in `.kube/`, are not pushed to the repo.
- Commit all changes to git and execute Jenkins pipeline.

## Screenshots

![Jenkins pipeline successful branch builds](https://res.cloudinary.com/dpav6x91z/image/upload/v1788449166/Screenshot_2026-09-03_172213_npbgrz.png)
![deploy resources created in EKS](https://res.cloudinary.com/dpav6x91z/image/upload/v1788449169/Screenshot_2026-09-03_172353_tzjmvh.png)
![ecr java-maven-app repo](https://res.cloudinary.com/dpav6x91z/image/upload/v1788449171/Screenshot_2026-09-03_172500_t61syl.png)
