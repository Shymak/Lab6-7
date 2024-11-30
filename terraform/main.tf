terraform {
  required_version = ">=0.13.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
backend "s3" {
    bucket = "lab6-7"
    key = "terraform.tfstate"
    region = "eu-north-1"
    dynamodb_table = "lab6-7" 

  }
}

# Configure the AWS provider
provider "aws" {
  region     = "eu-north-1"
}

resource "aws_security_group" "web_app" {
  name        = "web_app"
  description = "security group"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags= {
    Name = "web_app"
  }
}

resource "aws_instance" "web_instance" {
  ami           = "ami-089146c5626baa6bf"
  instance_type = "t3.micro"
  security_groups = ["web_app"]
 user_data = <<-EOF
  #!/bin/bash
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
  sudo groupadd docker
  sudo usermod -aG docker $USER
  newgrp docker
  docker pull  4ykcha/aws:latest
  docker run -it 4ykcha/aws:latest

  EOF

  tags = {
    Name = "webapp_instance"
  }
}


output "instance_public_ip" {
  value     = aws_instance.web_instance.public_ip
  sensitive = true
}
