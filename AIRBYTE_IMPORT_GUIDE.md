# Airbyte Import Guide for Cat Fact Connector

This guide provides step-by-step instructions for importing your Cat Fact connector into different Airbyte deployments.

## 🚀 Quick Start

Your connector is now available at:
- **Docker Image**: `ghcr.io/hennywell/airbyte-source-catfact:latest`
- **Versioned Image**: `ghcr.io/hennywell/airbyte-source-catfact:v0.1.0`
- **GitHub Repository**: https://github.com/hennywell/airbyte-source-catfact

## 📋 Prerequisites

Before importing, ensure:
- ✅ GitHub Actions build completed successfully
- ✅ Docker image is available in GHCR
- ✅ You have access to your Airbyte instance
- ✅ Your Airbyte instance can access GitHub Container Registry

## 🔍 Verify Build Status

1. Go to your GitHub repository: https://github.com/hennywell/airbyte-source-catfact
2. Click on the **Actions** tab
3. Verify the latest workflow run completed successfully
4. Check that both the main branch and v0.1.0 tag builds passed

## 🐳 Test Docker Image Availability

Run this command to verify the image is publicly available:

```bash
# Test the latest image
docker pull ghcr.io/hennywell/airbyte-source-catfact:latest

# Test the versioned image
docker pull ghcr.io/hennywell/airbyte-source-catfact:v0.1.0

# Quick test
echo '{}' | docker run --rm -i ghcr.io/hennywell/airbyte-source-catfact:latest check --config /dev/stdin
```

## 🌐 Import to Airbyte Cloud

