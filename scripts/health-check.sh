#!/bin/bash
set -e

echo "Consent IQ - Google Cloud Build Health Check"
echo "============================================="

PORT=${PORT:-8080}
HEALTH_CHECK_URL="http://localhost:$PORT/api/health"

echo "Waiting for service to be ready on port $PORT..."

# Try health check up to 30 times with 1 second delay
for i in {1..30}; do
  if curl -f -s "$HEALTH_CHECK_URL" > /dev/null 2>&1; then
    echo "✓ Service is healthy!"
    curl -s "$HEALTH_CHECK_URL" | python -m json.tool
    exit 0
  fi
  echo "Attempt $i/30: Waiting for service..."
  sleep 1
done

echo "✗ Service failed to become healthy"
exit 1
