provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "wordpress_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my wordpress vpc"
  }
}

resource "aws_internet_gateway" "wordpress_igw" {
  vpc_id = aws_vpc.wordpress_vpc.id
  tags = {
    Name = "my wordpress gateway"
  }
}

resource "aws_route_table" "wordpress_rt" {
  vpc_id = aws_vpc.wordpress_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wordpress_igw.id
  }

  tags = {
    Name = "wordpress-rt"
  }
}

resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.wordpress_rt.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.wordpress_rt.id
}

resource "aws_route_table_association" "public_subnet_3_association" {
  subnet_id      = aws_subnet.public_subnet_3.id
  route_table_id = aws_route_table.wordpress_rt.id
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.wordpress_vpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.wordpress_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-2"
  }
}

resource "aws_subnet" "public_subnet_3" {
  vpc_id                  = aws_vpc.wordpress_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-3"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id     = aws_vpc.wordpress_vpc.id
  cidr_block = "10.0.3.0/24"
  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id     = aws_vpc.wordpress_vpc.id
  cidr_block = "10.0.4.0/24"
  tags = {
    Name = "private-subnet-2"
  }
}

resource "aws_subnet" "private_subnet_3" {
  vpc_id     = aws_vpc.wordpress_vpc.id
  cidr_block = "10.0.5.0/24"
  tags = {
    Name = "private-subnet-3"
  }
}

variable "ingress_ports" {
  description = "List of ports to be opened in the security group"
  default = {
    http  = 80
    https = 443
    ssh   = 22
  }
}

resource "aws_security_group" "wordpress_sg" {
  name        = "wordpress-sg"
  description = "Security Group for WordPress"
  vpc_id      = aws_vpc.wordpress_vpc.id

  ingress {
    from_port   = var.ingress_ports.http
    to_port     = var.ingress_ports.http
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.ingress_ports.https
    to_port     = var.ingress_ports.https
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.ingress_ports.ssh
    to_port     = var.ingress_ports.ssh
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wordpress-sg"
  }
}

resource "aws_instance" "wordpress_ec2" {
  ami           = "ami-0bb4c991fa89d4b9b"
  instance_type = "t2.micro"
  key_name      = "ssh-key"
  subnet_id     = aws_subnet.public_subnet_1.id
  
  vpc_security_group_ids = [
    aws_security_group.wordpress_sg.id
  ]

user_data = <<-EOT
                #!/bin/bash
                yum update -y
                yum install httpd php php-mysql -y
                sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
                cd /var/www/html
                wget https://wordpress.org/wordpress-5.1.1.tar.gz
                tar -xzf wordpress-5.1.1.tar.gz
                cp -r wordpress/* /var/www/html/
                rm -rf wordpress
                rm -rf wordpress-5.1.1.tar.gz
                chmod -R 755 *
                chown -R apache:apache *
                chkconfig httpd on
                service httpd start
                EOT

  tags = {
    Name = "wordpress-ec2"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Security Group for RDS (MySQL)"
  vpc_id      = aws_vpc.wordpress_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.wordpress_sg.id]
  }

  tags = {
    Name = "rds-sg"
  }
}

resource "aws_db_subnet_group" "mysql_db_subnet_group" {
  name       = "mysql-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id, aws_subnet.private_subnet_3.id]

  tags = {
    Name = "MySQL DB Subnet Group"
  }
}

resource "aws_db_instance" "mysql" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  identifier           = "mysql"
  username             = "admin"
  password             = "adminadmin"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true

  db_subnet_group_name = aws_db_subnet_group.mysql_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  tags = {
    Name = "mysql"
  }
}
