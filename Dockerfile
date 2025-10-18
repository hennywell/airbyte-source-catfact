FROM docker.io/airbyte/python-connector-base:1.2.2@sha256:57703de3b4c4204bd68a7b13c9300f8e03c0189bffddaffc796f1da25d2dbea0

# Set the working directory
WORKDIR /airbyte/integration_code

# Copy the source code
COPY source_catfact ./source_catfact
COPY pyproject.toml ./
COPY README.md ./

# Install the connector
RUN pip install .

# Set the entrypoint
ENV AIRBYTE_ENTRYPOINT "python -m source_catfact"
ENTRYPOINT ["python", "-m", "source_catfact"]

# Labels for metadata
LABEL io.airbyte.version=0.1.0
LABEL io.airbyte.name=source-catfact