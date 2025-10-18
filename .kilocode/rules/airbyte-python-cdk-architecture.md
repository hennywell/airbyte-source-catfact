# Airbyte Python CDK Architecture Guide (Versions 1.7-2.0)

This document provides a comprehensive guide to understanding the Airbyte Python CDK architecture and core components for versions 1.7 through 2.0. The CDK (Connector Development Kit) is a framework that simplifies building Airbyte connectors by providing reusable components and abstractions.

## Overview

The Airbyte Python CDK is designed around a modular architecture that supports multiple connector types:

- **API Source Connectors**: For HTTP-based data sources
- **File-Based Source Connectors**: For file systems like S3, GCS, etc.
- **Declarative/Low-Code Connectors**: YAML-based configuration approach
- **Destination Connectors**: Including vector database destinations
- **Concurrent Connectors**: For high-throughput parallel processing

## Core Architecture Components

### 1. AbstractSource - The Foundation

[`AbstractSource`](airbyte_cdk/sources/abstract_source.py) is the base class for all source connectors:

```python
from airbyte_cdk.sources import AbstractSource
from airbyte_cdk.sources.streams import Stream
from typing import List, Mapping, Tuple, Any, Optional
import logging

class SourceMyApi(AbstractSource):
    def check_connection(self, logger: logging.Logger, config: Mapping[str, Any]) -> Tuple[bool, Optional[Any]]:
        """Verify connection can be established with provided config"""
        try:
            api_token = config.get("api_token")
            response = requests.get("https://api.example.com/health",
                                   headers={"Authorization": f"Bearer {api_token}"})
            response.raise_for_status()
            return True, None
        except Exception as e:
            return False, f"Connection failed: {str(e)}"

    def streams(self, config: Mapping[str, Any]) -> List[Stream]:
        """Return list of Stream instances for this source"""
        return [
            UsersStream(config),
            OrdersStream(config),
            ProductsStream(config)
        ]
```

**Key Responsibilities:**
- **Connection validation**: [`check_connection()`](airbyte_cdk/sources/abstract_source.py:check_connection) method validates credentials and connectivity
- **Stream discovery**: [`streams()`](airbyte_cdk/sources/abstract_source.py:streams) method returns available data streams
- **Configuration management**: Handles connector-specific configuration parameters

### 2. HttpStream - HTTP API Integration

[`HttpStream`](airbyte_cdk/sources/streams/http/http.py) provides the foundation for HTTP-based data sources:

```python
from airbyte_cdk.sources.streams.http import HttpStream
from typing import Any, Iterable, Mapping, Optional
import requests

class UsersStream(HttpStream):
    url_base = "https://api.example.com/v1/"
    primary_key = "id"
    http_method = "GET"

    def path(self, stream_state: Optional[Mapping[str, Any]] = None,
             stream_slice: Optional[Mapping[str, Any]] = None,
             next_page_token: Optional[Mapping[str, Any]] = None) -> str:
        return "users"

    def request_headers(self, **kwargs) -> Mapping[str, str]:
        return {
            "Authorization": f"Bearer {self.api_key}",
            "Accept": "application/json"
        }

    def request_params(self, stream_state: Optional[Mapping[str, Any]] = None,
                      stream_slice: Optional[Mapping[str, Any]] = None,
                      next_page_token: Optional[Mapping[str, Any]] = None) -> Mapping[str, Any]:
        params = {"limit": 100}
        if next_page_token:
            params["cursor"] = next_page_token["cursor"]
        if stream_state and stream_state.get("updated_at"):
            params["since"] = stream_state["updated_at"]
        return params

    def next_page_token(self, response: requests.Response) -> Optional[Mapping[str, Any]]:
        data = response.json()
        next_cursor = data.get("pagination", {}).get("next_cursor")
        return {"cursor": next_cursor} if next_cursor else None

    def parse_response(self, response: requests.Response, **kwargs) -> Iterable[Mapping[str, Any]]:
        data = response.json()
        yield from data.get("users", [])

    def should_retry(self, response: requests.Response) -> bool:
        """Custom retry logic for rate limiting and server errors"""
        if response.status_code == 429 or response.status_code >= 500:
            return True
        return super().should_retry(response)

    def backoff_time(self, response: requests.Response) -> Optional[float]:
        retry_after = response.headers.get("Retry-After")
        return float(retry_after) if retry_after else 60
```

