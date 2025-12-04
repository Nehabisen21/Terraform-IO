
###############################################
# VPC PEERING BETWEEN VPC1 AND VPC2
###############################################

resource "aws_vpc_peering_connection" "vpc1_to_vpc2" {
  vpc_id      = aws_vpc.vpc1.id
  peer_vpc_id = aws_vpc.vpc2.id
  auto_accept = true

  tags = {
    Name = "vpc1-vpc2-peering"
  }
}

###############################################
# ROUTE: VPC1 → VPC2
###############################################

resource "aws_route" "vpc1_to_vpc2_route" {
  route_table_id            = aws_route_table.vpc1_private_rt.id
  destination_cidr_block    = aws_vpc.vpc2.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc1_to_vpc2.id
}

###############################################
# ROUTE: VPC2 → VPC1  (USING MAIN ROUTE TABLE)
###############################################

resource "aws_route" "vpc2_to_vpc1_route" {
  route_table_id            = aws_vpc.vpc2.main_route_table_id
  destination_cidr_block    = aws_vpc.vpc1.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc1_to_vpc2.id
}
