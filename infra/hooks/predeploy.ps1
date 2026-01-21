#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"

Write-Host "Building and pushing Docker image to ACR..."

# Get ACR name from environment
$acrName = $env:AZURE_CONTAINER_REGISTRY_NAME

if ([string]::IsNullOrEmpty($acrName)) {
    Write-Error "Error: AZURE_CONTAINER_REGISTRY_NAME is not set"
    exit 1
}

# Build and push image to ACR
az acr build `
  --registry $acrName `
  --image web:latest `
  --file Dockerfile `
  .

Write-Host "Docker image successfully built and pushed to $acrName"
