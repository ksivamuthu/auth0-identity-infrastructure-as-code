terraform {
  backend "remote" {
    organization = "Identity-Infra-As-Code-Demo"

    workspaces {
      name = "demo-workspace"
    }
  }
}

locals {
  name_prefix             = "${var.project_name}-${var.env_name}"
  name_prefix_no_spl_char = "${var.project_name}${var.env_name}"
}