**Key Features:**
- **Request building**: [`path()`](airbyte_cdk/sources/streams/http/http.py:path), [`request_headers()`](airbyte_cdk/sources/streams/http/http.py:request_headers), [`request_params()`](airbyte_cdk/sources/streams/http/http.py:request_params)
- **Pagination support**: [`next_page_token()`](airbyte_cdk/sources/streams/http/http.py:next_page_token) for cursor-based pagination
- **Response parsing**: [`parse_response()`](airbyte_cdk/sources/streams/http/http.py:parse_response) extracts records from API responses
- **Error handling**: [`should_retry()`](airbyte_cdk/sources/streams/http/http.py:should_retry), [`backoff_time()`](airbyte_cdk/sources/streams/http/http.py:backoff_time) for resilient API calls
- **Authentication**: Integrated with various authenticator classes

### 3. IncrementalMixin - State Management

[`IncrementalMixin`](airbyte_cdk/sources/streams/core.py) enables incremental data synchronization:

```python
from airbyte_cdk.sources.streams import IncrementalMixin
from airbyte_cdk.sources.streams.http import HttpStream
from typing import Any, Mapping, MutableMapping, Optional

class IncrementalUsersStream(HttpStream, IncrementalMixin):
    url_base = "https://api.example.com/v1/"
    primary_key = "id"
    cursor_field = "updated_at"

    def __init__(self, config: Mapping[str, Any], **kwargs):
        super().__init__(**kwargs)
        self._cursor_value = None

    @property
    def state(self) -> MutableMapping[str, Any]:
        """State getter - returns current cursor value"""
        if self._cursor_value:
            return {self.cursor_field: self._cursor_value}
        return {}

    @state.setter
    def state(self, value: MutableMapping[str, Any]):
        """State setter - restores cursor from previous sync"""
        self._cursor_value = value.get(self.cursor_field)

    def read_records(self, stream_state: Optional[Mapping[str, Any]] = None, **kwargs):
        """Override to update cursor as records are read"""
        for record in super().read_records(stream_state=stream_state, **kwargs):
            if self.cursor_field in record:
                cursor_value = record[self.cursor_field]
                if not self._cursor_value or cursor_value > self._cursor_value:
                    self._cursor_value = cursor_value
            yield record
```

**Key Capabilities:**
- **State persistence**: [`state`](airbyte_cdk/sources/streams/core.py:state) property manages sync checkpoints
- **Cursor tracking**: Automatically updates cursor values during data reading
- **Resume capability**: Supports resuming syncs from last successful position

### 4. FileBasedSource - File System Integration

[`FileBasedSource`](airbyte_cdk/sources/file_based/file_based_source.py) handles file-based data sources:

```python
from airbyte_cdk.sources.file_based import FileBasedSource, AbstractFileBasedSpec
from airbyte_cdk.sources.file_based.stream_reader import AbstractFileBasedStreamReader

class SourceS3(FileBasedSource):
    def __init__(self):
        super().__init__(
            stream_reader=S3StreamReader(),
            spec_class=S3Config,
            catalog_path="catalog.json"
        )

class S3Config(AbstractFileBasedSpec):
    bucket: str
    aws_access_key_id: str
    aws_secret_access_key: str
    region_name: str = "us-east-1"
    prefix: str = ""
    file_type: str = "csv"  # csv, jsonl, parquet, avro
    streams: List[dict]  # Stream definitions with glob patterns
```

