# ☕ Le Café – AWS Hands-On Labs with LocalStack

**Infrastructure as Code · IAM · S3 · EC2 · SQS · SNS · CloudFormation**

[![LocalStack](https://img.shields.io/badge/LocalStack-3.0-blue)](https://localstack.cloud/)
[![AWS CLI](https://img.shields.io/badge/AWS%20CLI-2.x-orange)](https://aws.amazon.com/cli/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

---

## 📖 Overview

This repository contains the complete series of **Le Café** hands-on labs that guide you from zero to a fully working AWS-like infrastructure using **LocalStack**.

You will learn:

- **IAM** (users, roles, policies)  
- **S3** (storage, versioning, website)  
- **EC2** (instances, security)  
- **SQS & SNS** (messaging)  
- **CloudFormation** (Infrastructure as Code)  

✅ 100% local → no AWS account needed

---

## 🧰 Prerequisites

- Docker Desktop  
- Python 3.8+  
- AWS CLI  
- LocalStack CLI  

```bash
pip install localstack awscli-local
```

---

## 🚀 Quick Start

```bash
localstack start -d
```

```bash
aws configure --profile localstack
```

```bash
export AWS_PROFILE=localstack
# Windows:
set AWS_PROFILE=localstack
```

---

## 📂 Labs Overview

| Lab | Description |
|-----|------------|
| 00 | Setup LocalStack + S3 + SQS |
| 01 | IAM |
| 02 | S3 Advanced |
| 03 | EC2 |
| 04 | SQS & SNS |
| 05 | CloudFormation |

---

# 📂 Commandes clés par lab

---

## 🔹 Lab 00 – Découverte (S3, IAM, SQS)

```bash
# Créer un bucket S3
awslocal s3 mb s3://lecafe-menus

# Uploader un fichier
echo "Menu" > menu.txt
awslocal s3 cp menu.txt s3://lecafe-menus/menu.txt

# Lister les buckets
awslocal s3 ls

# Créer un utilisateur IAM
awslocal iam create-user --user-name lecafe-app

# Attacher une politique S3 read-only
awslocal iam attach-user-policy --user-name lecafe-app --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess

# Créer une file SQS
awslocal sqs create-queue --queue-name lecafe-orders

# Envoyer un message
awslocal sqs send-message --queue-url http://localhost:4566/000000000000/lecafe-orders --message-body '{"item":"Latte"}'

# Recevoir un message
awslocal sqs receive-message --queue-url http://localhost:4566/000000000000/lecafe-orders
```

---

## 🔹 Lab 01 – IAM (utilisateurs, groupes, rôles)

```bash
# Créer les utilisateurs
awslocal iam create-user --user-name alice
awslocal iam create-user --user-name bob
awslocal iam create-user --user-name charlie

# Créer les groupes
awslocal iam create-group --group-name cafe-developers
awslocal iam create-group --group-name cafe-operations

# Ajouter les utilisateurs aux groupes
awslocal iam add-user-to-group --user-name alice --group-name cafe-developers
awslocal iam add-user-to-group --user-name bob --group-name cafe-developers
awslocal iam add-user-to-group --user-name charlie --group-name cafe-operations

# Créer une policy
awslocal iam create-policy --policy-name LeCafe-Developer-S3 --policy-document file://developer-s3-policy.json

# Attacher policy au groupe
awslocal iam attach-group-policy --group-name cafe-developers --policy-arn arn:aws:iam::000000000000:policy/LeCafe-Developer-S3

# Créer un rôle
awslocal iam create-role --role-name lecafe-app-role --assume-role-policy-document file://trust-policy.json

# Ajouter policy au rôle
awslocal iam put-role-policy --role-name lecafe-app-role --policy-name LeCafe-App-Permissions --policy-document file://app-role-policy.json

# Assumer rôle
awslocal sts assume-role --role-arn arn:aws:iam::000000000000:role/lecafe-app-role --role-session-name test-session
```

---

## 🔹 Lab 02 – S3 (versionnement, site statique)

```bash
# Créer buckets
awslocal s3 mb s3://lecafe-assets
awslocal s3 mb s3://lecafe-website
awslocal s3 mb s3://lecafe-logs

# Activer versioning
awslocal s3api put-bucket-versioning --bucket lecafe-assets --versioning-configuration Status=Enabled

# Versions
echo "version 1" > config.txt
awslocal s3 cp config.txt s3://lecafe-assets/app/config.txt

echo "version 2" > config.txt
awslocal s3 cp config.txt s3://lecafe-assets/app/config.txt

# Lister versions
awslocal s3api list-object-versions --bucket lecafe-assets

# Website
awslocal s3api put-bucket-website --bucket lecafe-website --website-configuration '{"IndexDocument":{"Suffix":"index.html"}}'

# Upload site
awslocal s3 cp index.html s3://lecafe-website/index.html

# Accès
curl http://localhost:4566/lecafe-website/index.html
```

---

## 🔹 Lab 03 – EC2

```bash
# Key pair
awslocal ec2 create-key-pair --key-name lecafe-keypair --query 'KeyMaterial' --output text > lecafe-keypair.pem

# VPC
VPC_ID=$(awslocal ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query 'Vpcs[0].VpcId' --output text)

# Security group
SG_ID=$(awslocal ec2 create-security-group --group-name lecafe-app-sg --description "Security group" --vpc-id $VPC_ID --query 'GroupId' --output text)

# Rules
awslocal ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 80 --cidr 0.0.0.0/0

# Instance profile
awslocal iam create-instance-profile --instance-profile-name lecafe-app-profile
awslocal iam add-role-to-instance-profile --instance-profile-name lecafe-app-profile --role-name lecafe-app-role

# Launch instance
INSTANCE_ID=$(awslocal ec2 run-instances --image-id ami-0c02fb55956c7d316 --instance-type t3.micro --key-name lecafe-keypair --security-group-ids $SG_ID --iam-instance-profile Name=lecafe-app-profile --query 'Instances[0].InstanceId' --output text)

# Status
awslocal ec2 describe-instances --instance-ids $INSTANCE_ID
```

---

## 🔹 Lab 04 – SQS & SNS (messagerie, fan-out)

```bash
# Créer une file standard (kitchen)
awslocal sqs create-queue --queue-name lecafe-kitchen-orders

# Créer une DLQ
DLQ_URL=$(awslocal sqs create-queue --queue-name lecafe-kitchen-orders-dlq --query 'QueueUrl' --output text)
DLQ_ARN=$(awslocal sqs get-queue-attributes --queue-url $DLQ_URL --attribute-names QueueArn --query 'Attributes.QueueArn' --output text)

# Attacher la DLQ à la queue principale
QUEUE_URL=$(awslocal sqs get-queue-url --queue-name lecafe-kitchen-orders --query 'QueueUrl' --output text)

awslocal sqs set-queue-attributes \
  --queue-url $QUEUE_URL \
  --attributes RedrivePolicy="{\"deadLetterTargetArn\":\"$DLQ_ARN\",\"maxReceiveCount\":\"3\"}"

# Créer les files aval
QUEUE_URL_INVENTORY=$(awslocal sqs create-queue --queue-name lecafe-inventory-updates --query 'QueueUrl' --output text)
QUEUE_URL_LOYALTY=$(awslocal sqs create-queue --queue-name lecafe-loyalty-points --query 'QueueUrl' --output text)
QUEUE_URL_MANAGER=$(awslocal sqs create-queue --queue-name lecafe-manager-alerts --query 'QueueUrl' --output text)

# Récupérer les ARN
QUEUE_ARN_INVENTORY=$(awslocal sqs get-queue-attributes --queue-url $QUEUE_URL_INVENTORY --attribute-names QueueArn --query 'Attributes.QueueArn' --output text)
QUEUE_ARN_LOYALTY=$(awslocal sqs get-queue-attributes --queue-url $QUEUE_URL_LOYALTY --attribute-names QueueArn --query 'Attributes.QueueArn' --output text)
QUEUE_ARN_MANAGER=$(awslocal sqs get-queue-attributes --queue-url $QUEUE_URL_MANAGER --attribute-names QueueArn --query 'Attributes.QueueArn' --output text)

# Créer un topic SNS
TOPIC_ARN=$(awslocal sns create-topic --name lecafe-orders-topic --query 'TopicArn' --output text)

# Autoriser SNS à publier dans les queues (policy)
for QUEUE_URL in $QUEUE_URL_INVENTORY $QUEUE_URL_LOYALTY $QUEUE_URL_MANAGER
do
  QUEUE_ARN=$(awslocal sqs get-queue-attributes --queue-url $QUEUE_URL --attribute-names QueueArn --query 'Attributes.QueueArn' --output text)

  awslocal sqs set-queue-attributes \
    --queue-url $QUEUE_URL \
    --attributes Policy="{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"SQS:SendMessage\",\"Resource\":\"$QUEUE_ARN\",\"Condition\":{\"ArnEquals\":{\"aws:SourceArn\":\"$TOPIC_ARN\"}}}]}"
done

# Abonner les queues au topic
SUB_ARN_INVENTORY=$(awslocal sns subscribe --topic-arn $TOPIC_ARN --protocol sqs --notification-endpoint $QUEUE_ARN_INVENTORY --query 'SubscriptionArn' --output text)
SUB_ARN_LOYALTY=$(awslocal sns subscribe --topic-arn $TOPIC_ARN --protocol sqs --notification-endpoint $QUEUE_ARN_LOYALTY --query 'SubscriptionArn' --output text)
SUB_ARN_MANAGER=$(awslocal sns subscribe --topic-arn $TOPIC_ARN --protocol sqs --notification-endpoint $QUEUE_ARN_MANAGER --query 'SubscriptionArn' --output text)

# Appliquer filtre (manager reçoit seulement priorité high)
awslocal sns set-subscription-attributes \
  --subscription-arn $SUB_ARN_MANAGER \
  --attribute-name FilterPolicy \
  --attribute-value '{"Priority":["high"]}'

# Publier messages
awslocal sns publish \
  --topic-arn $TOPIC_ARN \
  --message '{"orderId":"ORD-100"}' \
  --message-attributes '{"Priority":{"DataType":"String","StringValue":"high"}}'

awslocal sns publish \
  --topic-arn $TOPIC_ARN \
  --message '{"orderId":"ORD-101"}' \
  --message-attributes '{"Priority":{"DataType":"String","StringValue":"normal"}}'

# Vérifier messages dans chaque queue
for QUEUE_URL in $QUEUE_URL_INVENTORY $QUEUE_URL_LOYALTY $QUEUE_URL_MANAGER
do
  awslocal sqs get-queue-attributes \
    --queue-url $QUEUE_URL \
    --attribute-names ApproximateNumberOfMessages
done
```

---

## 🔹 Lab 05 – CloudFormation (Infrastructure as Code)

```bash
# Valider le template
awslocal cloudformation validate-template \
  --template-body file://lecafe-stack.yaml

# Créer la stack
awslocal cloudformation create-stack \
  --stack-name lecafe-stack \
  --template-body file://lecafe-stack.yaml \
  --parameters ParameterKey=EnvironmentName,ParameterValue=development \
               ParameterKey=LogRetentionDays,ParameterValue=30 \
  --capabilities CAPABILITY_NAMED_IAM

# Voir les événements
awslocal cloudformation describe-stack-events \
  --stack-name lecafe-stack

# Vérifier statut
awslocal cloudformation describe-stacks \
  --stack-name lecafe-stack \
  --query 'Stacks[0].StackStatus'

# Lister ressources
awslocal cloudformation list-stack-resources \
  --stack-name lecafe-stack

# Récupérer outputs
awslocal cloudformation describe-stacks \
  --stack-name lecafe-stack \
  --query 'Stacks[0].Outputs'

# Créer un change set
awslocal cloudformation create-change-set \
  --stack-name lecafe-stack \
  --change-set-name update-retention \
  --template-body file://lecafe-stack.yaml \
  --parameters ParameterKey=LogRetentionDays,ParameterValue=14 \
  --capabilities CAPABILITY_NAMED_IAM

# Examiner change set
awslocal cloudformation describe-change-set \
  --stack-name lecafe-stack \
  --change-set-name update-retention \
  --query 'Changes[*].ResourceChange'

# Exécuter change set
awslocal cloudformation execute-change-set \
  --stack-name lecafe-stack \
  --change-set-name update-retention

# Supprimer stack
awslocal cloudformation delete-stack \
  --stack-name lecafe-stack
```
