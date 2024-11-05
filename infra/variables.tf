variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "ssh_key_name" {
  type    = string
  default = "ilynch-key"
}

variable "ssh_public_key" {
  type    = string
  default = "ssh-keys/id_rsa.pub"
}

variable "ssh_private_key" {
  type    = string
  default = "ssh-keys/id_rsa"
}

variable "ami_id" {
  type    = string
  default = "ami-04a81a99f5ec58529"
}

variable "instance_type" {
  type    = string
  default = "t3.large"
}
