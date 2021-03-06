#!/bin/bash
set -o errexit

SECONDS=0  
REGISTRY_CONFIG=${1:-registries.yaml}

# Create docker network
docker network create k3d-kyma || echo "k3d-kyma network already exists"

# Start docker Registry
docker run -d \
  -p 5000:5000 \
  --restart=always \
  --name registry.localhost \
  --network k3d-kyma \
  -v /opt/runners/local-kyma-registry:/var/lib/registry \
  registry:2

# Create Kyma cluster
k3d cluster create kyma \
    --port 80:80@loadbalancer \
    --port 443:443@loadbalancer \
    --k3s-server-arg --no-deploy \
    --k3s-server-arg traefik \
    --network k3d-kyma \
    --volume $PWD/${REGISTRY_CONFIG}:/etc/rancher/k3s/registries.yaml \
    --wait \
    --switch-context \
    --timeout 60s 

echo "Cluster created in $(( $SECONDS/60 )) min $(( $SECONDS % 60 )) sec"
