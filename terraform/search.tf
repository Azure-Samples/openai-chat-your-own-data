
resource "azurerm_search_service" "main" {
  name                         = "search-${var.application_name}-${var.environment_name}"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  sku                          = "standard"
  local_authentication_enabled = true
  authentication_failure_mode  = "http401WithBearerChallenge"
}

locals {
  search_endpoint    = "https://${azurerm_search_service.main.name}.search.windows.net"
  search_api_version = "2024-07-01"
}

resource "azurerm_role_assignment" "search_service_contributor" {
  scope                = azurerm_search_service.main.id
  role_definition_name = "Search Service Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}
