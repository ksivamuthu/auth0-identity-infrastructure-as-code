data "azurerm_client_config" "main" {}

data "azurerm_role_definition" "main" {
  name = "Contributor"
}

data "azurerm_subscription" "main" {}

resource "azuread_application" "main" {
  name = "${local.name_prefix}-ad-app"
  identifier_uris = [
    format("http://%s", "${local.name_prefix}-ad-app")
  ]
  available_to_other_tenants = false
}

resource "azuread_service_principal" "main" {
  application_id = azuread_application.main.application_id
}

resource "random_password" "main" {
  length  = 32
  special = false
}

resource "azuread_service_principal_password" "main" {
  service_principal_id = azuread_service_principal.main.id
  value                = random_password.main.result
  end_date_relative    = "2140h"
}

resource "azurerm_role_assignment" "main" {
  scope              = azurerm_resource_group.rg.id
  role_definition_id = format("%s%s", data.azurerm_subscription.main.id, data.azurerm_role_definition.main.id)
  principal_id       = azuread_service_principal.main.id
}

resource "github_actions_secret" "azure_secret" {
  repository  = "auth0-identity-infrastructure-as-code"
  secret_name = "AZURE_CREDENTIALS_${upper(var.env_name)}"
  plaintext_value = jsonencode({
    "clientId"       = azuread_application.main.application_id,
    "clientSecret"   = azuread_service_principal_password.main.value,
    "subscriptionId" = data.azurerm_client_config.main.subscription_id,
    "tenantId"       = data.azurerm_client_config.main.tenant_id,
    "activeDirectoryEndpointUrl" : "https://login.microsoftonline.com",
    "resourceManagerEndpointUrl" : "https://management.azure.com/",
    "activeDirectoryGraphResourceId" : "https://graph.windows.net/",
    "sqlManagementEndpointUrl" : "https://management.core.windows.net:8443/",
    "galleryEndpointUrl" : "https://gallery.azure.com/",
    "managementEndpointUrl" : "https://management.core.windows.net/"
  })
}
