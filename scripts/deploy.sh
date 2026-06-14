#!/bin/bash
set -e

echo "Consent IQ - Google Cloud Deployment Script"
echo "==========================================="

# Set default values
PORT=${PORT:-8080}
PROJECT_ID=${GCP_PROJECT_ID:-${GCLOUD_PROJECT}}
REGION=${GCP_REGION:-us-central1}
IMAGE_NAME=${IMAGE_NAME:-consent-iq}

echo "Configuration:"
echo "  PORT: $PORT"
echo "  PROJECT_ID: $PROJECT_ID"
echo "  REGION: $REGION"

# Validate environment
if [ -z "$PROJECT_ID" ]; then
  echo "Error: PROJECT_ID is not set"
  exit 1
fi

# Deploy to Cloud Run
echo ""
echo "Deploying to Cloud Run..."
gcloud run deploy $IMAGE_NAME \
  --image gcr.io/$PROJECT_ID/$IMAGE_NAME:latest \
  --region $REGION \
  --platform managed \
  --port $PORT \
  --set-env-vars=PORT=$PORT,NODE_ENV=production \
  --memory 512Mi \
  --cpu 1 \
  --allow-unauthenticated

echo "Deployment complete!"
echo "Service URL: $(gcloud run services describe $IMAGE_NAME --region=$REGION --format='value(status.url)')"
