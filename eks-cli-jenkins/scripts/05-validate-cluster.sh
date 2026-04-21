#!/bin/bash
set -e

CLUSTER_NAME=${CLUSTER_NAME:-"jenkins-eks-cluster"}
AWS_REGION=${AWS_REGION:-"us-east-1"}

echo "=========================================="
echo " Validating EKS Cluster"
echo "=========================================="

aws eks update-kubeconfig \
  --region ${AWS_REGION} \
  --name ${CLUSTER_NAME}

echo "--- Cluster Info ---"
aws eks describe-cluster \
  --name ${CLUSTER_NAME} \
  --query 'cluster.{Name:name,Status:status,Version:version,Endpoint:endpoint}' \
  --output table

echo "--- Node Group Status ---"
aws eks describe-nodegroup \
  --cluster-name ${CLUSTER_NAME} \
  --nodegroup-name ${CLUSTER_NAME}-nodegroup \
  --query 'nodegroup.{Name:nodegroupName,Status:status,InstanceType:instanceTypes}' \
  --output table

echo "--- Kubernetes Nodes ---"
kubectl get nodes -o wide

echo "--- System Pods ---"
kubectl get pods -n kube-system

echo "--- All Namespaces ---"
kubectl get namespaces

echo ""
echo "✓ Cluster validation complete!"