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

resource "aws_eip" "this" {
  vpc      = true
  instance = aws_instance.this.id
}

# create private key file
resource "local_file" "write_key" {
    content     = tls_private_key.this.private_key_pem
    filename    = "key/${var.key_name}"
}

# instance
resource "aws_instance" "this" {
  key_name      = module.key_pair.this_key_pair_key_name
  ami           = "ami-01fee56b22f308154"
  instance_type = "t2.micro"
  tags = {
    Name = "ssh-test-01"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("${path.module}\\/${local_file.write_key.filename}")
    host        = self.public_ip
    agent       = false
    timeout     = "2m"
  }

    provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install docker -y",
      "sudo service docker start",
      "sudo docker run -d -p 80:8080 ${var.docker_image}",
      "sudo usermod -a -G docker ec2-user"
    ]
  }
}

output "ip" {
  value = aws_eip.this.public_ip
}

output "private_key" {
  value = tls_private_key.this.private_key_pem
}

# resource "null_resource" "login" {

#   provisioner "local-exec" {
#     # copy the public-ip file back to CWD, which will be tested
#     command = "ssh -o StrictHostKeyChecking no -i ${local_file.write_key.filename} ${var.ssh_user}@${aws_eip.this.public_ip}"
#   }
# }