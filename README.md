# ☕ Le Café – AWS Hands-On Labs with LocalStack

**Infrastructure as Code · IAM · S3 · EC2 · SQS · SNS · CloudFormation**

[![LocalStack](https://img.shields.io/badge/LocalStack-3.0-blue)](https://localstack.cloud/)
[![AWS CLI](https://img.shields.io/badge/AWS%20CLI-2.x-orange)](https://aws.amazon.com/cli/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

## 📖 Overview

This repository contains the complete series of **Le Café** hands-on labs that guide you from zero to a fully working AWS-like infrastructure – entirely on your local machine using **LocalStack**.

You will learn core AWS services by building a realistic coffee shop ordering platform:  
- **IAM** users, groups, roles and least-privilege policies  
- **S3** versioned buckets, static website hosting, lifecycle rules  
- **EC2** security groups, key pairs, instance profiles, user data  
- **SQS** standard & FIFO queues, dead-letter queues, visibility timeouts  
- **SNS** pub/sub topics, subscription filters, fan-out to SQS  
- **CloudFormation** infrastructure as code – parameters, outputs, change sets  

All resources are created locally, without an AWS account or any cloud cost.

---

## 🧰 Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (or Docker Engine on Linux)
- [Python 3.8+](https://www.python.org/) with `pip`
- [AWS CLI](https://aws.amazon.com/cli/) (v2 recommended)
- LocalStack CLI & `awslocal` wrapper

Install the required Python packages:

```bash
pip install localstack awscli-local
```

---

## 🚀 Quick Start

### Start LocalStack

```bash
localstack start -d
```

### Configure a fake AWS profile

```bash
aws configure --profile localstack
# Access Key: test
# Secret: test
# region: us-east-1
# output: json
```

```bash
export AWS_PROFILE=localstack   # Windows: set AWS_PROFILE=localstack
```

Run any lab – each lab folder contains step-by-step commands (CLI or CloudFormation).  
The final infrastructure is also available as a single CloudFormation template:

```
lecafe-stack.yaml
```

---

## 🔍 Explore the live resources

```bash
awslocal s3 ls
awslocal sqs list-queues
```

CloudFormation stack UI:  
http://localhost:4566/_localstack/cloudformation/resources

---

## 📂 Labs Overview

| Lab | Topic | Key Skills |
|-----|------|----------|
| 00 | LocalStack Setup & First Resources | awslocal, S3, IAM User, SQS basics |
| 01 | Identity & Access Management | IAM groups, custom policies, service roles, sts:AssumeRole |
| 02 | Object Storage (S3) | Versioning, bucket policies, static website, lifecycle rules |
| 03 | Compute (EC2) | Key pairs, security groups, instance profiles, user data |
| 04 | Messaging (SQS & SNS) | Dead-letter queues, FIFO, pub/sub, filter policies, fan-out |
| 05 | Infrastructure as Code (CloudFormation) | Declarative templates, parameters, outputs, change sets |

Each lab folder contains a detailed README with commands and expected outputs.  
The `lecafe-stack.yaml` file defines the entire Le Café stack (IAM, S3, SQS, SNS).

---

## 🛠️ Technologies Used

- **LocalStack** – AWS emulator running inside Docker  
- **AWS CLI + awslocal** – command-line interaction  
- **CloudFormation** – infrastructure as code  

**Services emulated:** IAM, S3, EC2, SQS, SNS, STS, CloudFormation

---

## 📷 Example Output

After deploying the CloudFormation stack:

```json
{
  "Outputs": [
    {"Key": "AssetsBucketName", "Value": "lecafe-assets-development"},
    {"Key": "OrdersTopicArn", "Value": "arn:aws:sns:us-east-1:000000000000:lecafe-orders-topic-development"},
    {"Key": "KitchenQueueUrl", "Value": "http://sqs.us-east-1.localhost.localstack.cloud:4566/.../lecafe-kitchen-orders-development"}
  ]
}
```

Publishing a high-priority order to SNS delivers it only to the manager’s queue – filter policy works as expected.

---

## 📸 Détails des étapes & Captures

---

### 🔹 Lab 00 – Prise en main (S3, IAM, SQS)

**Installation LocalStack CLI**  
![Structure](lab0/verifier_installation_localStack_CLI.png)

**Health check des services**  
![Structure](screenshot/lab0/localstack_health.png)

**Création du bucket S3**  
![Structure](screenshot/lab0/create_bucket.png)

**Envoi d’un message SQS**  
![Structure](screenshot/lab0/SQS_Message_Sent.png)

**Réception du message SQS**  
![Structure](screenshot/lab0/SQS_Message_Received.png)

---

### 🔹 Lab 01 – IAM (utilisateurs, groupes, rôles)

**Création des utilisateurs**  
![Structure](screenshot/lab01/utilisateurs_IAM_cr%C3%A9es.png)

**Création des groupes**  
![Structure](screenshot/lab01/Groupes_IAM_cr%C3%A9s.png)

**Politiques attachées aux groupes**  
![Structure](screenshot/lab01/Politiques_attach%C3%A9es_aux_groupes.png)

**Création du rôle IAM**  
![Structure](screenshot/lab01/role_cree.png)

**Assumption du rôle (STS)**  
![Structure](screenshot/lab01/Simuler_assumption_r%C3%B4le.png)

---

### 🔹 Lab 02 – S3 (versionnement, site statique, lifecycle)

**Création des 3 buckets**  
![Structure](screenshot/lab02/Creer_3_buckets.png)

**Versionnement activé**  
![Structure](screenshot/lab02/Activer_versionnement_bucket_assets.png)

**Upload de deux versions**  
![Structure](screenshot/lab02/Creer_uploader_version1_2.png)

**Page d’accueil du site statique**  
![Structure](screenshot/lab02/Static%20Website%20-%20Homepage.png)

**Règle de cycle de vie configurée**  
![Structure](screenshot/lab02/Lifecycle_rule_configur%C3%A9e.png)

---

### 🔹 Lab 03 – EC2 (key pairs, security groups, instance)

**Création de la paire de clés**  
![Structure](screenshot/lab03/Cr%C3%A9er_paire_cl%C3%A9s.png)

**ID du groupe de sécurité**  
![Structure](screenshot/lab03/ID_groupe_s%C3%A9curit%C3%A9.png)

**Lancement de l’instance EC2**  
![Structure](screenshot/lab03/lancer_instance.png)

**Profil IAM attaché à l’instance**  
![Structure](screenshot/lab03/profil_IAM_attach%C3%A9_instance.png)

**Vue d’ensemble complète de la stack**  
![Structure](screenshot/lab03/Vue_ensemble_compl%C3%A8te_stack.png)

---

### 🔹 Lab 04 – SQS & SNS (fan-out, filtres)

**Création du topic SNS**  
![Structure](screenshot/lab04/creation_SNS_topic.png)

**Création des trois files aval**  
![Structure](screenshot/lab04/Creer_les_trois_files_aval.png)

**Abonnement des files au topic**  
![Structure](screenshot/lab04/Abonner_files_au_SNS.png)

**Publication des deux commandes (high & normal)**  
![Structure](screenshot/lab04/Publication_deux_commandes_SNS.png)

**Vérification du nombre de messages**  
![Structure](screenshot/lab04/V%C3%A9rifier_nbr_mssg_dans_chaque_file.png)

---

### 🔹 Lab 05 – CloudFormation (Infrastructure as Code)

**Validation du template YAML**  
![Structure](screenshot/lab05/Valider_template.png)

**Création de la stack**  
![Structure](screenshot/lab05/Creer_stack.png)

**Événements de déploiement**  
![Structure](screenshot/lab05/Surveiller_cr%C3%A9ation.png)

**Outputs de la stack**  
![Structure](screenshot/lab05/Inspector_output.png)

**Création et examen d’un change set**  
![Structure](screenshot/lab05/Examiner_change_set.png)

---

## 🧹 Clean Up

```bash
awslocal cloudformation delete-stack --stack-name lecafe-stack

awslocal s3 rm s3://lecafe-assets-development --recursive
awslocal s3 rb s3://lecafe-assets-development

awslocal s3 rm s3://lecafe-logs-development --recursive
awslocal s3 rb s3://lecafe-logs-development

localstack stop
```
