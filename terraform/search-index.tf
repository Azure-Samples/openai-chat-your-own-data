locals {
  search_index_name = "${var.environment_name}index"
  index_definition = {
    name = local.search_index_name
    fields = [
      { name = "id", type = "Edm.String", key = true, retrievable = true, filterable = true, sortable = true },
      { name = "content", type = "Edm.String", searchable = true, retrievable = true },
      { name = "filepath", type = "Edm.String", retrievable = true },
      { name = "title", type = "Edm.String", searchable = true, retrievable = true },
      { name = "url", type = "Edm.String", retrievable = true },
      { name = "chunk_id", type = "Edm.String", retrievable = true },
      { name = "last_updated", type = "Edm.String", retrievable = true }
    ]
  }
}

data "http" "create_index" {
  url    = "${local.search_endpoint}/indexes/?api-version=${local.search_api_version}"
  method = "POST"

  request_headers = {
    Authorization = "Bearer ${local.auth_token}"
    Content-Type  = "application/json"
  }

  request_body = jsonencode(local.index_definition)

  depends_on = [
    azurerm_search_service.main,
    azurerm_role_assignment.search_service_contributor
  ]
}
output "index_status_code" {
  value = data.http.create_index.status_code
}
output "index_response" {
  value = data.http.create_index.response_body
}
