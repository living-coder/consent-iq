#!/bin/bash
set -e

echo "Consent IQ - Google Cloud Build Deployment Script"
echo "================================================="

# Set default values
PORT=${PORT:-8080}
NODE_ENV=${NODE_ENV:-production}
PROJECT_ID=${GCP_PROJECT_ID:-${GCLOUD_PROJECT}}

echo "Configuration:"
echo "  PORT: $PORT"
echo "  NODE_ENV: $NODE_ENV"
echo "  PROJECT_ID: $PROJECT_ID"

# Validate environment
if [ -z "$PROJECT_ID" ]; then
  echo "Error: PROJECT_ID is not set"
  exit 1
fi

# Build Docker image
echo ""
echo "Building Docker image..."
docker build \
  --build-arg PORT=$PORT \
  --tag gcr.io/$PROJECT_ID/consent-iq:latest \
  --tag gcr.io/$PROJECT_ID/consent-iq:$(git rev-parse --short HEAD) \
  .

echo "Build complete!"
echo "Image: gcr.io/$PROJECT_ID/consent-iq:latest"
