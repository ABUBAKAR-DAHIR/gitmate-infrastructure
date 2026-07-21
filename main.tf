# VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_tag_name
  }
}

# Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.igw_tag_name
  }
}

# Frontend Security Group
resource "aws_security_group" "frontend_sg" {
  name        = "Public SG"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = var.frontend_sg_tag_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "https_ipv4" {
  security_group_id = aws_security_group.frontend_sg.id
  referenced_security_group_id = aws_security_group.frontend_alb_sg.id

  cidr_ipv4         = var.public_cidr_ipv4
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "http_ipv4" {
  security_group_id = aws_security_group.frontend_sg.id
  referenced_security_group_id = aws_security_group.frontend_alb_sg.id

  cidr_ipv4         = var.public_cidr_ipv4
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "ssh_ipv4" {
  security_group_id = aws_security_group.frontend_sg.id
  cidr_ipv4         = var.public_cidr_ipv4
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.frontend_sg.id
  cidr_ipv4         = var.public_cidr_ipv4
  ip_protocol       = "-1" # semantically equivalent to all ports
}


# Backend Security Group
resource "aws_security_group" "backend_sg" {
  name        = "Backend SG"
  description = "Allow TLS inbound traffic only from the frontend and all outbound traffic"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = var.backend_sg_tag_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "backend_ipv4" {
  security_group_id            = aws_security_group.backend_sg.id
  referenced_security_group_id = aws_security_group.frontend_sg.id
  from_port                    = 5000
  ip_protocol                  = "tcp"
  to_port                      = 5000
}

resource "aws_vpc_security_group_ingress_rule" "backend_ssh" {
  security_group_id            = aws_security_group.backend_sg.id
  referenced_security_group_id = aws_security_group.frontend_sg.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_egress_rule" "backend_all_outbound" {
  security_group_id = aws_security_group.backend_sg.id
  cidr_ipv4         = var.public_cidr_ipv4
  ip_protocol       = "-1"
}

# Public Route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.public_cidr_ipv4
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.public_rt_tag_name
  }
}

# Public Subnet A
resource "aws_subnet" "public_a" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public_subnet_a_cidr
  availability_zone = var.public_subnet_a_az

  tags = {
    Name = var.public_subnet_a_tag_name
  }
}

# Public Subnet B
resource "aws_subnet" "public_b" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public_subnet_b_cidr
  availability_zone = var.public_subnet_b_az

  tags = {
    Name = var.public_subnet_b_tag_name
  }
}

# Associate public subnet A with public route table
resource "aws_route_table_association" "public_a_association" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

# Associate public subnet B with public route table
resource "aws_route_table_association" "public_b_association" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}


# Private Subnet A
resource "aws_subnet" "private_a" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.private_subnet_a_cidr
  availability_zone = var.private_subnet_a_az

  tags = {
    Name = var.private_subnet_a_tag_name
  }
}

# private Subnet B
resource "aws_subnet" "private_b" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.private_subnet_b_cidr
  availability_zone = var.private_subnet_b_az

  tags = {
    Name = var.private_subnet_b_tag_name
  }
}

# Elastic IP address for the NAT Gateway we are going to create 
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = var.nat_eip_tag_name
  }
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  subnet_id     = aws_subnet.public_a.id
  allocation_id = aws_eip.nat_eip.id

  tags = {
    Name = var.nat_tag_name
  }

  depends_on = [aws_eip.nat_eip]
}

# Private Route table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.public_cidr_ipv4
    # gateway_id = aws_internet_gateway.igw.id
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = var.private_rt_tag_name
  }
}

# Associate private subnet with public route table
resource "aws_route_table_association" "private_a_association" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_rt.id
}

# Associate private subnet with public route table
resource "aws_route_table_association" "private_b_association" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_rt.id
}

# # Elastic IP address for the Frontend EC2 server we are going to create
# resource "aws_eip" "frontend_eip" {
#   domain = "vpc"

#   tags = {
#     Name = var.frontend_eip_tag_name
#   }
# }

# # Frontend EC2 Server
# resource "aws_instance" "frontend_ec2" {
#   ami                    = var.frontend_ami
#   instance_type          = var.frontend_instance_type
#   subnet_id              = aws_subnet.public.id
#   vpc_security_group_ids = [aws_security_group.frontend_sg.id]
#   key_name               = var.key_name

#   tags = {
#     Name = var.frontend_tag_name
#   }

#   user_data = templatefile("${path.module}/scripts/frontend.sh", {
#     git_private_key = file("keys/frontend_keys.txt")
# 	backend_ssh_key = replace(file("keys/gitmate.pem"), "\r\n", "\n")
#   })
# }

# # Frontend server launch template
# resource "aws_eip_association" "frontend_eip_association" {
#   allocation_id = aws_eip.frontend_eip.id
#   instance_id   = aws_instance.frontend_ec2.id
# }

