#!/bin/bash

# Simple Airbyte Port Forward Script
# Alternative to systemd approach using screen session

set -e

# Configuration
AIRBYTE_NAMESPACE="airbyte-v2"
LOCAL_PORT="8080"
SESSION_NAME="airbyte-portforward"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Starting Airbyte Port Forward${NC}"

# Check if screen is installed
if ! command -v screen &> /dev/null; then
    echo -e "${YELLOW}Screen not installed. Installing...${NC}"
    sudo apt-get update && sudo apt-get install -y screen
fi

# Kill existing session if it exists
screen -S "$SESSION_NAME" -X quit 2>/dev/null || true

# Find Airbyte service
echo "Finding Airbyte service..."
SERVICE_NAME=""
service_names=("airbyte-webapp-svc" "airbyte-webapp" "airbyte-web" "airbyte-server-svc" "airbyte-server")

for service in "${service_names[@]}"; do
    if kubectl get service "$service" -n "$AIRBYTE_NAMESPACE" &> /dev/null; then
        SERVICE_NAME="$service"
        echo -e "${GREEN}Found Airbyte service: $SERVICE_NAME${NC}"
        break
    fi
done

if [[ -z "$SERVICE_NAME" ]]; then
    echo -e "${RED}Could not find Airbyte service${NC}"
    echo "Available services:"
    kubectl get services -n "$AIRBYTE_NAMESPACE"
    exit 1
fi

# Get service port
REMOTE_PORT=$(kubectl get service "$SERVICE_NAME" -n "$AIRBYTE_NAMESPACE" -o jsonpath='{.spec.ports[0].port}')

echo "Starting port forward in screen session..."
screen -dmS "$SESSION_NAME" kubectl port-forward --address=0.0.0.0 -n "$AIRBYTE_NAMESPACE" service/"$SERVICE_NAME" "$LOCAL_PORT:$REMOTE_PORT"

# Wait a moment and check if it's running
sleep 2

if screen -list | grep -q "$SESSION_NAME"; then
    echo -e "${GREEN}Port forward started successfully!${NC}"
    echo ""
    echo "Airbyte web UI is accessible at:"
    echo "  - Local: http://localhost:$LOCAL_PORT"
    echo "  - Network: http://192.168.179.229:$LOCAL_PORT"
    echo ""
    echo "Management commands:"
    echo "  - View session: screen -r $SESSION_NAME"
    echo "  - Stop: screen -S $SESSION_NAME -X quit"
    echo "  - Check status: screen -list | grep $SESSION_NAME"
else
    echo -e "${RED}Failed to start port forward${NC}"
    exit 1
fi