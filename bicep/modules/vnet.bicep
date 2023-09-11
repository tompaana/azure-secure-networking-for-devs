
param virtualNetworkName string

param location string = resourceGroup().location

param addressPrefixes string

param subnets array

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefixes
      ]
    }
    subnets: subnets
  }
}

output vnetid string = virtualNetwork.id
output name string = virtualNetwork.name
