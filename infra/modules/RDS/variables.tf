variable "vpc_id" {
  description = "VPC id of the main vpc"
}

variable "subnet_ids" {
  type = list(string)
}