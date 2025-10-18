# Airbyte Source Cat Fact Connector

A custom Airbyte source connector for the Cat Fact API (catfact.ninja) that provides random cat facts and breed information.

## Features

- **No Authentication Required**: The Cat Fact API is free and doesn't require API keys
- **Two Data Streams**:
  - `facts` - Random cat facts with length information
  - `breeds` - Cat breed information including country, origin, coat, and pattern details
- **Full Airbyte Protocol Support**: Compatible with all Airbyte sync modes
- **Built with Airbyte CDK**: Uses the official Airbyte Python CDK v0.80.0

## Quick Start

### Using Docker

```bash
# Pull the image
docker pull ghcr.io/hennywell/airbyte-source-catfact:latest

# Test connection
echo '{}' | docker run --rm -i ghcr.io/hennywell/airbyte-source-catfact:latest check --config /dev/stdin

# Discover available streams
echo '{}' | docker run --rm -i ghcr.io/hennywell/airbyte-source-catfact:latest discover --config /dev/stdin
```

### Using in Airbyte

1. In your Airbyte instance, go to **Sources** → **New Source**
2. Select **Custom Connector** → **Add a new Docker connector**
3. Fill in the details:
   - **Connector display name**: Cat Fact
   - **Docker repository name**: `ghcr.io/hennywell/airbyte-source-catfact`
   - **Docker image tag**: `latest`
   - **Connector documentation URL**: `https://github.com/hennywell/airbyte-source-catfact`

## Configuration

This connector requires no configuration as the Cat Fact API is free and public. Simply provide an empty JSON object `{}` as the configuration.

## Supported Streams

### Facts Stream
- **Description**: Random cat facts
- **Primary Key**: None (facts are random)
- **Schema**:
  ```json
  {
    "fact": "string",
    "length": "integer"
  }
  ```

### Breeds Stream
- **Description**: Cat breed information
- **Primary Key**: `breed`
- **Schema**:
  ```json
  {
    "breed": "string",
    "country": "string", 
    "origin": "string",
    "coat": "string",
    "pattern": "string"
  }
  ```

## Development

### Prerequisites

- Python 3.9+
- Poetry
- Docker

### Local Development

```bash
# Clone the repository
git clone https://github.com/hennywell/airbyte-source-catfact.git
cd airbyte-source-catfact

# Install dependencies
poetry install

# Run tests
poetry run pytest

# Build Docker image
docker build -t airbyte/source-catfact:dev .
```

### Testing the Connector

```bash
# Test connection
echo '{}' | docker run --rm -i airbyte/source-catfact:dev check --config /dev/stdin

# Discover streams
echo '{}' | docker run --rm -i airbyte/source-catfact:dev discover --config /dev/stdin

# Read data (requires catalog.json)
docker run --rm -v $(pwd):/data airbyte/source-catfact:dev read --config /data/config.json --catalog /data/catalog.json
```

## API Reference

This connector uses the [Cat Fact API](https://catfact.ninja/):
- **Base URL**: https://catfact.ninja
- **Rate Limits**: No explicit rate limits
- **Authentication**: None required

### Endpoints Used

- `GET /fact` - Get a random cat fact
- `GET /facts` - Get multiple cat facts
- `GET /breeds` - Get cat breed information

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- **Issues**: [GitHub Issues](https://github.com/hennywell/airbyte-source-catfact/issues)
- **Cat Fact API**: [catfact.ninja](https://catfact.ninja/)
- **Airbyte Documentation**: [docs.airbyte.com](https://docs.airbyte.com/)# airbyte-source-catfact
