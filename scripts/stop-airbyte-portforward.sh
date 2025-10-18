#!/bin/bash

# Stop Airbyte Port Forward Script

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Stopping Airbyte Port Forward${NC}"

# Stop systemd service if it exists
if systemctl is-active --quiet airbyte-portforward.service 2>/dev/null; then
    echo "Stopping systemd service..."
    sudo systemctl stop airbyte-portforward.service
    echo -e "${GREEN}Systemd service stopped${NC}"
fi

# Stop screen session if it exists
if screen -list | grep -q "airbyte-portforward"; then
    echo "Stopping screen session..."
    screen -S "airbyte-portforward" -X quit
    echo -e "${GREEN}Screen session stopped${NC}"
fi

# Kill any remaining kubectl port-forward processes
if pgrep -f "kubectl.*port-forward.*airbyte" > /dev/null; then
    echo "Killing remaining kubectl port-forward processes..."
    pkill -f "kubectl.*port-forward.*airbyte"
    echo -e "${GREEN}Processes killed${NC}"
fi

# Check if port 8080 is still in use
if netstat -tuln | grep ":8080 " > /dev/null; then
    echo -e "${YELLOW}Port 8080 is still in use by another process${NC}"
    echo "Processes using port 8080:"
    sudo lsof -i :8080 || true
else
    echo -e "${GREEN}Port 8080 is now free${NC}"
fi

echo -e "${GREEN}Airbyte port forward stopped${NC}"