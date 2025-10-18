#!/bin/bash

# Airbyte Port Forward Setup Script
# This script sets up permanent port forwarding for Airbyte web UI

set -e

echo "Setting up permanent Airbyte port forwarding..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
AIRBYTE_NAMESPACE="airbyte-v2"
LOCAL_PORT="8080"
REMOTE_PORT="8080"
SERVICE_NAME="airbyte-webapp-svc"

# Function to check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        echo -e "${RED}This script should not be run as root${NC}"
        echo "Please run as regular user (pl)"
        exit 1
    fi
}

# Function to check prerequisites
check_prerequisites() {
    echo "Checking prerequisites..."
    
    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        echo -e "${RED}kubectl is not installed${NC}"
        exit 1
    fi
    
    # Check if minikube is running
    if ! minikube status &> /dev/null; then
        echo -e "${RED}Minikube is not running${NC}"
        exit 1
    fi
    
    # Check if Airbyte namespace exists
    if ! kubectl get namespace "$AIRBYTE_NAMESPACE" &> /dev/null; then
        echo -e "${RED}Airbyte namespace '$AIRBYTE_NAMESPACE' not found${NC}"
        echo "Available namespaces:"
        kubectl get namespaces
        exit 1
    fi
    
    echo -e "${GREEN}Prerequisites check passed${NC}"
}

# Function to find Airbyte service
find_airbyte_service() {
    echo "Finding Airbyte web service..."
    
    # Try common service names
    local service_names=("airbyte-webapp-svc" "airbyte-webapp" "airbyte-web" "airbyte-server-svc" "airbyte-server")
    
    for service in "${service_names[@]}"; do
        if kubectl get service "$service" -n "$AIRBYTE_NAMESPACE" &> /dev/null; then
            SERVICE_NAME="$service"
            echo -e "${GREEN}Found Airbyte service: $SERVICE_NAME${NC}"
            return 0
        fi
    done
    
    echo -e "${YELLOW}Could not find Airbyte service with common names${NC}"
    echo "Available services in $AIRBYTE_NAMESPACE namespace:"
    kubectl get services -n "$AIRBYTE_NAMESPACE"
    
    read -p "Enter the correct service name: " SERVICE_NAME
    
    if ! kubectl get service "$SERVICE_NAME" -n "$AIRBYTE_NAMESPACE" &> /dev/null; then
        echo -e "${RED}Service '$SERVICE_NAME' not found${NC}"
        exit 1
    fi
}

# Function to get service port
get_service_port() {
    echo "Getting service port information..."
    
    # Get the target port from the service
    REMOTE_PORT=$(kubectl get service "$SERVICE_NAME" -n "$AIRBYTE_NAMESPACE" -o jsonpath='{.spec.ports[0].port}')
    
    if [[ -z "$REMOTE_PORT" ]]; then
        echo -e "${RED}Could not determine service port${NC}"
        kubectl describe service "$SERVICE_NAME" -n "$AIRBYTE_NAMESPACE"
        exit 1
    fi
    
    echo -e "${GREEN}Service port: $REMOTE_PORT${NC}"
}

# Function to create systemd service
create_systemd_service() {
    echo "Creating systemd service for port forwarding..."
    
    # Create the service file content
    cat > /tmp/airbyte-portforward.service << EOF
[Unit]
Description=Airbyte Port Forward Service
After=network.target
Wants=network.target

[Service]
Type=simple
User=pl
Group=pl
ExecStart=/usr/local/bin/kubectl port-forward --address=0.0.0.0 -n $AIRBYTE_NAMESPACE service/$SERVICE_NAME $LOCAL_PORT:$REMOTE_PORT
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

    # Move to systemd directory (requires sudo)
    echo "Installing systemd service (requires sudo)..."
    sudo mv /tmp/airbyte-portforward.service /etc/systemd/system/
    
    # Reload systemd
    sudo systemctl daemon-reload
    
    echo -e "${GREEN}Systemd service created${NC}"
}

# Function to start and enable service
start_service() {
    echo "Starting and enabling Airbyte port forward service..."
    
    # Stop any existing port-forward processes
    pkill -f "kubectl.*port-forward.*$SERVICE_NAME" || true
    
    # Enable and start the service
    sudo systemctl enable airbyte-portforward.service
    sudo systemctl start airbyte-portforward.service
    
    # Wait a moment for service to start
    sleep 3
    
    # Check service status
    if sudo systemctl is-active --quiet airbyte-portforward.service; then
        echo -e "${GREEN}Service started successfully${NC}"
    else
        echo -e "${RED}Service failed to start${NC}"
        sudo systemctl status airbyte-portforward.service
        exit 1
    fi
}

# Function to verify setup
verify_setup() {
    echo "Verifying setup..."
    
    # Check if port is listening
    if netstat -tuln | grep ":$LOCAL_PORT " > /dev/null; then
        echo -e "${GREEN}Port $LOCAL_PORT is listening${NC}"
    else
        echo -e "${RED}Port $LOCAL_PORT is not listening${NC}"
        sudo systemctl status airbyte-portforward.service
        exit 1
    fi
    
    # Test local connection
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:$LOCAL_PORT | grep -q "200\|302\|404"; then
        echo -e "${GREEN}Local connection test passed${NC}"
    else
        echo -e "${YELLOW}Local connection test failed (this might be normal if Airbyte returns different status codes)${NC}"
    fi
    
    echo -e "${GREEN}Setup completed successfully!${NC}"
    echo ""
    echo "Airbyte web UI is now accessible at:"
    echo "  - Local: http://localhost:$LOCAL_PORT"
    echo "  - Network: http://192.168.179.229:$LOCAL_PORT"
    echo "  - External: http://0.0.0.0:$LOCAL_PORT"
    echo ""
    echo "Service management commands:"
    echo "  - Check status: sudo systemctl status airbyte-portforward.service"
    echo "  - Stop service: sudo systemctl stop airbyte-portforward.service"
    echo "  - Start service: sudo systemctl start airbyte-portforward.service"
    echo "  - View logs: sudo journalctl -u airbyte-portforward.service -f"
}

# Main execution
main() {
    echo -e "${GREEN}Airbyte Port Forward Setup${NC}"
    echo "================================"
    
    check_root
    check_prerequisites
    find_airbyte_service
    get_service_port
    create_systemd_service
    start_service
    verify_setup
}

# Run main function
main "$@"