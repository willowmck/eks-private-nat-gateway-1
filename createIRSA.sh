##!/bin/bash
REGION=us-west-2
SERVICE_ACCOUNT_NAMESPACE=kube-system
SERVICE_ACCOUNT_NAME=aws-load-balancer-controller

SERVICE_ACCOUNT_IAM_POLICY=EKS-PrivateNAT-AWSLB-Controller-Policy
#SERVICE_ACCOUNT_IAM_POLICY_ARN=$(aws iam create-policy --policy-name $SERVICE_ACCOUNT_IAM_POLICY \
#--policy-document file://iam-policy.json \
#--query 'Policy.Arn' --output text)
SERVICE_ACCOUNT_IAM_POLICY_ARN="arn:aws:iam::986112284769:policy/EKS-PrivateNAT-AWSLB-Controller-Policy"


#
# Create IAM role and service account for cluster A
#
CLUSTER_NAME="EKS-CLUSTER-A"
SERVICE_ACCOUNT_IAM_ROLE=EKS-AWSLB-Controller-Role-$CLUSTER_NAME

eksctl utils associate-iam-oidc-provider \
--cluster=$CLUSTER_NAME \
--region=$REGION \
--approve

eksctl create iamserviceaccount \
--cluster=$CLUSTER_NAME \
--region=$REGION \
--name=$SERVICE_ACCOUNT_NAME \
--namespace=$SERVICE_ACCOUNT_NAMESPACE \
--role-name=$SERVICE_ACCOUNT_IAM_ROLE \
--attach-policy-arn=$SERVICE_ACCOUNT_IAM_POLICY_ARN \
--override-existing-serviceaccounts \
--approve


#
# Create IAM role and service account for cluster B
#
CLUSTER_NAME="EKS-CLUSTER-B"
SERVICE_ACCOUNT_IAM_ROLE=EKS-AWSLB-Controller-Role-$CLUSTER_NAME

eksctl utils associate-iam-oidc-provider \
--cluster=$CLUSTER_NAME \
--region=$REGION \
--approve

eksctl create iamserviceaccount \
--cluster=$CLUSTER_NAME \
--region=$REGION \
--name=$SERVICE_ACCOUNT_NAME \
--namespace=$SERVICE_ACCOUNT_NAMESPACE \
--role-name=$SERVICE_ACCOUNT_IAM_ROLE \
--attach-policy-arn=$SERVICE_ACCOUNT_IAM_POLICY_ARN \
--override-existing-serviceaccounts \
--approve

#
# Create IAM role and service account for cluster C
#
CLUSTER_NAME="EKS-CLUSTER-C"
SERVICE_ACCOUNT_IAM_ROLE=EKS-AWSLB-Controller-Role-$CLUSTER_NAME

eksctl utils associate-iam-oidc-provider \
--cluster=$CLUSTER_NAME \
--region=$REGION \
--approve

eksctl create iamserviceaccount \
--cluster=$CLUSTER_NAME \
--region=$REGION \
--name=$SERVICE_ACCOUNT_NAME \
--namespace=$SERVICE_ACCOUNT_NAMESPACE \
--role-name=$SERVICE_ACCOUNT_IAM_ROLE \
--attach-policy-arn=$SERVICE_ACCOUNT_IAM_POLICY_ARN \
--override-existing-serviceaccounts \
--approve

helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --kube-context mgmt \
  --set clusterName=EKS-CLUSTER-A \
  --set serviceAccount.create=false \
  --set hostNetwork=true \
  --set serviceAccount.name=aws-load-balancer-controller 

helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --kube-context web \
  --set clusterName=EKS-CLUSTER-B \
  --set serviceAccount.create=false \
  --set hostNetwork=true \
  --set serviceAccount.name=aws-load-balancer-controller 

helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --kube-context lob \
  --set clusterName=EKS-CLUSTER-C \
  --set serviceAccount.create=false \
  --set hostNetwork=true \
  --set serviceAccount.name=aws-load-balancer-controller
