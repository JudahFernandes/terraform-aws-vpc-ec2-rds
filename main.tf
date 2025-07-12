
provider "aws" {
region = "us-west-2" # Specify your desired AWS region
}
data "aws_ssm_parameter" "al2_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}
resource "aws_vpc" "main_vpc" {
cidr_block = "10.0.0.0/16"
tags = {
Name = "main_vpc"
}
}


resource "aws_subnet" "public_subnet" {
vpc_id = aws_vpc.main_vpc.id
cidr_block = "10.0.1.0/24"
availability_zone = "us-west-2a"
tags = {
Name = "public_subnet"
}
}
resource "aws_subnet" "private_subnet" {
vpc_id = aws_vpc.main_vpc.id
cidr_block = "10.0.2.0/24"
availability_zone = "us-west-2a"
tags = {
Name = "private_subnet"
}
}


resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "private_subnet_2"
  }
}



resource "aws_internet_gateway" "igw" {
vpc_id = aws_vpc.main_vpc.id
tags = {
Name = "main_igw"
}
}
resource "aws_route_table" "public_route_table" {
vpc_id = aws_vpc.main_vpc.id
route {
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.igw.id
}
tags = {
Name = "public_route_table"
}
}
resource "aws_route_table_association" "public_subnet_association" {
subnet_id = aws_subnet.public_subnet.id
route_table_id = aws_route_table.public_route_table.id
}



resource "aws_security_group" "ec2_sg" {
vpc_id = aws_vpc.main_vpc.id
ingress {
from_port = 22
to_port = 22
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere; adjust as needed
}
egress {
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]
}
tags = {
Name = "ec2_sg"
}
}
resource "aws_security_group" "rds_sg" {
vpc_id = aws_vpc.main_vpc.id
ingress {
from_port = 3306 # Default MySQL port; adjust for your DB engine
to_port = 3306
protocol = "tcp"
cidr_blocks = ["10.0.0.0/16"] # Allow access from within the VPC
}
egress {
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]
}
tags = {
Name = "rds_sg"
}
}


resource "aws_instance" "web_server" {
  ami           = data.aws_ssm_parameter.al2_ami.value
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "web_server"
  }
}





resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds_subnet_group"
  subnet_ids = [
    aws_subnet.private_subnet.id,
    aws_subnet.private_subnet_2.id
  ]

  tags = {
    Name = "rds_subnet_group"
  }
}


resource "aws_db_instance" "rds_instance" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"               
  db_name                = "mydatabase"
  username               = "admin"
  password               = "Password123!"
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true

  tags = {
    Name = "rds_instance"
  }
}
