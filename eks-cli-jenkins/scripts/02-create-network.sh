#!/bin/bash
set -e

CLUSTER_NAME=${CLUSTER_NAME:-"jenkins-eks-cluster"}
AWS_REGION=${AWS_REGION:-"us-east-1"}

echo "=========================================="
echo " Creating VPC & Networking"
echo "=========================================="

# ── VPC ───────────────────────────────────────
VPC_ID=$(aws ec2 create-vpc \
  --cidr-block 10.0.0.0/16 \
  --query 'Vpc.VpcId' \
  --output text)

aws ec2 create-tags \
  --resources $VPC_ID \
  --tags Key=Name,Value=${CLUSTER_NAME}-vpc \
         Key=kubernetes.io/cluster/${CLUSTER_NAME},Value=shared

aws ec2 modify-vpc-attribute \
  --vpc-id $VPC_ID \
  --enable-dns-hostnames

aws ec2 modify-vpc-attribute \
  --vpc-id $VPC_ID \
  --enable-dns-support

echo "✓ VPC created: $VPC_ID"

# ── Internet Gateway ──────────────────────────
IGW_ID=$(aws ec2 create-internet-gateway \
  --query 'InternetGateway.InternetGatewayId' \
  --output text)

aws ec2 attach-internet-gateway \
  --internet-gateway-id $IGW_ID \
  --vpc-id $VPC_ID

echo "✓ Internet Gateway: $IGW_ID"

# ── Subnets (2 AZs) ───────────────────────────
SUBNET1_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block 10.0.1.0/24 \
  --availability-zone ${AWS_REGION}a \
  --query 'Subnet.SubnetId' \
  --output text)

aws ec2 create-tags \
  --resources $SUBNET1_ID \
  --tags Key=Name,Value=${CLUSTER_NAME}-subnet-1 \
         Key=kubernetes.io/cluster/${CLUSTER_NAME},Value=shared \
         Key=kubernetes.io/role/elb,Value=1

SUBNET2_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block 10.0.2.0/24 \
  --availability-zone ${AWS_REGION}b \
  --query 'Subnet.SubnetId' \
  --output text)

aws ec2 create-tags \
  --resources $SUBNET2_ID \
  --tags Key=Name,Value=${CLUSTER_NAME}-subnet-2 \
         Key=kubernetes.io/cluster/${CLUSTER_NAME},Value=shared \
         Key=kubernetes.io/role/elb,Value=1

aws ec2 modify-subnet-attribute \
  --subnet-id $SUBNET1_ID \
  --map-public-ip-on-launch

aws ec2 modify-subnet-attribute \
  --subnet-id $SUBNET2_ID \
  --map-public-ip-on-launch

echo "✓ Subnets: $SUBNET1_ID, $SUBNET2_ID"

# ── Route Table ───────────────────────────────
RT_ID=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --query 'RouteTable.RouteTableId' \
  --output text)

aws ec2 create-route \
  --route-table-id $RT_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $IGW_ID

aws ec2 associate-route-table --route-table-id $RT_ID --subnet-id $SUBNET1_ID
aws ec2 associate-route-table --route-table-id $RT_ID --subnet-id $SUBNET2_ID

echo "✓ Route table configured"

# ── Security Group ────────────────────────────
SG_ID=$(aws ec2 create-security-group \
  --group-name ${CLUSTER_NAME}-sg \
  --description "EKS Cluster Security Group" \
  --vpc-id $VPC_ID \
  --query 'GroupId' \
  --output text)

aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 443 \
  --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 10250 \
  --cidr 10.0.0.0/16

echo "✓ Security Group: $SG_ID"

# ── Save IDs to file (read by later stages) ───
cat > /tmp/eks-network-ids.env <<EOF
VPC_ID=${VPC_ID}
SUBNET1_ID=${SUBNET1_ID}
SUBNET2_ID=${SUBNET2_ID}
SG_ID=${SG_ID}
IGW_ID=${IGW_ID}
RT_ID=${RT_ID}
EOF

echo ""
echo "Network IDs saved to /tmp/eks-network-ids.env"
cat /tmp/eks-network-ids.env