# Stand alone module for RDS

provider "aws" {
  region = "us-east-1"
}

# Security Group for RDS
resource "aws_security_group" "rds_security_group" {
  name        = "ilynch-rds-security-group"
  description = "Allow inbound traffic to RDS from application instances"
  vpc_id      = var.vpc_id

  # Allow inbound PostgresSQL traffic (port 5432)
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "ilynch_subnet_group" {
  name       = "iko-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "My DB Subnet Group"
  }
}

# Create the RDS instance for PostgresSQL
resource "aws_db_instance" "postgres" {
  identifier             = "ilynch-db"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "13"
  instance_class         = "db.t3.micro"
  db_name                = "springAppDB"
  username               = "myusername" #Should use secrets manager, but can't bada rn
  password               = "mypassword"
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds_security_group.id]
  db_subnet_group_name   = aws_db_subnet_group.ilynch_subnet_group

  # Optional: Backup & Monitoring
  # backup_retention_period = 8
  multi_az = false

}

output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}