### Step 1: Access Airbyte Cloud
1. Go to [Airbyte Cloud](https://cloud.airbyte.com/)
2. Log into your account
3. Select your workspace

### Step 2: Add Custom Connector
1. Navigate to **Sources** in the left sidebar
2. Click **+ New Source**
3. Scroll down and click **Custom Connector**
4. Select **Add a new Docker connector**

### Step 3: Configure Connector
Fill in the following details:

- **Connector display name**: `Cat Fact`
- **Docker repository name**: `ghcr.io/hennywell/airbyte-source-catfact`
- **Docker image tag**: `latest` (or `v0.1.0` for specific version)
- **Connector documentation URL**: `https://github.com/hennywell/airbyte-source-catfact`

### Step 4: Save and Test
1. Click **Add** to save the connector
2. The connector should now appear in your sources list
3. Create a new source using your Cat Fact connector
4. Use `{}` as the configuration (no authentication required)
5. Test the connection

## 🏠 Import to Airbyte Open Source (Docker Compose)

### Step 1: Access Airbyte UI
1. Open your Airbyte instance (typically `http://localhost:8000`)
2. Log in with your credentials

### Step 2: Add Custom Connector
1. Go to **Settings** → **Sources**
2. Click **New connector**
3. Select **Add a new Docker connector**

### Step 3: Configure Connector
Use the same configuration as Airbyte Cloud:

- **Connector display name**: `Cat Fact`
- **Docker repository name**: `ghcr.io/hennywell/airbyte-source-catfact`
- **Docker image tag**: `latest`
- **Connector documentation URL**: `https://github.com/hennywell/airbyte-source-catfact`

## ☸️ Import to Airbyte on Kubernetes

### For Kind Clusters (abctl)

```bash
# Load the image into the cluster
kind load docker-image ghcr.io/hennywell/airbyte-source-catfact:latest -n airbyte-abctl

# Restart Airbyte if needed
abctl local deployments --restart
```

### For Standard Minikube

```bash
# Load the image
minikube image load ghcr.io/hennywell/airbyte-source-catfact:latest

# Restart Airbyte pods
kubectl rollout restart deployment -n airbyte
```

### Using the Deployment Script

You can use the provided deployment script:

```bash
# For kind clusters
./scripts/deploy.sh deploy-kind

# For minikube
./scripts/deploy.sh deploy-minikube
```

## 🔧 Configure Your First Connection

### Step 1: Create Source
1. Click **+ New Source** in Airbyte
2. Select **Cat Fact** from the connector list
3. Give it a name (e.g., "Cat Facts API")
4. Configuration: Use `{}` (empty JSON object)
5. Test the connection - it should succeed

### Step 2: Discover Schema
After successful connection test:
1. Click **Set up source**
2. Airbyte will discover available streams:
   - `cat_facts_stream` - Random cat facts
   - `cat_breeds_stream` - Cat breed information

### Step 3: Create Destination
1. Set up a destination (e.g., Local JSON, PostgreSQL, BigQuery)
2. Configure the destination connection details

### Step 4: Create Connection
1. Go to **Connections** → **+ New Connection**
2. Select your Cat Fact source
3. Select your destination
4. Configure sync settings:
   - **Sync frequency**: Choose how often to sync
   - **Destination Namespace**: Optional namespace for your data
   - **Streams**: Enable the streams you want to sync

### Step 5: Run Your First Sync
1. Click **Set up connection**
2. The connection will be created and an initial sync will start
3. Monitor the sync progress in the connection dashboard

## 📊 Expected Data

### Cat Facts Stream
```json
{
  "fact": "A cat's hearing is better than a dog's. And a cat can hear high-frequency sounds up to two octaves higher than a human.",
  "length": 134
}
```

### Cat Breeds Stream
```json
{
  "breed": "Abyssinian",
  "country": "Ethiopia",
  "origin": "Natural/Standard",
  "coat": "Short",
  "pattern": "Ticked"
}
```

## 🔍 Troubleshooting

### Image Pull Errors
If Airbyte can't pull the image:

1. **Verify image exists**:
   ```bash
   docker pull ghcr.io/hennywell/airbyte-source-catfact:latest
   ```

2. **Check repository visibility**: Ensure the GitHub repository is public

3. **For Kubernetes**: Make sure the image is loaded into the cluster

### Connection Test Failures
If the connection test fails:

1. **Check API accessibility**:
   ```bash
   curl https://catfact.ninja/fact
   ```

2. **Verify network connectivity** from your Airbyte instance

3. **Check Airbyte logs** for specific error messages

### Connector Not Appearing
If the connector doesn't appear in the UI:

1. **Restart Airbyte services**
2. **Check the Docker image tag** is correct
3. **Verify the image is accessible** from your Airbyte instance

## 🔄 Updating the Connector

To update your connector:

1. **Make changes** to your connector code
2. **Commit and push** to GitHub
3. **Create a new tag** for versioned releases:
   ```bash
   git tag v0.1.1
   git push origin v0.1.1
   ```
4. **Update the image tag** in Airbyte connector settings
5. **Test the updated connector**

## 📈 Monitoring and Maintenance

### Monitor Sync Performance
- Check sync duration and success rates
- Monitor data volume and API response times
- Set up alerts for failed syncs

### API Rate Limiting
The Cat Fact API doesn't have explicit rate limits, but consider:
- Reasonable sync frequencies
- Monitoring for API changes
- Implementing backoff strategies if needed

### Security Updates
- Regularly update base Docker images
- Monitor security scan results in GitHub
- Keep dependencies updated

## 🎯 Next Steps

1. **Set up regular syncs** for your data pipeline
2. **Configure destinations** for your specific use case
3. **Monitor connector performance** and logs
4. **Consider contributing** improvements back to the community
5. **Document any custom configurations** for your team

## 📚 Additional Resources

- [Airbyte Documentation](https://docs.airbyte.com/)
- [Custom Connector Guide](https://docs.airbyte.com/connector-development/)
- [Cat Fact API](https://catfact.ninja/)
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)

## 🆘 Support

If you encounter issues:

1. **Check the GitHub Issues**: https://github.com/hennywell/airbyte-source-catfact/issues
2. **Review Airbyte logs** for error details
3. **Test the connector locally** using the deployment script
4. **Verify API accessibility** from your environment

---

**Congratulations!** 🎉 You've successfully deployed your Airbyte connector to GitHub with automated CI/CD and are ready to import it into your Airbyte instance.