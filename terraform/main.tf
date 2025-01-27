
data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.application_name}-${var.environment_name}-${random_string.suffix.result}"
  location = var.location
}
