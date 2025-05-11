locals {
  vpc_id           = "vpc-bc2bfac1"
  subnet_id        = "subnet-889b18a9"
  ssh_user         = "ubuntu"
  key_name         = "myKeyPair"
  private_key_path = "myKeyPair.pem"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "lamp" {
  name   = "lamp_access"
  vpc_id = local.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "lamp" {
  ami                         = "ami-084568db4383264d4"
  subnet_id                   = local.subnet_id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.lamp.id]
  key_name                    = local.key_name

  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.lamp.public_ip
    }
  }
  provisioner "local-exec" {
    command = "ansible-playbook  -i ${aws_instance.lamp.public_ip}, --private-key ${local.private_key_path} -u ${local.ssh_user} lamp_provision.yaml"
  }
}

output "lamp_ip" {
  value = aws_instance.lamp.public_ip
}
