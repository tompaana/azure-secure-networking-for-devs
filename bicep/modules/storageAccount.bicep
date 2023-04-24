// az storage account create `
//     --name "st${TeamName}${Environment}us" `
//     --resource-group $ResourceGroupName `
//     --location $SecondaryLocation `
//     --kind StorageV2 `
//     --sku Standard_LRS

@minLength(1)
@maxLength(22)
param storageAccountName string

param storageAccountKind string = 'StorageV2'

param storageAccountSKU string = 'Standard_LRS'

param location string = resourceGroup().location

@minLength(2)
@maxLength(64)
param vnetName string

@minLength(1)
@maxLength(80)
param subnetName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSKU
  }
  kind: storageAccountKind 
  properties: {
    publicNetworkAccess: 'Disabled'
  }
  
}

module privateEndpoints './privateEndpoint.bicep' = {
  name: '${storageAccountName}blobPrivateEndpointDeployment'

  params: {
    serviceName: storageAccountName
    serviceId: storageAccount.id
    location: location
    vnetName: vnetName
    subnetName: subnetName
    groupId: 'blob'
    privateDnsZoneName: 'privatelink.blob.${environment().suffixes.storage}'
  }
}


