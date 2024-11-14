# setup.sh
#!/bin/bash
set -euo pipefail

# Start devbox shell
echo "Starting devbox shell..."
devbox shell

# Create KinD cluster
echo "Creating KinD cluster..."
kind create cluster --config kind-config.yaml --name argocd-playground

# Create argocd namespace
echo "Creating argocd namespace..."
kubectl create namespace argocd

# Install ArgoCD
echo "Installing ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Patch ArgoCD service to use NodePort
echo "Patching ArgoCD service..."
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort", "ports": [{"port": 80, "nodePort": 30080}, {"port": 443, "nodePort": 30443}]}}'

# Wait for ArgoCD to be ready
echo "Waiting for ArgoCD pods to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

# Get initial admin password
echo "ArgoCD initial admin password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo

# Print access information
echo "ArgoCD UI is available at: https://localhost:30443"
echo "Username: admin"
echo "Use the password printed above to log in"

