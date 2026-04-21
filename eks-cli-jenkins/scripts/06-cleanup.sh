#!/bin/bash
set -e

source /tmp/eks-network-ids.env

CLUSTER_NAME=${CLUSTER_NAME:-"jenkins-eks-cluster"}
AWS_REGION=${AWS_REGION:-"us-east-1"}
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "=========================================="
echo " Destroying EKS Cluster & Resources"
echo "=========================================="

# Delete node group first
aws eks delete-nodegroup \
  --cluster-name ${CLUSTER_NAME} \
  --nodegroup-name ${CLUSTER_NAME}-nodegroup \
  --region ${AWS_REGION} || true

echo "⏳ Waiting for node group deletion..."
aws eks wait nodegroup-deleted \
  --cluster-name ${CLUSTER_NAME} \
  --nodegroup-name ${CLUSTER_NAME}-nodegroup \
  --region ${AWS_REGION} || true

# Delete cluster
aws eks delete-cluster \
  --name ${CLUSTER_NAME} \
  --region ${AWS_REGION} || true

echo "⏳ Waiting for cluster deletion..."
aws eks wait cluster-deleted \
  --name ${CLUSTER_NAME} \
  --region ${AWS_REGION} || true

# Detach & delete IAM roles
for policy in AmazonEKSClusterPolicy; do
  aws iam detach-role-policy \
    --role-name ${CLUSTER_NAME}-eks-cluster-role \
    --policy-arn arn:aws:iam::aws:policy/$policy || true
done

for policy in AmazonEKSWorkerNodePolicy AmazonEKS_CNI_Policy AmazonEC2ContainerRegistryReadOnly; do
  aws iam detach-role-policy \
    --role-name ${CLUSTER_NAME}-eks-node-role \
    --policy-arn arn:aws:iam::aws:policy/$policy || true
done

aws iam delete-role --role-name ${CLUSTER_NAME}-eks-cluster-role || true
aws iam delete-role --role-name ${CLUSTER_NAME}-eks-node-role || true

# Network cleanup
aws ec2 delete-subnet --subnet-id ${SUBNET1_ID} || true
aws ec2 delete-subnet --subnet-id ${SUBNET2_ID} || true
aws ec2 delete-route-table --route-table-id ${RT_ID} || true
aws ec2 detach-internet-gateway \
  --internet-gateway-id ${IGW_ID} \
  --vpc-id ${VPC_ID} || true
aws ec2 delete-internet-gateway \
  --internet-gateway-id ${IGW_ID} || true
aws ec2 delete-security-group --group-id ${SG_ID} || true
aws ec2 delete-vpc --vpc-id ${VPC_ID} || true

echo "✓ All resources cleaned up"