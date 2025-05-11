# Automated LAMP Stack Deployment and Management on AWS

This project automates the deployment and management of a **LAMP stack** (Linux, Apache, MySQL, PHP) on **AWS** using **Terraform** for infrastructure provisioning and **Ansible** for configuration management. It includes **AWS CloudWatch** for monitoring and a custom dashboard for visualizing key metrics. The setup ensures scalability, security, and observability, making it suitable for production-grade web applications.

## Features

- **Infrastructure as Code**: Provisions AWS resources (VPC, EC2, Security Groups, etc.) using Terraform.
- **Configuration Automation**: Configures the LAMP stack on an EC2 instance using Ansible playbook.
- **Monitoring**: Integrates AWS CloudWatch for monitoring.
- **Dashboard**: Provides a CloudWatch dashboard for visualizing CPU, memory and disk usage.
- **Security**: Implements security best practices (such as Security Groups, parameterized credentials).
- **Reusability**: Modular Terraform and Ansible code for easy customization and redeployment.

## Architecture

The project deploys the following AWS components:

- **VPC**: Custom Virtual Private Cloud with public and private subnets.
- **EC2 Instance**: Hosts the Apache web server, PHP application and MySQL.
- **Security Group**: Controls inbound/outbound traffic for EC2.
- **CloudWatch**: Collects metrics and logs, with a dashboard for visualization.
- **IAM Roles**: Grants necessary permissions for EC2 and CloudWatch.

## Prerequisites

Before you begin, ensure you have the following:

- **AWS Account** with programmatic access (Access Key and Secret Key).
- **Terraform** installed locally.
- **Ansible** installed locally.
- **AWS CLI** configured with your credentials (`aws configure`).
- **SSH Key Pair** created in AWS for EC2 access.
- **Git** installed to clone the repository.

## Project Structure

```
terraform-ansible-stack/
├── roles/lamp-services/tasks/main.yaml      # Ansible roles for Apache, MySQL, PHP, CloudWatch Agent.
├── main.tf                # Main Terraform configuration
├── cloudwatch.tf          # Cloudwatch configuration
├── outputs.tf             # Output values
├── ansible.cfg            # Ansible configuration
├── lamp_provision.yaml    # Main playbook for LAMP stack setup
└── README.md              # This file
```

## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/razackou/terraform-ansible-stack.git
cd terraform-ansible-stack
```

### 2. Configure AWS Credentials

Ensure your AWS CLI is configured:

```bash
aws configure
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Customize Variables

Edit `main.tf` to specify your configuration:

```hcl
vpc_id           = "vpc-bc1bfec9"
subnet_id        = "subnet-879b12a7"
ami_id           = "ami-084568db4383264d4"
instance_type_id = "t2.micro"
ssh_user         = "ubuntu"
key_name         = "your-key-pair"
private_key_path = "your-key-pair.pem"
```

### 5. Deploy Infrastructure

Run the following commands to provision the AWS resources:

```bash
terraform apply
```

This will create the VPC, EC2 instance, Security Group, AMI and CloudWatch resources. Also, Ansible playbook will be run automatically to configure the LAMP stack and install the CloudWatch agent on the EC2 instance.

![1-terra-output](https://github.com/user-attachments/assets/8a1381ad-d88d-459c-b197-cf6aaefaaa8e)

### 6. Access the Application

- **Web Application**: Open the EC2 instance's public IP in a browser (`http://<ec2-public-ip>`).
![2-test-page](https://github.com/user-attachments/assets/74ace597-d54f-471e-87c5-024b87573c3b)

- **Check the whole stack**: Open the EC2 instance's public IP in a browser (`http://<ec2-public-ip>/info.php`)
![3-phpinfo](https://github.com/user-attachments/assets/83562c4b-68b5-4b03-904b-00b40c100cca)

- **CloudWatch Dashboard**: Navigate to the AWS CloudWatch console, select "Dashboards," and view the custom dashboard (`LAMP-Monitoring`).
![4-monitor](https://github.com/user-attachments/assets/693d7d43-b568-42c2-9c5f-7ba83d10c5ec)

![5-dash](https://github.com/user-attachments/assets/14d88ef2-179d-4882-b4c2-d723973827d5)

## Monitoring and Dashboard

The CloudWatch dashboard provides **EC2** metrics.

To customize the dashboard, modify the Terraform code in `cloudwatch.tf`.

## Cleanup

To avoid AWS charges, destroy the infrastructure when done:

```bash
terraform destroy
```

Confirm the destruction when prompted.

![6-destroy](https://github.com/user-attachments/assets/d0d02015-4237-4666-99a5-895611eab2ce)

## Future Improvements

- Add a CI/CD pipeline.
- Add SNS topic ARN to receive alerts by email.
- Migrate the LAMP stack to Docker containers managed by ECS or EKS for better portability and scalability.
- Replace hardcoded credentials with AWS Secrets Manager or AWS Parameter Store.
- Modify Terraform to use EC2 Spot Instances for non-critical workloads to reduce costs, with fallback to On-Demand instances for reliability.
- Enhance CloudWatch Metrics or Integrate AWS X-Ray to trace requests through the LAMP stack.

## Contributing

This is a personal project, but feedback is welcome! Feel free to open an issue or submit a pull request with suggestions.

## License

This project is open-source — feel free to fork, modify, and copy it.

## Contact

For inquiries, reach out via [razackou@gmail.com](mailto:razackou@gmail.com) or connect with me on [LinkedIn](https://www.linkedin.com/in/razakou/).
