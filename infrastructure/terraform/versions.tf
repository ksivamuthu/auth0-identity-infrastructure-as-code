terraform {
  required_providers {
    auth0 = {
      source  = "alexkappa/auth0"
      version = "~> 0.16.1"
    }
    azurerm = {
      version = "~> 2.40.0"
    }
  }
  required_version = ">= 0.13"
}
