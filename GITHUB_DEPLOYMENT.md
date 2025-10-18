# GitHub Deployment Guide for Airbyte Source Cat Fact Connector

This guide walks you through deploying your Airbyte connector to GitHub with automated Docker builds and importing it into your Airbyte instance.

## Overview

This deployment setup includes:
- **GitHub Actions** for automated CI/CD
- **GitHub Container Registry (GHCR)** for Docker image hosting
- **Multi-platform builds** (AMD64 and ARM64)
- **Automated testing** and security scanning
- **Semantic versioning** support

## Prerequisites

- GitHub repository: `hennywell/airbyte-source-catfact`
- Docker installed locally
- Access to an Airbyte instance (local or cloud)

## Step 1: Push Code to GitHub

First, ensure all your changes are committed and pushed:

```bash
# Add all files
git add .

# Commit changes
git commit -m "Add GitHub Actions workflow and update documentation"

# Push to GitHub
git push origin main
```

## Step 2: GitHub Actions Setup

The GitHub Actions workflow (`.github/workflows/build-and-publish.yml`) will automatically:

1. **Run tests** on every push and pull request
2. **Build Docker images** for multiple platforms
3. **Push to GitHub Container Registry** (GHCR)
4. **Run security scans** with Trivy
5. **Tag images** based on Git tags and branches

### Workflow Triggers

- **Push to main/develop**: Builds and pushes with `latest` tag
- **Pull requests**: Builds and tests (no push)
- **Git tags** (v*): Creates versioned releases
- **Manual trigger**: Can be run manually from GitHub Actions tab

## Step 3: GitHub Container Registry Configuration

The workflow automatically configures GHCR using the `GITHUB_TOKEN`. No additional setup required!

### Image Naming Convention

- **Latest**: `ghcr.io/hennywell/airbyte-source-catfact:latest`
- **Branch**: `ghcr.io/hennywell/airbyte-source-catfact:main`
- **Version**: `ghcr.io/hennywell/airbyte-source-catfact:v1.0.0`

## Step 4: Create a Release

To create a versioned release:

```bash
# Create and push a version tag
git tag v0.1.0
git push origin v0.1.0
```

This will trigger a build with version tags: `v0.1.0`, `0.1`, `0`, and `latest`.

## Step 5: Monitor the Build

1. Go to your GitHub repository
2. Click on **Actions** tab
3. Watch the build progress
4. Verify all jobs complete successfully

## Step 6: Verify Docker Image

Once the build completes, verify the image is available:

```bash
# Pull the image
docker pull ghcr.io/hennywell/airbyte-source-catfact:latest

# Test the connector
echo '{}' | docker run --rm -i ghcr.io/hennywell/airbyte-source-catfact:latest check --config /dev/stdin

# Discover streams
echo '{}' | docker run --rm -i ghcr.io/hennywell/airbyte-source-catfact:latest discover --config /dev/stdin
```

## Step 7: Import to Airbyte

### For Airbyte Cloud

1. Log into [Airbyte Cloud](https://cloud.airbyte.com/)
2. Navigate to **Sources** → **New Source**
3. Select **Custom Connector** → **Add a new Docker connector**
4. Fill in the details:
   - **Connector display name**: `Cat Fact`
   - **Docker repository name**: `ghcr.io/hennywell/airbyte-source-catfact`
   - **Docker image tag**: `latest`
   - **Connector documentation URL**: `https://github.com/hennywell/airbyte-source-catfact`

### For Airbyte Open Source (Docker Compose)

1. Access your Airbyte instance (typically `http://localhost:8000`)
2. Navigate to **Settings** → **Sources**
3. Click **New connector** → **Add a new Docker connector**
4. Use the same details as above

### For Airbyte on Kubernetes/Minikube

If using kind (common with abctl):

```bash
# Load the image into the cluster
kind load docker-image ghcr.io/hennywell/airbyte-source-catfact:latest -n airbyte-abctl

# Restart Airbyte if needed
abctl local deployments --restart
```

If using standard Minikube:

```bash
# Load the image
minikube image load ghcr.io/hennywell/airbyte-source-catfact:latest

# Restart Airbyte pods if needed
kubectl rollout restart deployment -n airbyte
```

## Step 8: Configure the Connector

1. Create a new source using your custom connector
2. **Configuration**: Use an empty JSON object `{}` (no authentication required)
3. **Test connection**: Should succeed if the Cat Fact API is accessible
4. **Discover schema**: Should find `facts` and `breeds` streams

## Step 9: Set Up a Connection

1. Create or select a destination
2. Set up a connection between your Cat Fact source and destination
3. Configure sync settings:
   - **Sync mode**: Full refresh or Incremental (both supported)
   - **Schedule**: Set up regular syncs as needed
4. Run a test sync to verify data flows correctly

## Troubleshooting

### Build Failures

Check the GitHub Actions logs for specific error messages:

1. Go to **Actions** tab in your repository
2. Click on the failed workflow run
3. Expand the failed job to see detailed logs

### Image Pull Errors

If Airbyte can't pull the image:

1. Verify the image exists: `docker pull ghcr.io/hennywell/airbyte-source-catfact:latest`
2. Check if the repository is public or if authentication is needed
3. For private repositories, configure image pull secrets in Kubernetes

### Connector Not Appearing

If the connector doesn't appear in Airbyte:

1. Check Airbyte logs for errors
2. Restart Airbyte services
3. Verify the Docker image tag is correct
4. Ensure the image is accessible from your Airbyte instance

### Connection Test Failures

If the connection test fails:

1. Verify internet connectivity from Airbyte to `catfact.ninja`
2. Check if there are firewall restrictions
3. Test the API directly: `curl https://catfact.ninja/fact`

## Maintenance and Updates

### Updating the Connector

1. Make changes to your connector code
2. Commit and push to GitHub
3. Create a new version tag for releases
4. Update the connector in Airbyte with the new image tag

### Monitoring

- **GitHub Actions**: Monitor build status and failures
- **Security**: Review Trivy scan results in the Security tab
- **Performance**: Monitor sync performance in Airbyte
- **API**: Watch for changes to the Cat Fact API

## Security Considerations

- **Image Scanning**: Trivy automatically scans for vulnerabilities
- **Secrets**: Never commit API keys or sensitive data
- **Access**: Use least-privilege principles for GitHub tokens
- **Updates**: Keep base images and dependencies updated

## Next Steps

1. **Set up monitoring** for your connector in production
2. **Configure alerting** for failed syncs
3. **Document any custom configurations** for your team
4. **Consider contributing** to the Airbyte community if useful

## Resources

- [Airbyte Connector Development](https://docs.airbyte.com/connector-development/)
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [Cat Fact API](https://catfact.ninja/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)