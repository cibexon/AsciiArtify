# Kubernetes Prompt Engineering Portfolio

This repository contains a collection of prompts for generating and analyzing Kubernetes manifests using AI tools.

## Prompt Engineering Principles Applied

Based on Google's Prompt Engineering guidelines, these prompts follow:

1. **Clarity and Specificity** - Clear objectives and constraints
2. **Context Provision** - Providing relevant Kubernetes context
3. **Iterative Refinement** - Prompt improvement through testing
4. **Domain Expertise** - Incorporating Kubernetes best practices

## Prompts Table

app.yaml:Generate a Kubernetes Pod manifest for a demo application. The pod should be named "app" with labels app: demo and run: demo. Use container image gcr.io/k8s-k3s/demo:v1.0.0 exposing port 8000 named "http". Ensure proper YAML formatting with all necessary fields.:Basic Pod configuration for a demo application:[app.yaml](./app.yaml)
app-livenessProbe.yaml:Create a Kubernetes Pod with liveness probe for health monitoring. The pod should check HTTP GET on path /healthz on port 8000, with initial delay of 30 seconds and period of 10 seconds. Use image gcr.io/k8s-k3s/demo:v1.0.0 and expose port 8000. Include proper probe configuration with failure thresholds.:Pod with liveness probe for container health monitoring:[app-livenessProbe.yaml](./app-livenessProbe.yaml)
app-readinessProbe.yaml:Generate a Pod with readiness probe for traffic management. The readiness probe should check TCP socket on port 8000 with initial delay of 5 seconds and period of 10 seconds. Include labels app: demo and run: demo for proper service discovery. Specify success and failure thresholds.:Pod with readiness probe for traffic routing control:[app-readinessProbe.yaml](./app-readinessProbe.yaml)
app-volumeMounts.yaml:Create a Pod with volume mounts for persistent storage. Mount a ConfigMap named "app-config" to /etc/config and use emptyDir volume for temporary files mounted at /tmp. The container should run with user ID 1000 for security. Show both volume definitions and volume mounts.:Pod with volume mounts for configuration and temporary storage:[app-volumeMounts.yaml](./app-volumeMounts.yaml)
app-cronjob.yaml:Generate a Kubernetes CronJob for scheduled tasks. The job should run every minute using busybox image to echo current timestamp. Include successfulJobsHistoryLimit of 3 and failedJobsHistoryLimit of 1 for job history management. Specify proper schedule syntax and job template.:Scheduled cron job for regular maintenance tasks:[app-cronjob.yaml](./app-cronjob.yaml)
app-job.yaml:Create a Kubernetes Job for batch processing. The job should have 3 completions with parallelism of 2, using busybox image to process data. Include backoffLimit of 2 and proper restart policy for reliable execution. Define pod template with necessary specifications.:Batch job for one-time data processing tasks:[app-job.yaml](./app-job.yaml)
app-multicontainer.yaml:Generate a Pod with two containers: 1) main application container running demo app on port 8000, 2) sidecar nginx container for reverse proxy on port 80. Share volume between containers for configuration files. Define shared volumes and container specifications clearly.:Multi-container pod with main app and sidecar proxy:[app-multicontainer.yaml](./app-multicontainer.yaml)
app-resources.yaml:Create a Pod with resource requests and limits. Request 100m CPU and 128Mi memory, limit to 200m CPU and 256Mi memory. Include proper QoS class specification and security context with non-root user execution. Show both requests and limits in container resources.:Pod with resource constraints and quality of service guarantees:[app-resources.yaml](./app-resources.yaml)
app-secret-env.yaml:Generate a Pod that uses Secrets for sensitive environment variables. Create environment variables from Secret named "app-secret" with keys username and password. Include security context with read-only root filesystem for enhanced security. Show Secret reference in envFrom field.:Pod with secure environment variables from Kubernetes Secrets:[app-secret-env.yaml](./app-secret-env.yaml)

## Using kubectl-ai

To use these prompts with Google Cloud's kubectl-ai:

```bash
# Install kubectl-ai
kubectl krew install ai
```

```bash
# Generate a manifest
kubectl ai "Generate a Kubernetes Deployment for a Go web application with 3 replicas..."
```

```bash
# Apply the generated manifest
kubectl apply -f generated-manifest.yaml
```
