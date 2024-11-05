resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "ilynch-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "ilynch-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "ilynch-public-rt"
  }
}

resource "aws_subnet" "subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "ilynch-subnet-${count.index + 1}"
  }
}

resource "aws_route_table_association" "public_rt_association" {
  count = length(aws_subnet.subnet)

  subnet_id      = aws_subnet.subnet[count.index].id # Associate each subnet
  route_table_id = aws_route_table.public_rt.id      # Associate with public route table
}

resource "aws_security_group" "app_sg" {
  vpc_id = aws_vpc.main.id
  name   = "ilynch-app-sg"

  # Allow SSH traffic (port 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP traffic (port 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP traffic (port 8080)
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outgoing traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ilynch-app-sg"
  }
}

resource "aws_security_group" "lb_sg" {
  vpc_id = aws_vpc.main.id
  name   = "ilynch-lb-sg"

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

  tags = {
    Name = "ilynch-lb-sg"
  }
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_ids" {
  value = aws_subnet.subnet[*].id
}

output "app_security_group_id" {
  value = aws_security_group.app_sg.id
}

output "lb_security_group_id" {
  value = aws_security_group.lb_sg.id
}
