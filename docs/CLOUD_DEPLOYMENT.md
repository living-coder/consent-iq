# Consent IQ - Google Cloud Deployment Guide

## Prerequisites

- Google Cloud Project
- Cloud Build enabled
- Container Registry enabled
- Cloud Run enabled (optional, for serverless deployment)
- `gcloud` CLI installed

## Environment Variables for Cloud Build

Set these in your `cloudbuild.yaml` or Cloud Build trigger configuration:

```yaml
substitutions:
  _PORT: '8080'  # Cloud Run requires port 8080 or higher
  _REGION: 'us-central1'
  _MEMORY: '512Mi'
  _CPU: '1'
```

## Deployment Options

### Option 1: Cloud Build to Container Registry + Cloud Run

```bash
gcloud builds submit \
  --config cloudbuild.yaml \
  --substitutions _PORT=8080,_REGION=us-central1
```

### Option 2: Cloud Build to GKE

Update the `k8s/deployment.yaml` with your project ID:

```bash
sed -i 's/PROJECT_ID/'$GCP_PROJECT_ID'/g' k8s/deployment.yaml

gcloud builds submit \
  --config cloudbuild.yaml
```

### Option 3: Direct Deployment Script

```bash
export GCP_PROJECT_ID=your-project-id
export GCP_REGION=us-central1
bash scripts/deploy.sh
```

## Docker Port Configuration

The Dockerfile includes:

1. **Build Argument**: `ARG PORT=3000` (default)
2. **Environment Variable**: `ENV PORT=${PORT}` (set from build arg)
3. **Expose**: `EXPOSE ${PORT}` (exposes the variable)

For Google Cloud Build:

```yaml
args:
  - 'build'
  - '--build-arg'
  - 'PORT=8080'  # Cloud Run requirement
```

## Server Configuration

The Express server reads from the environment variable:

```javascript
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

## Cloud Run Specific Requirements

- **Port**: Must listen on port 8080 or configured port ≥ 1024
- **Startup**: Service should be ready within 4 minutes
- **Memory**: Minimum 128Mi, recommended 256Mi+
- **CPU**: Minimum 0.083 CPU cores (1/12), recommended 1 CPU

## Health Checks

The Dockerfile includes a HEALTHCHECK directive:

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:' + process.env.PORT, ...)"
```

Cloud Run endpoint:

```bash
curl https://your-service-url/api/health
```

## Monitoring

View deployment logs:

```bash
# Cloud Build logs
gcloud builds log [BUILD_ID]

# Cloud Run logs
gcloud run logs read consent-iq --region us-central1 --limit 100

# View live logs
gcloud run logs read consent-iq --region us-central1 --follow
```

## Environment Variables in Production

Set via Cloud Run:

```bash
gcloud run deploy consent-iq \
  --image gcr.io/$PROJECT_ID/consent-iq:latest \
  --set-env-vars PORT=8080,NODE_ENV=production \
  --region us-central1
```

Or in `k8s/deployment.yaml` ConfigMap for GKE.

## Troubleshooting

### Service won't start

```bash
# Check logs
gcloud run logs read consent-iq --limit 50

# Verify image exists
gcloud container images list --repository=gcr.io/$PROJECT_ID
```

### Port issues

```bash
# Cloud Run only supports specific ports
# Recommended: 8080, 8081, 9000

# Local test with different port
PORT=8080 npm start
```

### Build timeout

Increase machine type in `cloudbuild.yaml`:

```yaml
options:
  machineType: 'N1_HIGHCPU_8'  # For faster builds
```

## Next Steps

1. Set up Cloud Build trigger in Google Cloud Console
2. Connect your GitHub repository
3. Configure trigger settings with appropriate `_PORT` substitution
4. Push to trigger automatic deployment
