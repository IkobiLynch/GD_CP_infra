resource "aws_instance" "application" {
  count                  = 2
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = element(var.subnet_ids, count.index)
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [var.security_group_id]

  root_block_device {
    volume_size           = 15
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = file("${path.root}/../Scripts/install_basic_dependencies.sh")

  tags = {
    Name = "ilynch-application-instance-${count.index + 1}"
  }
}

resource "aws_instance" "jenkins" {
  count                  = 3
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = element(var.subnet_ids, count.index)
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [var.security_group_id]

  root_block_device {
    volume_size           = 15
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = file("${path.root}/../Scripts/install_basic_dependencies.sh")

  lifecycle {
    ignore_changes = [user_data]
  }
  tags = {
    Name = "ilynch-jenkins-instance-${count.index + 1}"
  }
}

output "application_instance_ips" {
  value = aws_instance.application[*].private_ip
}

output "jenkins_instance_ips" {
  value = aws_instance.jenkins[*].private_ip
}

output "app_instance_ids" {
  value = aws_instance.application[*].id
}