**Architecture Components:**
- **Stream readers**: [`AbstractFileBasedStreamReader`](airbyte_cdk/sources/file_based/stream_reader.py) implementations for different storage systems
- **File discovery**: Glob pattern matching for file selection
- **Format support**: CSV, JSON, Parquet, Avro, and more
- **Schema inference**: Automatic schema detection from file contents

### 5. DeclarativeSource - Low-Code Approach

[`DeclarativeSource`](airbyte_cdk/sources/declarative/declarative_source.py) enables YAML-based connector definitions:

```yaml
version: 3.9.6
type: DeclarativeSource

definitions:
  requester:
    type: HttpRequester
    url_base: "https://api.example.com/v1/"
    http_method: "GET"
    authenticator:
      type: BearerAuthenticator
      api_token: "{{ config['api_token'] }}"

  paginator:
    type: DefaultPaginator
    pagination_strategy:
      type: CursorPagination
      cursor_value: "{{ response.pagination.next_cursor }}"
      stop_condition: "{{ not response.pagination.next_cursor }}"

  incremental_sync:
    type: DatetimeBasedCursor
    cursor_field: "updated_at"
    datetime_format: "%Y-%m-%dT%H:%M:%SZ"
    start_datetime:
      datetime: "{{ config['start_date'] }}"
      datetime_format: "%Y-%m-%d"

  users_stream:
    type: DeclarativeStream
    name: "users"
    primary_key: "id"
    retriever:
      type: SimpleRetriever
      requester:
        $ref: "#/definitions/requester"
      paginator:
        $ref: "#/definitions/paginator"
    incremental_sync:
      $ref: "#/definitions/incremental_sync"

streams:
  - $ref: "#/definitions/users_stream"
```

**Key Benefits:**
- **No-code development**: Define connectors using YAML configuration
- **Component reusability**: Shared definitions across multiple streams
- **Jinja templating**: Dynamic configuration using [`{{ config['field'] }}`](airbyte_cdk/sources/declarative/interpolation/jinja.py) syntax
- **Built-in components**: Pre-built authenticators, paginators, and cursors

### 6. Authentication Framework

The CDK provides multiple authentication mechanisms:

#### Bearer Token Authentication
```python
from airbyte_cdk.sources.streams.http.requests_native_auth import TokenAuthenticator

class UsersStream(HttpStream):
    def __init__(self, config, **kwargs):
        super().__init__(
            authenticator=TokenAuthenticator(token=config["api_token"]),
            **kwargs
        )
```

#### OAuth2 Authentication
```python
from airbyte_cdk.sources.streams.http.requests_native_auth import Oauth2Authenticator

class OAuth2Stream(HttpStream):
    def __init__(self, config, **kwargs):
        super().__init__(
            authenticator=Oauth2Authenticator(
                token_refresh_endpoint="https://api.example.com/oauth/token",
                client_id=config["client_id"],
                client_secret=config["client_secret"],
                refresh_token=config["refresh_token"],
                scopes=["read:data"]
            ),
            **kwargs
        )
```

#### Custom Authentication
```python
from requests.auth import AuthBase

class CustomAuth(AuthBase):
    def __init__(self, api_key: str, secret: str):
        self.api_key = api_key
        self.secret = secret

    def __call__(self, request):
        # Add custom authentication headers
        timestamp = str(int(time.time()))
        signature = hmac.new(
            self.secret.encode(),
            f"{timestamp}{request.url}".encode(),
            hashlib.sha256
        ).hexdigest()
        
        request.headers["X-API-Key"] = self.api_key
        request.headers["X-Timestamp"] = timestamp
        request.headers["X-Signature"] = signature
        return request
```

### 7. Concurrent Processing (CDK 2.0+)

[`ConcurrentSource`](airbyte_cdk/sources/concurrent_source/concurrent_source.py) enables parallel data processing:

