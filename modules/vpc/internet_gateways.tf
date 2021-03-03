resource "aws_internet_gateway" "igw_tfdemo" {
  vpc_id = aws_vpc.vpc_tfdemo.id

  tags = {
    Name = "icw_${var.vpc_name}"
  }
}