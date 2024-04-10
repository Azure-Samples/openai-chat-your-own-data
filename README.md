# Project Name

This template provisions essential infrastructure for you to use Azure OpenAI with your own data. Visit the [OpenAI Use Your Data](https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/azure-developer-cli) tutorial for details on how to combine this architecture setup with application code.

## Features

This project framework provides the following features:

* Provisions an Azure OpenAI service
* Provisions an Azure AI Search service
* Configures essential connections between the OpenAI and AI Search service, such as creating indexes and managing permissions

## Getting Started

### Prerequisites

- [Azure Developer CLI](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd)

### Quickstart

To provision the template, open a terminal in an empty folder on your local computer and run the following commands:

```azurecli
azd init --template openai-chat-your-own-data

azd auth login

azd up
```

The provisioning process may take several minutes to complete.

## Resources

- [Tutorial - Use Your Data with OpenAI](https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/
