

param virtualNetworkName string

param remotevirtualNetworkName string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' existing ={
  name: virtualNetworkName
}

resource remotevirtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' existing ={
  name: remotevirtualNetworkName
}

resource vnetpeering1 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: 'peer-${virtualNetworkName}-${remotevirtualNetworkName}1'
  parent: virtualNetwork
  properties: {
    remoteVirtualNetwork: {
      id: remotevirtualNetwork.id
    }
    allowVirtualNetworkAccess:true
    allowForwardedTraffic:true
  }
}

resource vnetpeering2 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: 'peer-${remotevirtualNetworkName}-${virtualNetworkName}2'
  parent: remotevirtualNetwork
  properties: {
    remoteVirtualNetwork: {
      id: virtualNetwork.id
    }
    allowVirtualNetworkAccess:true
    allowForwardedTraffic:true
  }
}
