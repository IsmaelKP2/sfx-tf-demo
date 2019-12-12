# Provides the ID of the various AWS Seurity Groups so they can be referenced 
# when creating the VMs using the terraform_remote_state data source 
# https://blog.gruntwork.io/how-to-manage-terraform-state-28f5697e68fa


output "allow_all_id" {
  value       = "${aws_security_group.allow_all.id}"
  description = "ID of the Allow All Security Group"
}

output "allow_egress_id" {
  value       = "${aws_security_group.allow_egress.id}"
  description = "ID of the Allow Egress Security Group"
}

output "allow_tls_id" {
  value       = "${aws_security_group.allow_tls.id}"
  description = "ID of the Allow TLS Security Group"
}

output "allow_http_id" {
  value       = "${aws_security_group.allow_http.id}"
  description = "ID of the Allow HTTP Security Group"
}

output "allow_ssh_id" {
  value       = "${aws_security_group.allow_ssh.id}"
  description = "ID of the Allow SSH Security Group"
}

output "allow_mysql_id" {
  value       = "${aws_security_group.allow_mysql.id}"
  description = "ID of the Allow mysql Security Group"
}

output "allow_sfx_mon_id" {
  value       = "${aws_security_group.allow_sfx_mon.id}"
  description = "ID of the Allow SFX Security Group"
}