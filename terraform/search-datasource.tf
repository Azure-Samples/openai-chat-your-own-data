locals {
  data_source_name = "azureblob-datasource"
  data_source_definition = {
    name = local.data_source_name
    type = "azureblob"
    container = {
      name = azurerm_storage_container.fileuploads.name
    }
    credentials = {
      connectionString = azurerm_storage_account.main.primary_connection_string
    }
  }
}

data "http" "create_datasource" {
  url    = "${local.search_endpoint}/datasources/?api-version=${local.search_api_version}"
  method = "POST"

  request_headers = {
    Authorization = "Bearer ${local.auth_token}"
    Content-Type  = "application/json"
  }

  request_body = jsonencode(local.data_source_definition)

  depends_on = [
    azurerm_search_service.main,
    azurerm_role_assignment.search_service_contributor,
    data.http.create_index
  ]
}
output "datasource_status_code" {
  value = data.http.create_datasource.status_code
}
output "datasource_response" {
  value = data.http.create_datasource.response_body
}
