## Getting Started

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install?product_intent=terraform)

### Quickstart

To provision the template, open a terminal in an empty folder on your local computer and run the following commands:

```
az login

export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"

terraform init

terraform apply
```

The provisioning process may take several minutes to complete.

### Bicep vs. Terraform: Lines of Code Analysis

1. Bicep's root module interface is consolidated into a single file `main.bicep` file Terraform's (by convention is distributed across three files: `main.tf`, `variables.tf` and `versions.tf`)
2. Bicep uses a PowerShell script embedded within a `Microsoft.Resource\deploymentScripts` resource in order to make the REST API calls to the Azure Search Service to setup the Index, Data Source and Indexer. This results in the deployment being split between client-side (Bicep) and server-side (PowerShell script running as a Deployment Script). In contrast, Terraform uses two utility providers `external` and `http` in order to obtain a bearer token and make the REST API calls. This means the entire deployment is completed entirely on the local machine.


| Bicep File                          |     | Terraform File        |     |
| ----------------------------------- | --- |---------------------- | --- |
| main.bicep                          | 147 | main.tf               | 12  |
| N/A                                 |     | variables.tf          |  9  |
| N/A                                 |     | versions.tf           | 12  |
| main.parameters.json                | 15  | terraform.tfvars      |  3  |
| core/security/role.bicep            | 21  | N/A                   |     |
| core/ai/cognitiveservices.bicep     | 55  | cognitive.tf          | 23  |
| core/storage/storage-account.bicep  | 65  | storage.tf            | 20  |
| core/ai/search/search-service.bicep | 71  | search.tf             | 20  |
| setup-search-service.bicep          | 58  | N/A                   |     |
| SetupSearchService.ps1              | 90  | N/A                   |     |
| N/A                                 |     | search-auth.tf        | 11  |
| N/A                                 |     | search-datasource.tf  | 37  |
| N/A                                 |     | search-index.tf       | 38  |
| N/A                                 |     | search-indexer.tf     | 35  |
| **BICEP TOTALS**                    | 522 | **TERRAFORM TOTALS**  | 220 |

All in good fun. For "science". よろしくね :o)