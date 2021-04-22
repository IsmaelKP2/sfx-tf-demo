# Create a new dashboard group
resource "signalfx_dashboard_group" "tfg0" {
  name        = "Terraform Created Dashboard Group ${var.environment}"
  description = "Dashboard Group created using Terraform"
}
