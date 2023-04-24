
// az webapp create `
//     --name "${AppServiceNamePrefix}-eu" `
//     --resource-group $ResourceGroupName `
//     --plan "${AppServicePlanNamePrefix}-eu" `
//     --runtime PYTHON:3.9

param appServicePlanName string

@minLength(2)
@maxLength(22)
param appServiceName string
param linuxFxVersion string = 'PYTHON|3.9'
param location string = resourceGroup().location


@minLength(2)
@maxLength(64)
param vnetName string

@minLength(1)
@maxLength(80)
param subnetName string

@minLength(1)
@maxLength(80)
param privateendpointsubnetName string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: vnetName
}

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
}

resource appService 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceName
  location: location
  kind: 'app,linux'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: linuxFxVersion
    }
    publicNetworkAccess: 'Disabled'
    virtualNetworkSubnetId: '${virtualNetwork.id}/subnets/${subnetName}'
  }
  identity: {
    type: 'SystemAssigned'
  }
}


module privateEndpoint './privateEndpoint.bicep' = {
  name: '${appServiceName}PrivateEndpointDeployment'

  params: {
    serviceName: appServiceName
    serviceId: appService.id
    location: location
    vnetName: vnetName
    subnetName: privateendpointsubnetName
    groupId: 'sites'
    privateDnsZoneName: 'privatelink.azurewebsites.net'
  }
}
