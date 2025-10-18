# Deploying Source-Catfact Connector to Local Airbyte on Minikube

This guide provides step-by-step instructions for deploying your source-catfact connector to a local Airbyte instance running on Minikube.

## Prerequisites

Before you begin, ensure you have the following installed and configured:

- **Minikube** running with Airbyte deployed
- **kubectl** configured to communicate with your Minikube cluster
- **airbyte-ci** CLI tool installed
- **Docker** running locally

## Deployment Steps

### Step 1: Build Your Connector Docker Image

Build your connector using the airbyte-ci tool:

```bash
airbyte-ci connectors --name=source-catfact build
```

This creates a Docker image tagged as `airbyte/source-catfact:dev` on your local machine.

### Step 2: Verify the Image was Built

Check that your connector image was successfully built:

```bash
docker images ls | grep airbyte/source-catfact:dev
```

You should see output similar to:
```
airbyte/source-catfact    dev    <image-id>    <timestamp>    <size>
```

### Step 3: Load the Image into Minikube

Since Minikube runs in its own Docker environment, you need to load your locally built image into the cluster:

#### If using abctl with kind (common for local development):
```bash
kind load docker-image airbyte/source-catfact:dev -n airbyte-abctl
```

#### If using standard minikube:
```bash
minikube image load airbyte/source-catfact:dev
```

### Step 4: Configure kubectl for Your Cluster

If you're using abctl with kind, configure kubectl:

```bash
kind export kubeconfig -n airbyte-abctl
```

### Step 5: Verify Airbyte Pods are Running

Check that your Airbyte deployment is healthy:

```bash
kubectl get pods -n airbyte-abctl
```

All pods should be in `Running` or `Ready` state.

### Step 6: Access Airbyte UI and Deploy

1. Access your local Airbyte instance (typically at `http://localhost:8000` or the port you configured)
2. Navigate to **Sources** in the left sidebar
3. Click **+ New Source**
4. Look for your "Cat Fact" connector in the source type dropdown
5. If it appears, select it and proceed with configuration
6. Configure it with any required settings (the Cat Fact API doesn't require authentication)
7. Test the connection to ensure it can reach the Cat Fact API
8. Run a sync to verify data flows correctly

### Step 7: Restart Airbyte if Needed

If your connector doesn't automatically appear in the UI, restart the Airbyte deployments:

```bash
abctl local deployments --restart
```

## Development Workflow

For iterative development and testing:

1. **Make changes** to your connector code
2. **Rebuild** the connector:
   ```bash
   airbyte-ci connectors --name=source-catfact build
   ```
3. **Reload** the image into the cluster:
   ```bash
   kind load docker-image airbyte/source-catfact:dev -n airbyte-abctl
   ```
4. **Restart Airbyte** if needed:
   ```bash
   abctl local deployments --restart
   ```
5. **Test** in the Airbyte UI

## Troubleshooting

### Image Pull Errors
If you encounter image pull errors:
- Ensure the image was properly loaded into your cluster using the `kind load` or `minikube image load` command
- Verify the image exists locally with `docker images`

### Connector Not Appearing in UI
If your connector doesn't appear in the source dropdown:
- Check Airbyte webapp logs:
  ```bash
  kubectl logs -n airbyte-abctl deployment/airbyte-webapp
  ```
- Restart Airbyte deployments:
  ```bash
  abctl local deployments --restart
  ```

### Check Deployment Status
Monitor your Airbyte deployment status:
```bash
abctl local deployments
```

### View All Pods
Get an overview of all running pods:
```bash
kubectl get pods -n airbyte-abctl
```

## Testing Your Connector

Once deployed, your Cat Fact connector should:

1. **Connect successfully** to the Cat Fact API (`https://catfact.ninja`)
2. **Discover streams** including:
   - `facts` - Random cat facts
   - `breeds` - Cat breed information
3. **Sync data** without authentication requirements
4. **Handle pagination** if implemented
5. **Respect rate limits** of the Cat Fact API

## Next Steps

After successful deployment:

- **Monitor sync performance** in the Airbyte UI
- **Set up regular sync schedules** as needed
- **Configure destinations** to send cat facts to your preferred data warehouse
- **Review logs** for any issues or optimization opportunities

## Additional Resources

- [Airbyte Connector Development Documentation](https://docs.airbyte.com/connector-development/)
- [Cat Fact API Documentation](https://catfact.ninja/)
- [Airbyte Local Development Guide](https://docs.airbyte.com/contributing-to-airbyte/developing-locally)