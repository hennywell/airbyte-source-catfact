# Uploading Docker-based custom connectors

Copy Page

CoreStandardProEnterprise FlexSelf-Managed Enterprise[ Compare](https://airbyte.com/product/features)

info

This guide walks through the setup of a Docker-based custom connector. To understand how to use our low-code connector builder, read our guide [here](/platform/connector-development/connector-builder-ui/overview.md).

If our connector catalog does not fulfill your needs, you can build your own Airbyte connectors! You can either use our [low-code connector builder](/platform/connector-development/connector-builder-ui/overview.md) or upload a Docker-based custom connector.

This page walks through the process to upload a **Docker-based custom connector**. This is an ideal route for connectors that have an **internal** use case like a private API with a specific fit for your organization. This guide for using Docker-based custom connectors assumes the following:

* You followed our other guides and tutorials about [connector development](/platform/connector-development/connector-builder-ui/overview.md)
* You finished your connector development and have it running locally on an Airbyte development instance.
* You want to deploy this connector to a production Airbyte instance running on a VM with docker-compose or on a Kubernetes cluster.

If you prefer video tutorials, we recorded a demo on how to upload [connectors images to a GCP Artifact Registry](https://www.youtube.com/watch?v=4YF20PODv30\&ab_channel=Airbyte).

## 1. Create a private Docker registry[​](#1-create-a-private-docker-registry "Direct link to 1. Create a private Docker registry")

Airbyte needs to pull its Docker images from a remote Docker registry to consume a connector. You should host your custom connectors image on a private Docker registry. Here are some resources to create a private Docker registry, in case your organization does not already have one:

| Cloud provider | Service name                | Documentation                                                                                                                                                                                                                                                                                  |
| -------------- | --------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Google Cloud   | Artifact Registry           | [Quickstart](https://cloud.google.com/artifact-registry/docs/docker/quickstart)                                                                                                                                                                                                                |
| AWS            | Amazon ECR                  | [Getting started with Amazon ECR](https://docs.aws.amazon.com/AmazonECR/latest/userguide/getting-started-console.html)                                                                                                                                                                         |
| Azure          | Container Registry          | [Quickstart](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-get-started-portal#:~:text=Azure%20Container%20Registry%20is%20a,container%20images%20and%20related%20artifacts.\&text=Then%2C%20use%20Docker%20commands%20to,the%20image%20from%20your%20registry.) |
| DockerHub      | Repositories                | [DockerHub Quickstart](https://docs.docker.com/docker-hub/)                                                                                                                                                                                                                                    |
| GitHub         | Container Registry          | [Working with the Container registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)                                                                                                                                         |
| Self hosted    | Open-source Docker Registry | [Deploy a registry server](https://docs.docker.com/registry/deploying/)                                                                                                                                                                                                                        |

## 2. Authenticate to your private Docker registry[​](#2-authenticate-to-your-private-docker-registry "Direct link to 2. Authenticate to your private Docker registry")

To push and pull images to your private Docker registry, you need to authenticate to it:

* Your local or CI environment (where you build your connector image) must be able to **push** images to your registry.
* Your Airbyte instance must be able to **pull** images from your registry.

## 3. Adhere to Airbyte's Docker Image Requirements[​](#3-adhere-to-airbytes-docker-image-requirements "Direct link to 3. Adhere to Airbyte's Docker Image Requirements")

See the [Airbyte Protocol Docker Interface](/platform/understanding-airbyte/airbyte-protocol-docker.md) page for specific Docker image requirements, such as required environment variables.

### For Docker-compose Airbyte deployments[​](#for-docker-compose-airbyte-deployments "Direct link to For Docker-compose Airbyte deployments")

#### On GCP - Artifact Registry:[​](#on-gcp---artifact-registry "Direct link to On GCP - Artifact Registry:")

GCP offers the `gcloud` credential helper to log in to your Artifact registry. Please run the command detailed [here](https://cloud.google.com/artifact-registry/docs/docker/quickstart#auth) to authenticate your local environment/CI environment to your Artifact registry. Run the same authentication flow on your Compute Engine instance. If you do not want to use `gcloud`, GCP offers other authentication methods detailed [here](https://cloud.google.com/artifact-registry/docs/docker/authentication).

#### On AWS - Amazon ECR:[​](#on-aws---amazon-ecr "Direct link to On AWS - Amazon ECR:")

You can authenticate to an ECR private registry using the `aws` CLI: `aws ecr get-login-password --region region | docker login --username AWS --password-stdin aws_account_id.dkr.ecr.region.amazonaws.com` You can find details about this command and other available authentication methods [here](https://docs.aws.amazon.com/AmazonECR/latest/userguide/registry_auth.html). You will have to authenticate your local/CI environment (where you build your image) **and** your EC2 instance where your Airbyte instance is running.

#### On Azure - Container Registry:[​](#on-azure---container-registry "Direct link to On Azure - Container Registry:")

You can authenticate to an Azure Container Registry using the `az` CLI: `az acr login --name <registry-name>` You can find details about this command [here](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-get-started-portal#:~:text=Azure%20Container%20Registry%20is%20a,container%20images%20and%20related%20artifacts.\&text=Then,%20use%20Docker%20commands%20to,the%20image%20from%20your%20registry.) You will have to authenticate both your local/CI environment/ environment (where your image is built) **and** your Azure Virtual Machine instance where the Airbyte instance is running.

#### On DockerHub - Repositories:[​](#on-dockerhub---repositories "Direct link to On DockerHub - Repositories:")

You can use Docker Desktop to authenticate your local machine to your DockerHub registry by signing in on the desktop application using your DockerID. You need to use a [service account](https://docs.docker.com/docker-hub/service-accounts/) to authenticate your Airbyte instance to your DockerHub registry.

#### Self hosted - Open source Docker Registry:[​](#self-hosted---open-source-docker-registry "Direct link to Self hosted - Open source Docker Registry:")

It would be best to set up auth on your Docker registry to make it private. Available authentication options for an open-source Docker registry are listed [here](https://docs.docker.com/registry/configuration/#auth). To authenticate your local/CI environment and Airbyte instance you can use the [`docker login`](https://docs.docker.com/engine/reference/commandline/login/) command.

### For Kubernetes Airbyte deployments[​](#for-kubernetes-airbyte-deployments "Direct link to For Kubernetes Airbyte deployments")

You can use the previous section's authentication flow to authenticate your local/CI to your private Docker registry. If you provisioned your Kubernetes cluster using AWS EKS, GCP GKE, or Azure AKS: it is very likely that you already allowed your cluster to pull images from the respective container registry service of your cloud provider. If you want Airbyte to pull images from another private Docker registry, you will have to do the following:

1. Create a `Secret` in Kubernetes that will host your authentication credentials. [This Kubernetes documentation](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/) explains how to proceed.
2. Set the `JOB_KUBE_MAIN_CONTAINER_IMAGE_PULL_SECRET` environment variable on the `airbyte-worker` pod. The value must be **the name of your previously created Kubernetes Secret**.

## 3. Push your connector image to your private Docker registry[​](#3-push-your-connector-image-to-your-private-docker-registry "Direct link to 3. Push your connector image to your private Docker registry")

1. Build and tag your connector image locally, e.g.: `docker build . -t my-custom-connectors/source-custom:0.1.0`
2. Create your image tag with `docker tag` command. The structure of the remote tag depends on your cloud provider's container registry service. Please check their online documentation linked at the top.
3. Use `docker push <image-name>:<tag>` to push the image to your private Docker registry.

You should run all the above commands from your local/CI environment, where your connector source code is available.

## 4. Use your custom Docker connector in Airbyte[​](#4-use-your-custom-docker-connector-in-airbyte "Direct link to 4. Use your custom Docker connector in Airbyte")

At this step, you should have:

* A private Docker registry hosting your custom connector image.
* Authenticated your Airbyte instance to your private Docker registry.

You can pull your connector image from your private registry to validate the previous steps. On your Airbyte instance: run `docker pull <image-name>:<tag>` if you are using our `docker-compose` deployment, or start a pod that is using the connector image.

1. Click **Workspace settings** > **Sources**/**Destinations** depending on your connector. Click **New connector** > **Add a new Docker connector**.

2. Name your custom connector in `Connector display name`. This is just the display name used for your workspace.

3. Fill in the Docker `Docker full image name` and `Docker image tag`.

4. (Optional) Add a link to connector's documentation in `Connector documentation URL` You can optionally fill this with any value if you do not have online documentation for your connector. This documentation will be linked in your connector setting's page.

5. `Add` the connector to save the configuration. You can now select your new connector when setting up a new connection!

# Troubleshooting

## Loading connector docker containers into kind[​](#loading-connector-docker-containers-into-kind "Direct link to Loading connector docker containers into kind")

If you are running Airbyte in kind (kubernetes in docker -- this is the default method for abctl), you must load the docker image of that connector into the cluster. If you are seeing the following error, it likely means that the docker image has not been properly loaded into the cluster.

![Screenshot of UI error when custom connector container is not loaded in the cluster](/assets/images/custom-connector-error1-98c571a5383e4f956b491d77c762dec8.png)

![Screenshot of K8s error when custom connector container is not loaded in the cluster](data:image/png;base64,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)

A connector container can be loaded using the following command:

```
kind load docker-image <image-name>:<image-tag> -n airbyte-abctl
```

For the example above, the command would be:

```
kind load docker-image airbyte/source-custom:1 -n airbyte-abctl
```