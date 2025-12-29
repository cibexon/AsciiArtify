# Kubernetes Prompt Engineering Portfolio

This repository contains a collection of prompts for generating and analyzing Kubernetes manifests using AI tools.

## Prompt Engineering Principles Applied

Based on Google's Prompt Engineering guidelines, these prompts follow:

1. **Clarity and Specificity** - Clear objectives and constraints
2. **Context Provision** - Providing relevant Kubernetes context
3. **Iterative Refinement** - Prompt improvement through testing
4. **Domain Expertise** - Incorporating Kubernetes best practices

## Prompts Table

| NAME | PROMPT | DESCRIPTION | EXAMPLE |
|------|--------|-------------|---------|
| app.yaml | `Generate a Kubernetes Deployment for a Go web application with 3 replicas. The app listens on port 8080 and has environment variable APP_ENV set to "production". Include a Service of type ClusterIP exposing the application.` | Basic deployment and service for a web application | [app.yaml](./app.yaml) |
| app-livenessProbe.yaml | `Create a Kubernetes Deployment with liveness probe for a Go application. The probe should check HTTP GET on path /healthz on port 8080, with initial delay of 30 seconds, period of 10 seconds, and timeout of 5 seconds.` | Deployment with health check for container liveness | [app-livenessProbe.yaml](./app-livenessProbe.yaml) |
| app-readinessProbe.yaml | `Generate a Deployment with readiness probe for a microservice. The readiness probe should check TCP socket on port 8080 with initial delay of 5 seconds and period of 10 seconds. Include proper labels and annotations.` | Deployment with readiness check for traffic routing | [app-readinessProbe.yaml](./app-readinessProbe.yaml) |
| app-volumeMounts.yaml | `Create a Deployment with volume mounts for configuration. Mount a ConfigMap named "app-config" to /etc/config and an emptyDir volume for temporary files at /tmp. The container should run as non-root user.` | Deployment with persistent storage configuration | [app-volumeMounts.yaml](./app-volumeMounts.yaml) |
| app-cronjob.yaml | `Generate a Kubernetes CronJob that runs a batch processing task every day at 2 AM. The job should have a deadline of 300 seconds, use backoff limit of 2, and store logs in /var/log. Include proper resource limits.` | Scheduled batch job configuration | [app-cronjob.yaml](./app-cronjob.yaml) |
| app-job.yaml | `Create a Kubernetes Job for one-time data migration. The job should have 3 completions with parallelism of 2, active deadline of 600 seconds, and proper restart policy. Include environment variables for database connection.` | One-time or batch job configuration | [app-job.yaml](./app-job.yaml) |
| app-multicontainer.yaml | `Generate a Pod with two containers: 1) main application container running on port 8080, 2) sidecar container for logging that reads from shared volume. Include init container for configuration setup.` | Multi-container pod with shared resources | [app-multicontainer.yaml](./app-multicontainer.yaml) |
| app-resources.yaml | `Create a Deployment with resource requests and limits. Request 100m CPU and 128Mi memory, limit to 500m CPU and 512Mi memory. Include HorizontalPodAutoscaler configuration for CPU utilization of 70%.` | Resource management and autoscaling | [app-resources.yaml](./app-resources.yaml) |
| app-secret-env.yaml | `Generate a Deployment that uses Secrets for environment variables. Create a Secret for database credentials and mount them as environment variables DB_USER and DB_PASSWORD. Include security context with read-only root filesystem.` | Secure secret management for sensitive data | [app-secret-env.yaml](./app-secret-env.yaml) |

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