```python
from airbyte_cdk.sources.concurrent_source import ConcurrentSource
from airbyte_cdk.sources.streams.concurrent.default_stream import DefaultStream
from airbyte_cdk.sources.streams.concurrent.partitions.partition_generator import PartitionGenerator

class DatePartitionGenerator(PartitionGenerator):
    def generate(self) -> Iterable[Partition]:
        """Generate daily partitions for parallel processing"""
        current = self.start_date
        while current <= self.end_date:
            next_day = current + timedelta(days=1)
            yield DatePartition(
                stream_name=self.stream_name,
                _partition={
                    "start": current.isoformat(),
                    "end": next_day.isoformat()
                }
            )
            current = next_day

class MyConcurrentStream(DefaultStream):
    def __init__(self, config: Mapping[str, Any], **kwargs):
        partition_generator = DatePartitionGenerator(
            start_date=datetime.fromisoformat(config["start_date"]),
            end_date=datetime.now(),
            stream_name="users"
        )
        super().__init__(
            partition_generator=partition_generator,
            name="users",
            json_schema=self._get_json_schema(),
            primary_key=["id"],
            cursor_field="updated_at",
            **kwargs
        )
```

**Concurrency Features:**
- **Partition-based processing**: Split data into parallel-processable chunks
- **Thread pool execution**: Configurable worker threads
- **State management**: Per-partition state tracking
- **Error isolation**: Failures in one partition don't affect others

## Data Flow Architecture

### 1. Sync Process Flow

```
1. Configuration Validation
   ↓
2. Connection Check (check_connection)
   ↓
3. Stream Discovery (streams method)
   ↓
4. Schema Discovery (get_json_schema)
   ↓
5. Data Reading (read_records)
   ↓
6. State Management (IncrementalMixin)
   ↓
7. Output Generation (AirbyteMessage)
```

### 2. Stream Processing Pipeline

```
HTTP Request → Authentication → Rate Limiting → Response Parsing → Record Transformation → State Update → Output
```

### 3. Error Handling Flow

```
API Error → Retry Logic → Backoff Strategy → Error Classification → Recovery or Failure
```

## Configuration and Specification

### Connector Specification
```python
def spec(self) -> AirbyteConnectionSpecification:
    return AirbyteConnectionSpecification(
        connectionSpecification={
            "type": "object",
            "required": ["api_token"],
            "properties": {
                "api_token": {
                    "type": "string",
                    "title": "API Token",
                    "description": "Your API authentication token",
                    "airbyte_secret": True
                },
                "start_date": {
                    "type": "string",
                    "title": "Start Date",
                    "description": "UTC date to start syncing from",
                    "pattern": "^[0-9]{4}-[0-9]{2}-[0-9]{2}$",
                    "examples": ["2024-01-01"]
                }
            }
        }
    )
```

### Stream Configuration
```python
def get_json_schema(self) -> Mapping[str, Any]:
    return {
        "$schema": "http://json-schema.org/draft-07/schema#",
        "type": "object",
        "properties": {
            "id": {"type": "integer"},
            "name": {"type": "string"},
            "email": {"type": "string", "format": "email"},
            "updated_at": {"type": "string", "format": "date-time"}
        }
    }
```

## Testing Framework

### Unit Testing
```python
def test_parse_response():
    """Test stream parses API response correctly"""
    stream = UsersStream(config={"api_token": "test_token"})
    
    mock_response = Mock()
    mock_response.json.return_value = {
        "users": [
            {"id": 1, "name": "Alice", "email": "alice@example.com"},
            {"id": 2, "name": "Bob", "email": "bob@example.com"}
        ]
    }
    
    records = list(stream.parse_response(mock_response))
    assert len(records) == 2
    assert records[0]["id"] == 1
    assert records[1]["name"] == "Bob"
```

