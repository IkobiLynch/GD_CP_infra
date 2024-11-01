variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "instances" {
  type = list(string)
}

variable "lb_security_group_ids" {
  description = "ID of the load balancer security group"
}

variable "availability_zones" {
  type = list(string)
}

variable "instance_ids" {
  type = map(string)
  description = "Map of instance IDs to attach to the target group"
}
