
########################################
#               VPC 1
########################################

resource "aws_vpc" "vpc1" {
  cidr_block = var.vpc1_cidr
  tags       = { Name = "vpc1" }
}

resource "aws_subnet" "vpc1_public" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone
  tags                    = { Name = "vpc1-public" }
}

resource "aws_subnet" "vpc1_private" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = "10.0.2.0/25"
  availability_zone = var.availability_zone
  tags              = { Name = "vpc1-private" }
}

resource "aws_eip" "vpc1_nat_eip" {

}

resource "aws_nat_gateway" "vpc1_nat" {
  allocation_id = aws_eip.vpc1_nat_eip.id
  subnet_id     = aws_subnet.vpc1_public.id
}


resource "aws_internet_gateway" "vpc1_igw" {
  vpc_id = aws_vpc.vpc1.id
}

resource "aws_route_table" "vpc1_public_rt" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "vpc1-public-rt"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc1_igw.id
  }

  # ADD PEERING ROUTE INSIDE THE TABLE
  route {
    cidr_block                = aws_vpc.vpc2.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc1_to_vpc2.id
  }
}

resource "aws_route_table_association" "vpc1_public_rta" {
  subnet_id      = aws_subnet.vpc1_public.id
  route_table_id = aws_route_table.vpc1_public_rt.id
}

resource "aws_route_table" "vpc1_private_rt" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "vpc1-private-rt"
  }

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.vpc1_nat.id
  }
}

resource "aws_route_table_association" "vpc1_private_rta" {
  subnet_id      = aws_subnet.vpc1_private.id
  route_table_id = aws_route_table.vpc1_private_rt.id
}
