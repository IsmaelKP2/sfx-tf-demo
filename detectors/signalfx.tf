# Configure the SignalFx provider
provider "signalfx" {
  auth_token = "${var.signalfx_auth_token}"
  api_url = "${var.api_url}"
}