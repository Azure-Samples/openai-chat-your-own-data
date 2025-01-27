locals {
  indexer_name = "azureblob-indexer"
  indexer_definition = {
    name            = local.indexer_name
    targetIndexName = local.search_index_name
    dataSourceName  = local.data_source_name
    schedule        = { interval = "PT5M" }
  }
}

data "http" "create_indexer" {
  url    = "${local.search_endpoint}/indexers/?api-version=${local.search_api_version}"
  method = "POST"

  request_headers = {
    Authorization = "Bearer ${local.auth_token}"
    Content-Type  = "application/json"
  }

  request_body = jsonencode(local.indexer_definition)

  depends_on = [
    azurerm_search_service.main,
    azurerm_role_assignment.search_service_contributor,
    data.http.create_datasource
  ]

}

output "indexer_status_code" {
  value = data.http.create_indexer.status_code
}
output "indexer_response" {
  value = data.http.create_indexer.response_body
}
