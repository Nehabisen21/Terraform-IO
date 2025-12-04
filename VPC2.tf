
########################################
#               VPC 2
########################################

resource "aws_vpc" "vpc2" {
  cidr_block = var.vpc2_cidr
  tags       = { Name = "vpc2" }
}

resource "aws_subnet" "vpc2_private" {
  vpc_id            = aws_vpc.vpc2.id
  cidr_block        = var.private2_subnet_cidr
  availability_zone = var.availability_zone
  tags              = { Name = "vpc2-private" }
}

resource "aws_internet_gateway" "vpc2_igw" {
  vpc_id = aws_vpc.vpc2.id
}


#############################
# PRIVATE ROUTE TABLE
#############################

resource "aws_route_table" "vpc2_private_rt" {
  vpc_id = aws_vpc.vpc2.id

  # >>> REQUIRED ROUTE FOR VPC PEERING <<<
  route {
    cidr_block                = aws_vpc.vpc1.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc1_to_vpc2.id
  }
}

resource "aws_route_table_association" "vpc2_private_rta" {
  subnet_id      = aws_subnet.vpc2_private.id
  route_table_id = aws_route_table.vpc2_private_rt.id
}
