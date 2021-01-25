output "vpc_id" {
    value = aws_vpc.vpc_tfdemo.id
}

output "subnet_ids" {
    value = aws_subnet.tfdemo_subnets.*.id
}
