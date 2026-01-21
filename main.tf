provider "aws" {
  region = var.aws_region
}

# 1. Dynamically fetch the latest Ubuntu 24.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 2. Network Infrastructure
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "main-vpc" }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  # FIX: AZs need a letter (e.g., us-east-1a). 
  # This dynamically picks the first available zone in your region.
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = { Name = "public-subnet" }
}

# Add an Internet Gateway (Required for a "Public" subnet to actually work)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# 3. Security & Access
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("C:/Users/ManojKumar/.ssh/id_rsa.pub")
}

resource "aws_security_group" "allow_ssh" {
  name   = "allow_ssh_traffic"
  vpc_id = aws_vpc.main.id

  # Inbound rule for SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allows access from any IP
  }

  # Inbound rule for Flask (Optional but helpful)
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound rule for Express (Optional but helpful)
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rules (Required to download Node.js/Python)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allows all outgoing traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 4. EC2 Instance
resource "aws_instance" "my_ubuntu" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.deployer.key_name

  # FIX: This explicitly links the instance to your new VPC Subnet
  subnet_id = aws_subnet.public.id

  # Link the security group
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  user_data = file("scripts/setup.sh")

  tags = {
    Name = var.instance_name
  }
}
