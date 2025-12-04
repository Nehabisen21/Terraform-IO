
########################################
# EC2 INSTANCE IN VPC1 PUBLIC SUBNET
########################################

resource "aws_security_group" "vpc1_public_sg" {
  name        = "vpc1-public-sg"
  vpc_id      = aws_vpc.vpc1.id
  description = "Allow SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" #all traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "vpc1_public_ec2" { #bastion server
  ami                         = var.instance_ami
  instance_type               = var.public_subnet_cidr
  subnet_id                   = aws_subnet.vpc1_public.id
  availability_zone           = var.availability_zone
  key_name                    = aws_key_pair.generated_key.key_name
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.vpc1_public_sg.id
  ]

  tags = {
    Name = "vpc1-public-ec2"
  }

  ###################################################
  # ADDED: Connection + Provisioners (Do NOT remove)
  ###################################################

  # Needed for Terraform to SSH into EC2
  connection {
    type        = "ssh"          #terraform will use ssh to connect
    host        = self.public_ip #use the public IP of the EC2
    user        = "ec2-user"
    private_key = tls_private_key.ssh_key.private_key_pem #use the generated private key
  }

  # Upload PEM file into EC2
  provisioner "file" { #upload the private key to the EC2
    content     = tls_private_key.ssh_key.private_key_pem
    destination = "/home/ec2-user/terraform-key.pem"
  }

  # Fix permissions
  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/ec2-user/terraform-key.pem" #give read-only permission to the owner
    ]
  }
}
#not for production use only for testing and learning purposes
