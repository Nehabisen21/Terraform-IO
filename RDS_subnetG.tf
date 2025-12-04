
resource "aws_db_subnet_group" "vpc2_rds_subnet_group" {
  name = "vpc2-rds-subnet-group"
  subnet_ids = [
    aws_subnet.vpc2_private.id,
    aws_subnet.vpc2_private_2.id
  ]

  tags = {
    Name = "vpc2-rds-subnet-group"
  }
}
#rds must be in private subnets only and must be in at least two subnets for high availability
