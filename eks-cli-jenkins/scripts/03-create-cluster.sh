#!/bin/bash
set -e

source /tmp/eks-network-ids.env

CLUSTER_NAME=${CLUSTER_NAME:-"jenkins-eks-cluster"}
AWS_REGION=${AWS_REGION:-"us-east-1"}
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
CLUSTER_ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/${CLUSTER_NAME}-eks-cluster-role"

echo "=========================================="
echo " Creating EKS Cluster: ${CLUSTER_NAME}"
echo "=========================================="

aws eks create-cluster \
  --name ${CLUSTER_NAME} \
  --region ${AWS_REGION} \
  --kubernetes-version 1.29 \
  --role-arn ${CLUSTER_ROLE_ARN} \
  --resources-vpc-config \
    subnetIds=${SUBNET1_ID},${SUBNET2_ID},securityGroupIds=${SG_ID},endpointPublicAccess=true,endpointPrivateAccess=false

echo "⏳ Waiting for cluster to become ACTIVE (this takes ~12 minutes)..."

aws eks wait cluster-active \
  --name ${CLUSTER_NAME} \
  --region ${AWS_REGION}

echo "✓ EKS Cluster is ACTIVE"

# ── Configure kubectl ─────────────────────────
aws eks update-kubeconfig \
  --region ${AWS_REGION} \
  --name ${CLUSTER_NAME}

echo "✓ kubectl configured"
kubectl cluster-info