# VPC (equivalent to DigitalOcean VPC)
resource "aws_vpc" "bas_network" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name = "bas-network"
  }
}

# Internet Gateway for public access
resource "aws_internet_gateway" "bas_igw" {
  vpc_id = aws_vpc.bas_network.id

  tags = {
    Name = "bas-igw"
  }
}

# Public subnet for instances with internet access
resource "aws_subnet" "bas_public_subnet" {
  vpc_id                                    = aws_vpc.bas_network.id
  cidr_block                                = var.vpc_cidr
  availability_zone                         = "${var.aws_region}a"
  map_public_ip_on_launch                   = true
  enable_dns64                              = false
  assign_ipv6_address_on_creation           = false
  enable_resource_name_dns_a_record_on_launch = false
  ipv6_native                               = false
  enable_resource_name_dns_aaaa_record_on_launch = false

  tags = {
    Name = "bas-public-subnet"
  }
}

# Route table for public subnet
resource "aws_route_table" "bas_public_rt" {
  vpc_id = aws_vpc.bas_network.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.bas_igw.id
  }

  tags = {
    Name = "bas-public-rt"
  }
}

# Associate route table with public subnet
resource "aws_route_table_association" "bas_public_rta" {
  subnet_id      = aws_subnet.bas_public_subnet.id
  route_table_id = aws_route_table.bas_public_rt.id
}

# Security group for BAS server
resource "aws_security_group" "bas_server_sg" {
  name                   = "bas-server-sg"
  description            = "Security group for BAS server"
  vpc_id                 = aws_vpc.bas_network.id
  revoke_rules_on_delete = false

  # SSH access
  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "SSH access"
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }

  # Outbound internet access
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "All outbound traffic"
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }

  tags = {
    Name = "bas-server-sg"
  }
}

# Security group for BAS database
resource "aws_security_group" "bas_database_sg" {
  name                   = "bas-database-sg"
  description            = "Security group for BAS database"
  vpc_id                 = aws_vpc.bas_network.id
  revoke_rules_on_delete = false

  depends_on = [aws_security_group.bas_server_sg]

  # SSH access
  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "SSH access from server"
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    self             = false
  }

  # PostgreSQL access from server security group
  ingress {
    from_port        = 8001
    to_port          = 8001
    protocol         = "tcp"
    security_groups  = [aws_security_group.bas_server_sg.id]
    description      = "PostgreSQL access from server"
    cidr_blocks      = []
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    self             = false
  }

  # # Internal VPC communication
  # ingress {
  #   from_port        = 0
  #   to_port          = 65535
  #   protocol         = "tcp"
  #   cidr_blocks      = [var.vpc_cidr]
  #   description      = "Internal VPC communication"
  #   ipv6_cidr_blocks = []
  #   prefix_list_ids  = []
  #   security_groups  = []
  #   self             = false
  # }

  # Outbound internet access
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "All outbound traffic"
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }

  tags = {
    Name = "bas-database-sg"
  }
}
