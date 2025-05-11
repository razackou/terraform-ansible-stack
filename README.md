# ansible-stack

Automated LAMP Stack Deployment and Management with Ansible

ensure that ansible is installed on your workstation.

1. Create a key pair and save the private key ####create a keypair on AWS

aws ec2 create-key-pair \
 --key-name myKeyPair \
 --key-type rsa \
 --key-format pem \
 --query 'KeyMaterial' \
 --output text > myKeyPair.pem

2. Secure the key file

chmod 400 myKeyPair.pem

3. Change MySQL root password
