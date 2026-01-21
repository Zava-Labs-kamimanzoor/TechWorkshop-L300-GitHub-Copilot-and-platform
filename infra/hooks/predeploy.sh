#!/bin/bash
set -e

echo "Building and pushing Docker image to ACR..."

# Get ACR name from environment
ACR_NAME="${AZURE_CONTAINER_REGISTRY_NAME}"

if [ -z "$ACR_NAME" ]; then
  echo "Error: AZURE_CONTAINER_REGISTRY_NAME is not set"
  exit 1
fi

# Build and push image to ACR
az acr build \
  --registry "$ACR_NAME" \
  --image web:latest \
  --file Dockerfile \
  .

echo "Docker image successfully built and pushed to $ACR_NAME"
