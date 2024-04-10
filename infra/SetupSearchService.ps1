param(
    [string] [Parameter(Mandatory=$true)] $searchServiceName,
    [string] [Parameter(Mandatory=$true)] [AllowEmptyString()] $dataSourceContainerName,
    [string] [Parameter(Mandatory=$true)] [AllowEmptyString()] $dataSourceConnectionString,
    [string] [Parameter(Mandatory=$true)] $dataSourceType,
    [string] [Parameter(Mandatory=$true)] $searchIndexName
)

$ErrorActionPreference = 'Stop'

$apiversion = '2020-06-30'
$token = Get-AzAccessToken -ResourceUrl https://search.azure.com | select -expand Token
#$headers = @{ 'Authorization' = "Bearer $token"; 'Content-Type' = 'application/json'; }
$headers = @{ 'Authorization' = "Bearer $token"; 'Content-Type' = 'application/json'; }
$uri = "https://$searchServiceName.search.windows.net"
$indexDefinition = $null
$dataSourceDefinition = $null
$indexerDefinition = $null
$DeploymentScriptOutputs = @{}

# Create data source, index, and indexer definitions
switch ($dataSourceType)
{
    "azureblob" {
        $indexDefinition = @{
            'name' = $searchIndexName;
            'fields' = @(
                @{ 'name' = 'id'; 'type' = 'Edm.String'; 'key' = $true; 'retrievable' = $true; 'filterable' = $true; 'sortable' = $true; 'facetable' = $false; 'searchable' = $false },
                @{ 'name' = 'content'; 'type' = 'Edm.String'; 'searchable' = $true; 'retrievable' = $true; 'sortable' = $false; 'filterable' = $false; 'facetable' = $false; 'key'= $false },
                @{ 'name' = 'filepath'; 'type' = 'Edm.String'; 'searchable' = $false; 'retrievable' = $true; 'sortable' = $false; 'filterable' = $false; 'facetable' = $false; 'key'= $false },
                @{ 'name' = 'title'; 'type' = 'Edm.String'; 'searchable' = $true; 'retrievable' = $true; 'sortable' = $false; 'filterable' = $false; 'facetable' = $false; 'key'= $false },
                @{ 'name' = 'url'; 'type' = 'Edm.String'; 'searchable' = $false; 'retrievable' = $true; 'sortable' = $false; 'filterable' = $false; 'facetable' = $false; 'key'= $false },
                @{ 'name' = 'chunk_id'; 'type' = 'Edm.String'; 'searchable' = $false; 'retrievable' = $true; 'sortable' = $false; 'filterable' = $false; 'facetable' = $false; 'key'= $false },
                @{ 'name' = 'last_updated'; 'type' = 'Edm.String'; 'searchable' = $false; 'retrievable' = $true; 'sortable' = $false; 'filterable' = $false; 'facetable' = $false; 'key'= $false }
            );
        }
        $dataSourceDefinition = @{
            'name' = 'azureblob-datasource';
            'type' = 'azureblob';
            'container' = @{
                'name' = $dataSourceContainerName;
            };
            'credentials' = @{
                'connectionString' = $dataSourceConnectionString
            };
        }
        $indexerDefinition = @{
            'name' = 'azureblob-indexer';
            'targetIndexName' = $searchIndexName;
            'dataSourceName' = 'azureblob-datasource';
            'schedule' = @{ 'interval' = 'PT5M' };
        }
        $DeploymentScriptOutputs['indexName'] = $searchIndexName
    }
    default {
        throw "Unsupported data source type $dataSourceType"
    }
}

# try {
    # https://learn.microsoft.com/rest/api/searchservice/create-index
    Write-Host "https://$searchServiceName.search.windows.net/datasources/$($indexDefinition['name'])?api-version=$apiversion"
    Invoke-WebRequest `
        -Method 'PUT' `
        -Uri "https://$searchServiceName.search.windows.net/indexes/$($indexDefinition['name'])?api-version=$apiversion" `
        -Headers  $headers `
        -Body (ConvertTo-Json $indexDefinition)

    if ($dataSourceContainerName.Length -gt 0 -and $dataSourceConnectionString.Length -gt 0)
    {
        # https://learn.microsoft.com/rest/api/searchservice/create-data-source
        Invoke-WebRequest `
            -Method 'PUT' `
            -Uri "$uri/datasources/$($dataSourceDefinition['name'])?api-version=$apiversion" `
            -Headers $headers `
            -Body (ConvertTo-Json $dataSourceDefinition)

        # https://learn.microsoft.com/rest/api/searchservice/create-indexer
        Invoke-WebRequest `
            -Method 'PUT' `
            -Uri "$uri/indexers/$($indexerDefinition['name'])?api-version=$apiversion" `
            -Headers $headers `
            -Body (ConvertTo-Json $indexerDefinition)
    }

    [System.Environment]::SetEnvironmentVariable('AZURE_AI_SEARCH_INDEX', $indexDefinition['name'])
# } catch {
#     Write-Error $_.ErrorDetails.Message
#     throw
# }