# # Backend EC2 Server
# resource "aws_instance" "backend_ec2" {
#   ami                    = var.backend_ami
#   instance_type          = var.backend_instance_type
#   subnet_id              = aws_subnet.private.id
#   vpc_security_group_ids = [aws_security_group.backend_sg.id]
#   key_name               = var.key_name
#   private_ip = var.backend_private_ip

#   tags = {
#     Name = var.backend_tag_name
#   }

#   user_data = templatefile("${path.module}/scripts/backend.sh", {
#     git_private_key = file("keys/backend_keys.txt")
# 	backend_env = file("keys/backend_env.txt")
#   })
# }

resource "aws_launch_template" "frontend_lt" {
  name_prefix = "frontend-"
  image_id = var.frontend_ami
  instance_type = var.frontend_instance_type
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]
  key_name = var.key_name

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = var.frontend_lt
    }
  }

  user_data = templatefile("${path.module}/scripts/frontend.sh", {
    git_private_key = file("keys/frontend_keys.txt")
	backend_ssh_key = replace(file("keys/gitmate.pem"), "\r\n", "\n")
  })
}

# Frontend AutoScaler
resource "aws_autoscaling_group" "frontend_asg" {
    name = var.frontend_asg
    min_size = 1
    max_size = 3
    desired_capacity = 1

    target_group_arns = [
        aws_lb_target_group.frontend_tg.arn
    ]

    vpc_zone_identifier = [
        aws_subnet.public_a.id,
        aws_subnet.public_b.id
    ]

    launch_template {
        id = aws_launch_template.frontend_lt.id
        version = "$Latest"
    }
}


# Backend launch template
resource "aws_launch_template" "backend_lt" {
  name_prefix = "backend-"
  image_id = var.backend_ami
  instance_type = var.backend_instance_type
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  key_name = var.key_name

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = var.backend_lt
    }
  }

  user_data = templatefile("${path.module}/scripts/backend.sh", {
    git_private_key = file("keys/backend_keys.txt")
	backend_env = file("keys/backend_env.txt")
  })
}

# Backend AutoScaler
resource "aws_autoscaling_group" "backend_asg" {
    name = var.backend_asg
    min_size = 1
    max_size = 3
    desired_capacity = 1

    vpc_zone_identifier = [
        aws_subnet.private_a.id,
        aws_subnet.private_b.id
    ]

    launch_template {
        id = aws_launch_template.backend_lt.id
        version = "$Latest"
    }
}


# Frontend ALB Security Group
resource "aws_security_group" "frontend_alb_sg" {
  name        = "Frontend Public SG"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = var.frontend_alb_sg_tag_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_https_ipv4" {
  security_group_id = aws_security_group.frontend_alb_sg.id
  cidr_ipv4         = var.public_cidr_ipv4
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "alb_http_ipv4" {
  security_group_id = aws_security_group.frontend_alb_sg.id
  cidr_ipv4         = var.public_cidr_ipv4
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "alb_allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.frontend_alb_sg.id
  cidr_ipv4         = var.public_cidr_ipv4
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Target group
resource "aws_lb_target_group" "frontend_tg" {
  name     = var.frontend_tg
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
  }

  tags = {
    Name = var.frontend_tg
  }
}

# Frontend ALB
resource "aws_lb" "frontend_alb" {
  name               = var.frontend_alb
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.frontend_alb_sg.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  enable_deletion_protection = true


  tags = {
    Name = var.frontend_alb
  }
}

# Frontend ALB listener
resource "aws_lb_listener" "frontend_alb_listener" {
  load_balancer_arn = aws_lb.frontend_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}


//

# Backend ALB Security Group
resource "aws_security_group" "backend_alb_sg" {
  name        = var.backend_alb_sg_tag_name
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = var.backend_alb_sg_tag_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_backend_ipv4" {
  security_group_id            = aws_security_group.backend_alb_sg.id
  referenced_security_group_id = aws_security_group.frontend_alb_sg.id
  from_port                    = 5000
  ip_protocol                  = "tcp"
  to_port                      = 5000
}

resource "aws_vpc_security_group_ingress_rule" "alb_backend_ssh" {
  security_group_id            = aws_security_group.backend_alb_sg.id
  referenced_security_group_id = aws_security_group.frontend_alb_sg.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_egress_rule" "alb_backend_all_outbound" {
  security_group_id = aws_security_group.backend_alb_sg.id
  cidr_ipv4         = var.public_cidr_ipv4
  ip_protocol       = "-1"
}

# Target group
resource "aws_lb_target_group" "backend_tg" {
  name     = var.backend_tg
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
  }

  tags = {
    Name = var.backend_tg
  }
}


# Backend ALB
resource "aws_lb" "backend_alb" {
  name               = var.backend_alb
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.backend_alb_sg.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  enable_deletion_protection = true


  tags = {
    Name = var.backend_alb
  }
}

# Backend ALB listener
resource "aws_lb_listener" "frontend_alb_listener" {
  load_balancer_arn = aws_lb.frontend_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}
