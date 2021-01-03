variable "auth0_domain" {}

resource "auth0_client" "app-frontend" {
  name                       = "${local.name_prefix}-app"
  description                = "${local.name_prefix}-app - Terraform generated"
  app_type                   = "spa"
  oidc_conformant            = true
  sso                        = true
  callbacks                  = ["https://${azurerm_app_service.app.default_site_hostname}"]
  allowed_logout_urls        = ["https://${azurerm_app_service.app.default_site_hostname}"]
  allowed_origins            = ["https://${azurerm_app_service.app.default_site_hostname}"]
  web_origins                = ["https://${azurerm_app_service.app.default_site_hostname}"]
  token_endpoint_auth_method = "none"

  jwt_configuration {
    alg = "RS256"
  }
}

resource "auth0_resource_server" "app-backend" {
  name                   = "${local.name_prefix}-api"
  identifier             = "https://${azurerm_app_service.api.default_site_hostname}"
  signing_alg            = "RS256"
  enforce_policies       = true
  allow_offline_access   = true
  token_lifetime         = 86400
  token_lifetime_for_web = 7200

  skip_consent_for_verifiable_first_party_clients = true
}

resource "github_actions_secret" "auth0_clientid" {
  repository      = "auth0-identity-infrastructure-as-code"
  secret_name     = "AUTH0_CLIENTID_${upper(var.env_name)}"
  plaintext_value = auth0_client.app-frontend.client_id
}

resource "github_actions_secret" "auth0_domain" {
  repository      = "auth0-identity-infrastructure-as-code"
  secret_name     = "AUTH0_DOMAIN_${upper(var.env_name)}"
  plaintext_value = var.auth0_domain
}

resource "github_actions_secret" "auth0_audience" {
  repository      = "auth0-identity-infrastructure-as-code"
  secret_name     = "AUTH0_AUDIENCE_${upper(var.env_name)}"
  plaintext_value = "https://${azurerm_app_service.api.default_site_hostname}"
}
