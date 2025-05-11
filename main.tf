locals {
  vpc_id           = "vpc-bc2bfac1" ##no vpc so that it will use the defaut vpc  # of finally keep it like that
  subnet_id        = "subnet-889b18a9"
  ssh_user         = "ubuntu"
  key_name         = "themyKeyPair"     ##"EC2-keyPair"
  private_key_path = "themyKeyPair.pem" ##"keyPair.pem" ##create a new keypair while uploading
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "nginx" { ##rename the nginx to apache
  name   = "nginx_access"               ##rename this as lamp access of something else
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

resource "aws_instance" "nginx" { ##rename the nginx to apache
  ami                         = "ami-084568db4383264d4"
  subnet_id                   = local.subnet_id #"subnet-889b18a9"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.nginx.id]
  key_name                    = local.key_name

  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.nginx.public_ip
    }
  }
  provisioner "local-exec" {
    command = "ansible-playbook  -i ${aws_instance.nginx.public_ip}, --private-key ${local.private_key_path} -u ${local.ssh_user} nginx.yaml"
  }
}

output "nginx_ip" {
  value = aws_instance.nginx.public_ip
}
