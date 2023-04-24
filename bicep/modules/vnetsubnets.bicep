

param subnetname string

param virtualNetworkName string

param addressPrefix string

param delegations array

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' existing ={
  name: virtualNetworkName
}

resource vnetsubnets 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = {
  name: subnetname
  parent: virtualNetwork
  properties: {
    addressPrefix: addressPrefix
    delegations: delegations
  }
}
