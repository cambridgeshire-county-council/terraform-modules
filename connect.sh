#!/bin/bash
rm cambs-insight.pem
terraform output -raw private_key > cambs-insight.pem
ssh -o 'PubkeyAcceptedKeyTypes +ssh-rsa' -i cambs-insight.pem ec2-user@$(terraform output -raw ec2_ip)