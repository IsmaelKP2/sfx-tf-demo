resource "aws_route" "route_tfdemo" {
  route_table_id            = aws_vpc.vpc_tfdemo.main_route_table_id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.igw_tfdemo.id
}