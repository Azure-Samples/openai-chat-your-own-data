targetScope = 'subscription'

// The main bicep module to provision Azure resources.
// For a more complete walkthrough to understand how this file works with azd,
// see https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/make-azd-compatible?pivots=azd-create

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string
param azureOpenAIChatGptModelVersion string ='0613'
@description('Primary location for all resources')
param principalId string
param chatGptDeploymentCapacity int = 10
param searchIndexName string = '${environmentName}index'
// Optional parameters to override the default azd resource naming conventions.
// Add the following to main.parameters.json to provide values:
// "resourceGroupName": {
//      "value": "myGroupName"
// }
param resourceGroupName string = ''

var abbrs = loadJsonContent('./abbreviations.json')

// tags that should be applied to all resources.
var tags = {
  // Tag all resources with the environment name.
  'azd-env-name': environmentName
}

// Generate a unique token to be used in naming resources.
// Remove linter suppression after using.
#disable-next-line no-unused-vars
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

// Name of the service defined in azure.yaml
// A tag named azd-service-name with this value should be applied to the service host resource, such as:
//   Microsoft.Web/sites for appservice, function
// Example usage:
//   tags: union(tags, { 'azd-service-name': apiServiceName })
#disable-next-line no-unused-vars
var apiServiceName = 'python-api'

// Organize resources in a resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

module azureOpenAi 'core/ai/cognitiveservices.bicep' = {
  name: 'openai'
  scope: rg
  params: {
    name: '${abbrs.cognitiveServicesAccounts}${resourceToken}'
    location: location
    tags: tags
    sku: {
      name: 'S0'
    }
    deployments: [{
      name: 'gpt-35-turbo-16k'
      model: {
        format: 'OpenAI'
        name: 'gpt-35-turbo-16k'
        version: azureOpenAIChatGptModelVersion
      }
      sku: {
        name: 'Standard'
        capacity: chatGptDeploymentCapacity
      }
    }]
  }
}

// Add resources to be provisioned below.
// A full example that leverages azd bicep modules can be seen in the todo-python-mongo template:
// https://github.com/Azure-Samples/todo-python-mongo/tree/main/infra

module storageAccount './core/storage/storage-account.bicep' = {
  scope: rg
  name: '${abbrs.storageStorageAccounts}${environmentName}'
  params: {
    location: location
    tags: tags
    name:  '${abbrs.storageStorageAccounts}${environmentName}'
    kind: 'StorageV2'
    containers: ['fileuploads']
  }
}

// Assign the Storage Blob Data Contributor role to the user
module storageRoleUser 'core/security/role.bicep' = {
  scope: rg
  name: 'storage-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
    principalType: 'User'
  }
}

module searchService 'core/search/search-services.bicep' = {
  scope: rg
  name: '${abbrs.searchSearchServices}${environmentName}'
  params: {
    location: location
    name: '${abbrs.searchSearchServices}${environmentName}'
  }
}

var dataSourceConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.outputs.connectionString};EndpointSuffix=core.windows.net'

module setupSearchService 'setup-search-service.bicep' = {
  scope: rg
  name: 'setup-search-service'
  params: {
    dataSourceContainerName: 'fileuploads'
    dataSourceConnectionString: dataSourceConnectionString
    dataSourceType: 'azureblob'
    location: location
    searchServiceName: searchService.name
    searchIndexName: searchIndexName
  }
}

// Add outputs from the deployment here, if needed.
//
// This allows the outputs to be referenced by other bicep deployments in the deployment pipeline,
// or by the local machine as a way to reference created resources in Azure for local development.
// Secrets should not be added here.
//
// Outputs are automatically saved in the local azd environment .env file.
// To see these outputs, run `azd env get-values`,  or `azd env get-values --output json` for json output.
output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId

output AZURE_OPENAI_ENDPOINT string = azureOpenAi.outputs.endpoint
output AZURE_OPENAI_API_KEY string = azureOpenAi.outputs.key
output AZURE_OPENAI_DEPLOYMENT_NAME string = azureOpenAi.outputs.deploymentName
output AZURE_AI_SEARCH_ENDPOINT string = searchService.outputs.endpoint
output AZURE_AI_SEARCH_API_KEY string = searchService.outputs.key
output AZURE_AI_SEARCH_INDEX string = searchIndexName