### Integration Testing
```python
import requests_mock

def test_integration_full_sync():
    """Integration test for full refresh sync"""
    stream = UsersStream(config={"api_token": "test_token"})
    
    with requests_mock.Mocker() as m:
        m.get(
            "https://api.example.com/v1/users",
            json={"users": [{"id": 1, "name": "Alice"}]}
        )
        
        records = list(stream.read_records(SyncMode.full_refresh))
        assert len(records) == 1
        assert records[0]["name"] == "Alice"
```

## Migration Considerations (1.7 → 2.0)

### Key Changes in CDK 2.0

1. **Concurrent Processing**: Introduction of [`ConcurrentSource`](airbyte_cdk/sources/concurrent_source/concurrent_source.py) for parallel execution
2. **Enhanced State Management**: Improved per-stream state handling
3. **Authentication Updates**: Migration from [`airbyte_cdk.sources.streams.http.auth`](airbyte_cdk/sources/streams/http/auth/) to [`airbyte_cdk.sources.streams.http.requests_native_auth`](airbyte_cdk/sources/streams/http/requests_native_auth/)
4. **Pydantic V2 Compatibility**: Updated imports for Pydantic V2 support
5. **Enhanced Error Handling**: New [`ErrorHandler`](airbyte_cdk/sources/streams/http/error_handlers/) and [`BackoffStrategy`](airbyte_cdk/sources/streams/http/error_handlers/backoff_strategy.py) classes

### Migration Steps

1. **Update Authentication Imports**:
```python
# Before
from airbyte_cdk.sources.streams.http.auth import TokenAuthenticator

# After
from airbyte_cdk.sources.streams.http.requests_native_auth import TokenAuthenticator
```

2. **Update Logger Type Annotations**:
```python
# Before
def check_connection(self, logger: AirbyteLogger, config: Mapping[str, Any]) -> Tuple[bool, any]:

# After
import logging
def check_connection(self, logger: logging.Logger, config: Mapping[str, Any]) -> Tuple[bool, any]:
```

3. **Update State Manager Usage**:
```python
# Before
connector_state_manager = ConnectorStateManager(stream_instance_map=stream_map)

# After
connector_state_manager = ConnectorStateManager()
```

## Best Practices

### 1. Stream Design
- Use [`primary_key`](airbyte_cdk/sources/streams/core.py:primary_key) for deduplication
- Implement [`cursor_field`](airbyte_cdk/sources/streams/core.py:cursor_field) for incremental syncs
- Handle pagination efficiently with [`next_page_token()`](airbyte_cdk/sources/streams/http/http.py:next_page_token)

### 2. Error Handling
- Implement robust retry logic in [`should_retry()`](airbyte_cdk/sources/streams/http/http.py:should_retry)
- Use appropriate backoff strategies in [`backoff_time()`](airbyte_cdk/sources/streams/http/http.py:backoff_time)
- Log meaningful error messages for debugging

### 3. Performance Optimization
- Use concurrent processing for high-volume data sources
- Implement efficient pagination strategies
- Minimize API calls through intelligent caching

### 4. Testing
- Write comprehensive unit tests for all stream methods
- Use integration tests with real API responses
- Test error scenarios and edge cases

## CLI Tools and Development

### Source Declarative Manifest CLI
```bash
# Install
pip install airbyte-cdk

# Check connection
source-declarative-manifest check \
  --config secrets/config.json \
  --manifest-path manifest.yaml

# Discover streams
source-declarative-manifest discover \
  --config secrets/config.json \
  --manifest-path manifest.yaml

# Read data
source-declarative-manifest read \
  --config config.json \
  --catalog catalog.json \
  --manifest-path manifest.yaml
```

### Manifest Server
```bash
# Install with manifest server support
pip install airbyte-cdk[manifest-server]

# Start server
manifest-server start --port 8080

# Test endpoints
curl -X POST http://localhost:8080/v1/manifest/check \
  -H "Content-Type: application/json" \
  -d '{"manifest": {...}, "config": {...}}'
```

This architecture provides a robust, scalable foundation for building Airbyte connectors that can handle various data sources, authentication methods, and processing patterns while maintaining high performance and reliability.