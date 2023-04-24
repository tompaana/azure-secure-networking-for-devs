
param bastionName string

param location string = resourceGroup().location

param virtualNetworkName string

param subnetName string = 'AzureBastionSubnet'

param bastionPublicIpName string = 'pip-AzureBastion-dev'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' existing ={
  name: virtualNetworkName
}

resource publicIP 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: bastionPublicIpName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2022-07-01' = {
  name: bastionName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    disableCopyPaste: false
    enableFileCopy: false
    enableIpConnect: false
    enableShareableLink: false
    ipConfigurations: [
      {
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIP.id
          }
          subnet: {
            id: '${virtualNetwork.id}/subnets/${subnetName}'
          }
        }
      }
    ]
    scaleUnits: 2
  }
}
