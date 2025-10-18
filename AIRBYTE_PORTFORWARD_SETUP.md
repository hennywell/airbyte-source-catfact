# Airbyte Port Forward Setup Guide

This guide helps you set up permanent port forwarding for Airbyte web UI on your remote Debian server (192.168.179.229) to make it accessible externally on `0.0.0.0:8080`.

## Prerequisites

- Airbyte deployed with Helm on minikube
- kubectl configured and working
- SSH access to the remote server (user: pl)
- Sudo privileges on the remote server

## Setup Options

You have two options for setting up permanent port forwarding:

### Option 1: Systemd Service (Recommended)

This creates a proper systemd service that automatically starts on boot and restarts if it fails.

#### Steps:

1. **SSH to your remote server:**
   ```bash
   ssh pl@192.168.179.229
   ```

2. **Copy the setup script to your server:**
   ```bash
   # If you have the scripts locally, copy them:
   scp scripts/setup-airbyte-portforward.sh pl@192.168.179.229:~/
   scp scripts/stop-airbyte-portforward.sh pl@192.168.179.229:~/
   ```

3. **Make the script executable and run it:**
   ```bash
   chmod +x ~/setup-airbyte-portforward.sh
   ./setup-airbyte-portforward.sh
   ```

4. **The script will:**
   - Check prerequisites (kubectl, minikube, Airbyte namespace)
   - Find the Airbyte web service automatically
   - Create a systemd service file
   - Start and enable the service
   - Verify the setup

#### Service Management:

```bash
# Check service status
sudo systemctl status airbyte-portforward.service

# Stop the service
sudo systemctl stop airbyte-portforward.service

# Start the service
sudo systemctl start airbyte-portforward.service

# Restart the service
sudo systemctl restart airbyte-portforward.service

# View logs
sudo journalctl -u airbyte-portforward.service -f

# Disable auto-start on boot
sudo systemctl disable airbyte-portforward.service
```

### Option 2: Screen Session (Simple Alternative)

This uses a screen session to run the port forward in the background.

#### Steps:

1. **SSH to your remote server:**
   ```bash
   ssh pl@192.168.179.229
   ```

2. **Copy and run the simple script:**
   ```bash
   # Copy the script
   scp scripts/start-airbyte-portforward.sh pl@192.168.179.229:~/
   
   # Make executable and run
   chmod +x ~/start-airbyte-portforward.sh
   ./start-airbyte-portforward.sh
   ```

#### Screen Session Management:

```bash
# View the running session
screen -r airbyte-portforward

# Detach from session (Ctrl+A, then D)

# Stop the port forward
screen -S airbyte-portforward -X quit

# List all screen sessions
screen -list
```

## Manual Setup (If Scripts Don't Work)

If the automated scripts don't work, you can set up manually:

### 1. Find Airbyte Service

```bash
# Check available namespaces
kubectl get namespaces

# List services in Airbyte namespace
kubectl get services -n airbyte-v2

# Common service names to look for:
# - airbyte-webapp-svc
# - airbyte-webapp
# - airbyte-web
# - airbyte-server-svc
```

### 2. Start Port Forward Manually

```bash
# Replace SERVICE_NAME with the actual service name
kubectl port-forward --address=0.0.0.0 -n airbyte-v2 service/SERVICE_NAME 8080:8080
```

### 3. Create Systemd Service Manually

Create the service file:

```bash
sudo nano /etc/systemd/system/airbyte-portforward.service
```

Add this content (replace SERVICE_NAME):

```ini
[Unit]
Description=Airbyte Port Forward Service
After=network.target
Wants=network.target

[Service]
Type=simple
User=pl
Group=pl
ExecStart=/usr/local/bin/kubectl port-forward --address=0.0.0.0 -n airbyte-v2 service/SERVICE_NAME 8080:8080
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

Enable and start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable airbyte-portforward.service
sudo systemctl start airbyte-portforward.service
```

## Verification

After setup, verify the port forwarding works:

### 1. Check if port is listening:
```bash
netstat -tuln | grep :8080
```

### 2. Test local connection:
```bash
curl -I http://localhost:8080
```

### 3. Test from your local machine:
```bash
curl -I http://192.168.179.229:8080
```

## Access URLs

Once set up, Airbyte will be accessible at:

- **Local (on server):** http://localhost:8080
- **Network:** http://192.168.179.229:8080
- **External:** http://0.0.0.0:8080 (if firewall allows)

## Troubleshooting

### Port Already in Use
```bash
# Check what's using port 8080
sudo lsof -i :8080

# Kill existing port-forward processes
pkill -f "kubectl.*port-forward"
```

### Service Won't Start
```bash
# Check service logs
sudo journalctl -u airbyte-portforward.service -f

# Check kubectl access
kubectl get pods -n airbyte-v2
```

### Firewall Issues
```bash
# Check if firewall is blocking (if using ufw)
sudo ufw status

# Allow port 8080 if needed
sudo ufw allow 8080
```

### Minikube Issues
```bash
# Check minikube status
minikube status

# Start minikube if stopped
minikube start
```

## Security Considerations

- The setup binds to `0.0.0.0:8080`, making Airbyte accessible from any IP
- Consider using a firewall to restrict access to specific IPs
- For production use, consider setting up proper ingress with SSL/TLS

## Stopping Port Forward

Use the stop script:
```bash
chmod +x ~/stop-airbyte-portforward.sh
./stop-airbyte-portforward.sh
```

Or manually:
```bash
# Stop systemd service
sudo systemctl stop airbyte-portforward.service

# Or kill screen session
screen -S airbyte-portforward -X quit
```

## Notes

- The systemd service will automatically restart if it fails
- The service will start automatically on system boot
- Port forwarding will persist across minikube restarts
- If Airbyte pods restart, the port forward should reconnect automatically