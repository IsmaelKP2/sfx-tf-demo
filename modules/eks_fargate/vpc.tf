# Fetch AZs in the current region
data "aws_availability_zones" "available" {
}

 resource "aws_vpc" "eks_fargate_vpc" {
  cidr_block           = var.eks_fargate_vpc_cidr
  enable_dns_hostnames = true
  
  tags = {
    Name = "${var.environment}-eks-fargate-vpc"
    "kubernetes.io/cluster/${var.eks_fargate_cluster_name}" = "shared"
  }
}

resource "aws_subnet" "eks_fargate_public" {
  vpc_id                   = aws_vpc.eks_fargate_vpc.id
  cidr_block               = element(var.eks_fargate_public_cidr, count.index)
  availability_zone        = data.aws_availability_zones.available.names[count.index]
  count                    = length(var.eks_fargate_public_cidr)
  map_public_ip_on_launch  = true
  # depends_on               = [ aws_vpc.eks_fargate_vpc ]
  
  tags = {
    "kubernetes.io/cluster/${var.eks_fargate_cluster_name}" = "shared"
    "kubernetes.io/role/elb" = 1
    # Name   = "${var.environment}-node-group-subnet-${count.index + 1}"
    Name   = "${var.environment}-eks-fargate-public-subnet-${count.index + 1}"
    state  = "public"
  }
}

resource "aws_subnet" "eks_fargate_private" {
  vpc_id                   = aws_vpc.eks_fargate_vpc.id
  cidr_block               = element(var.eks_fargate_private_cidr, count.index)
  availability_zone        = data.aws_availability_zones.available.names[count.index]
  count                    = length(var.eks_fargate_private_cidr)
  # depends_on               = [ aws_vpc.eks_fargate_vpc ]
  
  tags = {
    "kubernetes.io/cluster/${var.eks_fargate_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = 1
    "Name"   = "${var.environment}-eks-fargate-private-subnet-${count.index + 1}"
    "state"  = "private"
  }
}

resource "aws_internet_gateway" "eks_fargate_igw" {
  vpc_id = aws_vpc.eks_fargate_vpc.id
  # depends_on = [ aws_vpc.eks_fargate_vpc ]

  tags = {
    Name = "${var.environment}-eks-fargate-igw"
  }
}

resource "aws_eip" "eks_fargate_nat" {
  vpc              = true
  count            = length(var.eks_fargate_private_cidr)
  public_ipv4_pool = "amazon"
}

resource "aws_nat_gateway" "eks_fargate_nat_gw" {
  count         = length(var.eks_fargate_private_cidr)
  allocation_id = element(aws_eip.eks_fargate_nat.*.id, count.index)
  subnet_id     = element(aws_subnet.eks_fargate_public.*.id, count.index)
  # depends_on    = [aws_internet_gateway.eks_fargate_igw]

  tags = {
    Name = "${var.environment}-eks-fargate-nat-gateway-${count.index + 1}"
  }
}

resource "aws_route_table" "eks_fargate_internet_route" {
  vpc_id = aws_vpc.eks_fargate_vpc.id
  route {
    cidr_block = var.cidr_block_internet_gw
    gateway_id = aws_internet_gateway.eks_fargate_igw.id
  }
  # depends_on = [ aws_vpc.eks_fargate_vpc ]
  tags  = {
      Name = "${var.environment}-eks-fargate-public-route-table"
      state = "public"
  }
}

  resource "aws_route_table" "eks_fargate_nat_route" {
  vpc_id = aws_vpc.eks_fargate_vpc.id
  count  = length(var.eks_fargate_private_cidr)
  route {
    cidr_block = var.cidr_block_nat_gw
    gateway_id = element(aws_nat_gateway.eks_fargate_nat_gw.*.id, count.index)
  }
  # depends_on = [ aws_vpc.eks_fargate_vpc ]
  tags  = {
      Name = "${var.environment}-eks-fargate-nat-route-table-${count.index + 1}"
      state = "public"
  } 
}

resource "aws_route_table_association" "public" {
  count          = length(var.eks_fargate_public_cidr)
  subnet_id      = element(aws_subnet.eks_fargate_public.*.id, count.index)
  route_table_id = aws_route_table.eks_fargate_internet_route.id
  
  # depends_on = [ aws_route_table.eks_fargate_internet_route ,
  #                aws_subnet.eks_fargate_public
  # ]
}


resource "aws_route_table_association" "private" {
  count          = length(var.eks_fargate_private_cidr)
  subnet_id      = element(aws_subnet.eks_fargate_private.*.id, count.index)
  route_table_id = element(aws_route_table.eks_fargate_nat_route.*.id, count.index)
  # depends_on = [ aws_route_table.eks_fargate_nat_route ,
  #                aws_subnet.eks_fargate_private
  # ]
}

