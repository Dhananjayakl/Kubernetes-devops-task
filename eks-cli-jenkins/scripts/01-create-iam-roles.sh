#!/bin/bash
set -e

CLUSTER_NAME=${CLUSTER_NAME:-"jenkins-eks-cluster"}

echo "=========================================="
echo " Creating IAM Roles"
echo "=========================================="

# ── EKS Cluster Role ──────────────────────────
aws iam create-role \
  --role-name ${CLUSTER_NAME}-eks-cluster-role \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": { "Service": "eks.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }]
  }' || echo "Cluster role already exists, skipping..."

aws iam attach-role-policy \
  --role-name ${CLUSTER_NAME}-eks-cluster-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy

echo "✓ EKS Cluster IAM role ready"

# ── Node Group Role ───────────────────────────
aws iam create-role \
  --role-name ${CLUSTER_NAME}-eks-node-role \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }]
  }' || echo "Node role already exists, skipping..."

aws iam attach-role-policy \
  --role-name ${CLUSTER_NAME}-eks-node-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy

aws iam attach-role-policy \
  --role-name ${CLUSTER_NAME}-eks-node-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy

aws iam attach-role-policy \
  --role-name ${CLUSTER_NAME}-eks-node-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly

echo "✓ EKS Node Group IAM role ready"