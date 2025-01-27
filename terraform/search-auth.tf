
data "external" "azure_auth_token" {
  program = ["sh", "-c", <<EOT
    az account get-access-token --resource https://search.azure.com --query "{access_token: accessToken}" --output json
  EOT
  ]
}

locals {
  auth_token = data.external.azure_auth_token.result["access_token"]
}
