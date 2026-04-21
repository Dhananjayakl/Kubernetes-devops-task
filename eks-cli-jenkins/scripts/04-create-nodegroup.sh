#!/bin/bash
set -e

source /tmp/eks-network-ids.env

CLUSTER_NAME=${CLUSTER_NAME:-"jenkins-eks-cluster"}
AWS_REGION=${AWS_REGION:-"us-east-1"}
NODE_INSTANCE_TYPE=${NODE_INSTANCE_TYPE:-"t3.medium"}
DESIRED_NODES=${DESIRED_NODES:-2}
MIN_NODES=${MIN_NODES:-1}
MAX_NODES=${MAX_NODES:-3}
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
NODE_ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/${CLUSTER_NAME}-eks-node-role"

echo "=========================================="
echo " Creating Node Group"
echo "=========================================="

aws eks create-nodegroup \
  --cluster-name ${CLUSTER_NAME} \
  --nodegroup-name ${CLUSTER_NAME}-nodegroup \
  --node-role ${NODE_ROLE_ARN} \
  --subnets ${SUBNET1_ID} ${SUBNET2_ID} \
  --instance-types ${NODE_INSTANCE_TYPE} \
  --scaling-config minSize=${MIN_NODES},maxSize=${MAX_NODES},desiredSize=${DESIRED_NODES} \
  --disk-size 20 \
  --ami-type AL2_x86_64 \
  --region ${AWS_REGION}

echo "⏳ Waiting for node group to become ACTIVE (this takes ~5 minutes)..."

aws eks wait nodegroup-active \
  --cluster-name ${CLUSTER_NAME} \
  --nodegroup-name ${CLUSTER_NAME}-nodegroup \
  --region ${AWS_REGION}

echo "✓ Node group is ACTIVE"