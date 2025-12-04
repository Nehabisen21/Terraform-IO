
########################################
# EC2 INSTANCE IN VPC2 PRIVATE SUBNET
########################################

resource "aws_security_group" "vpc2_private_sg" {
  name   = "vpc2-private-sg"
  vpc_id = aws_vpc.vpc2.id

  # Allow SSH from VPC1
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc1.cidr_block]
  }

  # >>> ADDED: Allow ICMP (ping) from VPC1 <<<
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp" #for ping requests
    cidr_blocks = [aws_vpc.vpc1.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "vpc2_private_ec2" {
  ami                         = var.instance_ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.vpc2_private.id
  availability_zone           = var.availability_zone
  key_name                    = aws_key_pair.generated_key.key_name
  associate_public_ip_address = false
  user_data                   = <<EOF
#!/bin/bash
yum update -y
yum install -y mariadb
EOF

  vpc_security_group_ids = [
    aws_security_group.vpc2_private_sg.id
  ]

  tags = {
    Name = "vpc2-private-ec2"
  }
}
