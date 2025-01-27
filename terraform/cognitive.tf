resource "azurerm_cognitive_account" "main" {
  name                = "cog-${var.application_name}-${var.environment_name}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  kind                = "OpenAI"
  sku_name            = "S0"
}

resource "azurerm_cognitive_deployment" "main" {
  name                 = "gpt-35-turbo-16k"
  cognitive_account_id = azurerm_cognitive_account.main.id

  model {
    format  = "OpenAI"
    name    = "gpt-35-turbo-16k"
    version = "0613"
  }

  sku {
    name     = "Standard"
    capacity = 20
  }
}
