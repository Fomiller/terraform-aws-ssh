terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
}
resource "tls_private_key" "this" {
  algorithm = "RSA"
}

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"
  key_name = var.key_name
  public_key = tls_private_key.this.public_key_openssh
}

resource "aws_instance" "this" {
  key_name = module.key_pair.this_key_pair_key_name
  ami           = "ami-01fee56b22f308154"
  instance_type = "t2.micro"

  tags = {
    Name = "ssh-test-01"
  }
}

resource "aws_eip" "this" {
  vpc      = true
  instance = aws_instance.this.id
}

output "ip" {
  value = aws_eip.this.public_ip
}