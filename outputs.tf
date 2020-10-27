output "ip" {
  value = aws_eip.this.public_ip
}

output "private_key" {
  value = tls_private_key.this.private_key_pem
}
