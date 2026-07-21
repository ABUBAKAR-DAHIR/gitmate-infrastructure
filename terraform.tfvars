aws_region              = "ap-south-1"
vpc_cidr                = "10.0.0.0/16"
vpc_tag_name            = "gitmate-vpc"
public_subnet_a_cidr      = "10.0.1.0/24"
public_subnet_a_tag_name  = "public-subnet-a"
public_subnet_b_cidr      = "10.0.2.0/24"
public_subnet_b_tag_name  = "public-subnet-b"
public_subnet_a_az = "ap-south-1a"
public_subnet_b_az = "ap-south-1b"

private_subnet_a_cidr     = "10.0.3.0/24"
private_subnet_a_tag_name = "private-subnet-a"
private_subnet_b_cidr     = "10.0.4.0/24"
private_subnet_b_tag_name = "private-subnet-b"
private_subnet_a_az = "ap-south-1a"
private_subnet_b_az = "ap-south-1b"

igw_tag_name            = "igw"
public_cidr_ipv4        = "0.0.0.0/0"
public_cidr_ipv6        = "::/0"
frontend_sg_tag_name    = "frontend-sg"
backend_sg_tag_name     = "backend-sg"
public_rt_tag_name      = "public-rt"
nat_tag_name            = "nat-gw"
private_rt_tag_name     = "private-rt"
nat_eip_tag_name        = "nat-eip"

frontend_ami           = "ami-01a00762f46d584a1"
frontend_instance_type = "t2.medium"
frontend_tag_name      = "frontend-server"

backend_ami           = "ami-01a00762f46d584a1"
backend_instance_type = "t2.medium"
backend_tag_name      = "backend-server"

key_name = "gitmate"

# frontend_private_key = file("frontend_keys")
# backend_private_key  = file("backend_keys")
frontend_eip_tag_name = "frontend-eip"

backend_private_ip = "10.0.2.10"
frontend_lt = "frontend-lt"
frontend_asg = "frontend-asg"
frontend_alb_sg_tag_name = "frontend-alb-sg"
backend_lt = "backend-lt"
backend_asg = "backend-asg"

frontend_tg = "frontend-tg"
frontend_alb = "frontend-alb"

backend_alb_sg_tag_name = "backend-alb-sg"
backend_tg = "backend-tg"
backend_alb = "backend-alb"



