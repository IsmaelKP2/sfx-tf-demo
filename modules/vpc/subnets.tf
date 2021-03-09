# Fetch AZs in the current region
data "aws_availability_zones" "available" {
}

# Create private subnets, each in a different AZ
resource "aws_subnet" "private_subnets" {
  count             = var.subnet_count
  cidr_block        = cidrsubnet(aws_vpc.vpc_tfdemo.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.vpc_tfdemo.id

  tags = {
    Name  =        join("_", [var.vpc_name, "private", count.index])
  }
}


# Create public subnets, each in a different AZ
resource "aws_subnet" "public_subnets" {
  count                   = var.subnet_count
  cidr_block              = cidrsubnet(aws_vpc.vpc_tfdemo.cidr_block, 8, var.subnet_count + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.vpc_tfdemo.id
  map_public_ip_on_launch = true

  tags = {
    Name  =        join("_", [var.vpc_name, "public", count.index])
  }
}