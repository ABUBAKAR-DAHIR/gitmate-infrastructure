# outputs.tf

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.vpc.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private.id
}

output "frontend_security_group_id" {
  description = "ID of the frontend security group"
  value       = aws_security_group.frontend_sg.id
}

output "backend_security_group_id" {
  description = "ID of the backend security group"
  value       = aws_security_group.backend_sg.id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.nat.id
}

output "nat_eip" {
  description = "Elastic IP address of the NAT Gateway"
  value       = aws_eip.nat_eip.public_ip
}

output "frontend_instance_id" {
  description = "ID of the frontend EC2 instance"
  value       = aws_instance.frontend_ec2.id
}

output "frontend_public_ip" {
  description = "Public IP address of the frontend EC2 instance"
  value       = aws_instance.frontend_ec2.public_ip
}

output "frontend_public_dns" {
  description = "Public DNS name of the frontend EC2 instance"
  value       = aws_instance.frontend_ec2.public_dns
}

output "backend_instance_id" {
  description = "ID of the backend EC2 instance"
  value       = aws_instance.backend_ec2.id
}

output "backend_private_ip" {
  description = "Private IP address of the backend EC2 instance"
  value       = aws_instance.backend_ec2.private_ip
}

output "frontend_eip" {
  description = "Frontned EIP"
  value       = aws_eip.frontend_eip
}