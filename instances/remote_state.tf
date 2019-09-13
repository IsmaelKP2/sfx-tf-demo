data "terraform_remote_state" "security_groups" {
  backend = "local"

  config = {
    path = "${path.module}/../terraform.tfstate"
  }
}