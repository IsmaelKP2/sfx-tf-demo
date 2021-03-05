resource "aws_subnet" "tfdemo_subnets" {
  count       = var.subnet_count
  vpc_id      = aws_vpc.vpc_tfdemo.id
  # availability_zone = element(var.subnet_availability_zones, count.index)
  availability_zone = join("",[var.region, (element(var.subnet_availability_zones, count.index))]) 
  cidr_block  = element(var.subnet_cidrs, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name  = element(var.subnet_names, count.index)
  }
}
