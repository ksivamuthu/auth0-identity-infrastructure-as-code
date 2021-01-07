
resource "azurerm_resource_group" "rg" {
  name     = "${local.name_prefix}-resource-group"
  location = "East US"
}

resource "azurerm_app_service_plan" "appserviceplan" {
  name                = "${azurerm_resource_group.rg.name}-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  reserved            = true

  # Define Linux as Host OS
  kind = "Linux"

  # Choose size
  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "app" {
  name                = "${local.name_prefix}-app"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.appserviceplan.id
  https_only          = true
  site_config {
    linux_fx_version = "NODE|12.0"
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "WEBSITE_LOCAL_CACHE_OPTION"          = "Never"
  }
}

resource "azurerm_app_service" "api" {
  name                = "${local.name_prefix}-api"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.appserviceplan.id
  https_only          = true
  site_config {
    linux_fx_version = "NODE|12.0"
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false",
    "AUTH_CONFIG_DOMAIN"                  = var.auth0_domain,
    "AUTH_CONFIG_CLIENTID"                = auth0_client.app-frontend.client_id,
    "AUTH_CONFIG_AUDIENCE"                = "https://${local.name_prefix}-api.azurewebsites.net",
    "APP_ORIGIN"                          = "https://${local.name_prefix}-app.azurewebsites.net",
  }
}


resource "github_actions_secret" "api_origin" {
  repository      = "auth0-identity-infrastructure-as-code"
  secret_name     = "API_ORIGIN_${upper(var.env_name)}"
  plaintext_value = "https://${azurerm_app_service.api.default_site_hostname}"
}


resource "github_actions_secret" "app_origin" {
  repository      = "auth0-identity-infrastructure-as-code"
  secret_name     = "APP_ORIGIN_${upper(var.env_name)}"
  plaintext_value = "https://${azurerm_app_service.app.default_site_hostname}"
}
