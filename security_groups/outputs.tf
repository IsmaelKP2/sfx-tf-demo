output "allow_all_id" {
  value       = aws_security_group.allow_all.id
  description = "ID of the Allow All Security Group"
}

output "allow_egress_id" {
  value       = aws_security_group.allow_egress.id
  description = "ID of the Allow Egress Security Group"
}

output "allow_web_id" {
  value       = aws_security_group.allow_web.id
  description = "ID of the Allow Web Security Group"
}

output "allow_ssh_id" {
  value       = aws_security_group.allow_ssh.id
  description = "ID of the Allow SSH Security Group"
}

output "allow_mysql_id" {
  value       = aws_security_group.allow_mysql.id
  description = "ID of the Allow mysql Security Group"
}

output "allow_collectors_id" {
  value       = aws_security_group.allow_collectors.id
  description = "ID of the Allow Collectors Security Group"
}
