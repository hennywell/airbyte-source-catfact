#!/bin/bash

# Fixed Airbyte Port Forward Setup Script
# Uses the correct service name and port discovered during testing

set -e

echo "Setting up permanent Airbyte port forwarding..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration - using discovered values
AIRBYTE_NAMESPACE="airbyte-v2"
LOCAL_PORT="8080"
REMOTE_PORT="8080"
SERVICE_NAME="airbyte-enterprise-airbyte-webapp-svc"

echo -e "${GREEN}Airbyte Port Forward Setup (Fixed)${NC}"
echo "================================"
echo "Service: $SERVICE_NAME"
echo "Port mapping: $LOCAL_PORT:$REMOTE_PORT"
echo "Namespace: $AIRBYTE_NAMESPACE"
echo ""

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

    echo "Service file created. Please run the following commands with sudo:"
    echo ""
    echo -e "${YELLOW}sudo mv /tmp/airbyte-portforward.service /etc/systemd/system/${NC}"
    echo -e "${YELLOW}sudo systemctl daemon-reload${NC}"
    echo -e "${YELLOW}sudo systemctl enable airbyte-portforward.service${NC}"
    echo -e "${YELLOW}sudo systemctl start airbyte-portforward.service${NC}"
    echo ""
    echo "After running these commands, check status with:"
    echo -e "${YELLOW}sudo systemctl status airbyte-portforward.service${NC}"
}

# Function to verify current setup
verify_current_setup() {
    echo "Verifying current port forwarding..."
    
    # Check if port is listening
    if netstat -tuln | grep ":$LOCAL_PORT " > /dev/null; then
        echo -e "${GREEN}Port $LOCAL_PORT is currently listening${NC}"
        
        # Test connection
        if curl -s -o /dev/null -w "%{http_code}" http://localhost:$LOCAL_PORT | grep -q "200"; then
            echo -e "${GREEN}Airbyte web UI is accessible and responding${NC}"
        else
            echo -e "${YELLOW}Port is listening but may not be fully ready${NC}"
        fi
    else
        echo -e "${RED}Port $LOCAL_PORT is not currently listening${NC}"
        echo "The temporary port forward may have stopped."
    fi
}

# Main execution
main() {
    verify_current_setup
    echo ""
    create_systemd_service
    
    echo ""
    echo -e "${GREEN}Setup completed!${NC}"
    echo ""
    echo "Airbyte web UI should be accessible at:"
    echo "  - Local: http://localhost:$LOCAL_PORT"
    echo "  - Network: http://192.168.179.229:$LOCAL_PORT"
    echo "  - External: http://0.0.0.0:$LOCAL_PORT"
}

# Run main function
main "$@"