variable "aws_region" {
  type        = string
  description = "AWS Region"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
}

variable "vpc_tag_name" {
  type        = string
  description = "VPC Tag name"
}

variable "public_subnet_cidr" {
  type        = string
  description = "Public subnet CIDR block"
}

variable "public_subnet_tag_name" {
  type        = string
  description = "Public subnet Tag name"
}

variable "private_subnet_cidr" {
  type        = string
  description = "Private subnet CIDR block"
}

variable "private_subnet_tag_name" {
  type        = string
  description = "Private subnet Tag name"
}

variable "igw_tag_name" {
  type        = string
  description = "Intenet Gateway Tag name"
}

variable "public_cidr_ipv4" {
  type        = string
  description = "public CIDR block Ipv4"
}

variable "public_cidr_ipv6" {
  type        = string
  description = "public CIDR block Ipv6"
}

variable "frontend_sg_tag_name" {
  type        = string
  description = "Frontend SG Tag Name"
}

variable "backend_sg_tag_name" {
  type        = string
  description = "Backend SG Tag Name"
}

variable "public_rt_tag_name" {
  type        = string
  description = "Public rt Tag Name"
}

variable "private_rt_tag_name" {
  type        = string
  description = "Private rt Tag Name"
}

variable "nat_tag_name" {
  type        = string
  description = "NAT Tag Name"
}

variable "nat_eip_tag_name" {
  type        = string
  description = "NAT-EIP Tag Name"
}

variable "frontend_ami" {
  type        = string
  description = "Frontend EC2 AMI"
}

variable "frontend_instance_type" {
  type        = string
  description = "Frontend EC2 instance type"
}

variable "frontend_tag_name" {
  type        = string
  description = "Frontend EC2 Tag Name"
}

variable "backend_ami" {
  type        = string
  description = "backend EC2 AMI"
}

variable "backend_instance_type" {
  type        = string
  description = "backend EC2 instance type"
}

variable "backend_tag_name" {
  type        = string
  description = "backend EC2 Tag Name"
}

variable "key_name" {
  type        = string
  description = "SSH Key name"
}

# variable "frontend_private_key" {
#     type = string
#     description = "Frontend Private Key"
# }

# variable "backend_private_key" {
#     type = string
#     description = "Backend Private Key"
# }

variable "frontend_eip_tag_name" {
  type        = string
  description = "Frontend EC2 EIP"
}

variable "backend_private_ip" {
  type = string
  description = "Backend private IP address"
}

variable "frontend_lt" {
  type = string
  description = "Frontend Launch template"
}

variable "frontend_asg" {
  type = string
  description = "Frontend Autoscaler Group"
}

variable "backend_lt" {
  type = string
  description = "Backend Launch template"
}

variable "backend_asg" {
  type = string
  description = "Backend Autoscaler Group"
}




