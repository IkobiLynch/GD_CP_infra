resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "../ssh-keys/id_rsa"

  provisioner "local-exec" {
    command = "chmod 400 ../ssh-keys/id_rsa"
  }
}

resource "local_file" "public_key" {
  content  = tls_private_key.ssh_key.public_key_openssh
  filename = "../ssh-keys/id_rsa.pub"

  provisioner "local-exec" {
    command = "chmod 644 ../ssh-keys/id_rsa.pub"
  }
}

resource "aws_key_pair" "main" {
  key_name   = var.ssh_key_name
  public_key = tls_private_key.ssh_key.public_key_openssh
}

output "key_name" {
  value = aws_key_pair.main.key_name
}
