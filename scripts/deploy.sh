#!/bin/bash
set -e

# Configuration
ACR_NAME="ribacr123"
IMAGE_NAME="juice-roll"
ACR_URL="${ACR_NAME}.azurecr.io"
K8S_DIR="k8s"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo -e "${GREEN}=== Juice Roll Deployment Script ===${NC}"
echo "Project root: $PROJECT_ROOT"

# Generate version tag from timestamp
VERSION=$(date +%Y%m%d-%H%M%S)
FULL_IMAGE="${ACR_URL}/${IMAGE_NAME}:${VERSION}"
echo -e "${YELLOW}Version: ${VERSION}${NC}"

# Change to project root
cd "$PROJECT_ROOT"

# Step 1: Clean and build Flutter web app
echo -e "\n${GREEN}[1/6] Cleaning previous build...${NC}"
flutter clean

echo -e "\n${GREEN}[2/6] Getting dependencies...${NC}"
flutter pub get

echo -e "\n${GREEN}[3/6] Building Flutter web release...${NC}"
flutter build web --release

# Step 2: Login to ACR
echo -e "\n${GREEN}[4/6] Logging into Azure Container Registry...${NC}"
az acr login --name "$ACR_NAME"

# Step 3: Build and push Docker image
echo -e "\n${GREEN}[5/6] Building and pushing Docker image...${NC}"
docker build --no-cache -t "$FULL_IMAGE" .
docker push "$FULL_IMAGE"

# Step 4: Update deployment.yaml with new version
echo -e "\n${GREEN}[6/6] Deploying to Kubernetes...${NC}"

# Update the image tag in deployment.yaml
sed -i "s|image: ${ACR_URL}/${IMAGE_NAME}:.*|image: ${FULL_IMAGE}|" "${K8S_DIR}/deployment.yaml"

# Apply Kubernetes manifests
kubectl apply -f "${K8S_DIR}/deployment.yaml"
kubectl apply -f "${K8S_DIR}/ingress.yaml"

# Wait for rollout to complete
echo -e "\n${YELLOW}Waiting for deployment rollout...${NC}"
kubectl rollout status deployment/${IMAGE_NAME} --timeout=120s

# Show deployment status
echo -e "\n${GREEN}=== Deployment Complete ===${NC}"
echo -e "Image: ${FULL_IMAGE}"
echo ""
kubectl get pods -l app=${IMAGE_NAME}
echo ""
echo -e "${YELLOW}Note: You may need to hard refresh (Ctrl+F5) your browser to see changes.${NC}"
