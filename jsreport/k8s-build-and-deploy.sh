#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define variables
APP_NAME="jsreport"
DOCKER_COMPOSE_FILE="docker-compose_jsreport.yml"
REGISTRY_PATH="1.2.3.4/scada"
NAMESPACE="jsreport"
DEPLOY_FILE="k8s-deploy.yaml"
FULL_IMAGE_NAME="$REGISTRY_PATH/$APP_NAME"

### DOCKER BUILD
# Login to Docker
echo "Logging into Docker..."
docker login || { echo "Docker login failed!"; exit 1; }

# Pull base image from docker-compose
echo "Pulling base image from docker-compose file..."
docker-compose -f $DOCKER_COMPOSE_FILE pull jsreport || { echo "Docker pull failed!"; exit 1; }

# Tag the image for the remote repository
echo "Tagging image as $FULL_IMAGE_NAME..."
docker tag jsreport/jsreport:4.5.0 $FULL_IMAGE_NAME || { echo "Docker tag failed!"; exit 1; }

# Push the image to the remote repository
echo "Pushing image to registry..."
docker push $FULL_IMAGE_NAME || { echo "Docker push failed!"; exit 1; }

### KUBERNETES DEPLOYMENT
# Delete the existing deployment
echo "Deleting existing deployment..."
kubectl delete -f $DEPLOY_FILE --ignore-not-found

# Apply the Kubernetes deployment
echo "Applying Kubernetes deployment..."
kubectl apply -f $DEPLOY_FILE || { echo "Kubernetes deployment failed!"; exit 1; }

# Display deployed resources
echo "Deployed Resources status:"
kubectl get all -n "$NAMESPACE" | grep $APP_NAME

echo "Deployment completed successfully!"
