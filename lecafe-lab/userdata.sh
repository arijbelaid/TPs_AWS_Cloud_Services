#!/bin/bash 
yum update -y 
yum install -y aws-cli 
mkdir -p /opt/lecafe 
cat > /opt/lecafe/config.env << 'ENVEOF' 
APP_NAME=lecafe-ordering 
S3_BUCKET=lecafe-assets 
SQS_QUEUE=lecafe-orders 
AWS_REGION=us-east-1 
ENVEOF 
aws s3 cp s3://lecafe-assets/app/config.txt /opt/lecafe/app-config.txt --region us-east-1 
echo "Le Caf‚ bootstrap complete." >> /var/log/lecafe-setup.log 
