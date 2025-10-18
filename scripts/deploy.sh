#!/bin/bash

# Deployment script for Airbyte Source Cat Fact Connector
# This script helps with local testing and deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="ghcr.io/hennywell/airbyte-source-catfact"
LOCAL_IMAGE_NAME="airbyte/source-catfact"
VERSION="latest"

# Functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
    print_success "Docker is running"
}

# Build local image
build_local() {
    print_header "Building Local Docker Image"
    
    echo "Building $LOCAL_IMAGE_NAME:dev..."
    docker build -t "$LOCAL_IMAGE_NAME:dev" .
    
    print_success "Local image built successfully"
}

# Test connector locally
test_local() {
    print_header "Testing Local Connector"
    
    echo "Testing connector help..."
    docker run --rm "$LOCAL_IMAGE_NAME:dev" --help
    
    echo "Testing connection check..."
    echo '{}' | docker run --rm -i "$LOCAL_IMAGE_NAME:dev" check --config /dev/stdin
    
    echo "Testing stream discovery..."
    echo '{}' | docker run --rm -i "$LOCAL_IMAGE_NAME:dev" discover --config /dev/stdin
    
    print_success "Local tests passed"
}

# Pull from GitHub Container Registry
pull_remote() {
    print_header "Pulling from GitHub Container Registry"
    
    echo "Pulling $IMAGE_NAME:$VERSION..."
    docker pull "$IMAGE_NAME:$VERSION"
    
    print_success "Remote image pulled successfully"
}

# Test remote image
test_remote() {
    print_header "Testing Remote Image"
    
    echo "Testing connector help..."
    docker run --rm "$IMAGE_NAME:$VERSION" --help
    
    echo "Testing connection check..."
    echo '{}' | docker run --rm -i "$IMAGE_NAME:$VERSION" check --config /dev/stdin
    
    echo "Testing stream discovery..."
    echo '{}' | docker run --rm -i "$IMAGE_NAME:$VERSION" discover --config /dev/stdin
    
    print_success "Remote tests passed"
}

# Load image into kind cluster
load_kind() {
    print_header "Loading Image into Kind Cluster"
    
    if ! command -v kind &> /dev/null; then
        print_error "kind is not installed or not in PATH"
        exit 1
    fi
    
    echo "Loading $IMAGE_NAME:$VERSION into kind cluster..."
    kind load docker-image "$IMAGE_NAME:$VERSION" -n airbyte-abctl
    
    print_success "Image loaded into kind cluster"
}

# Load image into minikube
load_minikube() {
    print_header "Loading Image into Minikube"
    
    if ! command -v minikube &> /dev/null; then
        print_error "minikube is not installed or not in PATH"
        exit 1
    fi
    
    echo "Loading $IMAGE_NAME:$VERSION into minikube..."
    minikube image load "$IMAGE_NAME:$VERSION"
    
    print_success "Image loaded into minikube"
}

# Show usage
usage() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  build-local     Build the connector locally"
    echo "  test-local      Test the local connector"
    echo "  pull-remote     Pull the connector from GHCR"
    echo "  test-remote     Test the remote connector"
    echo "  load-kind       Load remote image into kind cluster"
    echo "  load-minikube   Load remote image into minikube"
    echo "  full-local      Build and test locally"
    echo "  full-remote     Pull and test remote image"
    echo "  deploy-kind     Pull, test, and load into kind"
    echo "  deploy-minikube Pull, test, and load into minikube"
    echo ""
    echo "Examples:"
    echo "  $0 full-local       # Build and test locally"
    echo "  $0 deploy-kind      # Deploy to kind cluster"
    echo "  $0 test-remote      # Test the published image"
}

# Main script logic
main() {
    check_docker
    
    case "${1:-}" in
        "build-local")
            build_local
            ;;
        "test-local")
            test_local
            ;;
        "pull-remote")
            pull_remote
            ;;
        "test-remote")
            test_remote
            ;;
        "load-kind")
            load_kind
            ;;
        "load-minikube")
            load_minikube
            ;;
        "full-local")
            build_local
            test_local
            ;;
        "full-remote")
            pull_remote
            test_remote
            ;;
        "deploy-kind")
            pull_remote
            test_remote
            load_kind
            print_success "Deployment to kind completed!"
            print_warning "You may need to restart Airbyte: abctl local deployments --restart"
            ;;
        "deploy-minikube")
            pull_remote
            test_remote
            load_minikube
            print_success "Deployment to minikube completed!"
            print_warning "You may need to restart Airbyte pods"
            ;;
        *)
            usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"