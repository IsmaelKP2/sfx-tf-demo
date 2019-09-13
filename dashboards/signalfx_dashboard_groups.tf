# Configure the SignalFx provider
provider "signalfx" {
  auth_token = "${var.signalfx_auth_token}"
  api_url = "${var.api_url}"
}

# Create a new dashboard group
resource "signalfx_dashboard_group" "terraform_created_dashboard_group" {
    name = "Terraform Created Dashboard Group"
    description = "Dashboard Group created using Terraform"
}
