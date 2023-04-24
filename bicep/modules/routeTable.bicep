

param routerablename string

param location string = resourceGroup().location

resource symbolicname 'Microsoft.Network/routeTables@2022-07-01' = {
  name: routerablename
  location: location

  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: 'udr-default'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopIpAddress: '10.0.2.4' //TODO get ip of firewall
          nextHopType: 'VirtualAppliance'
        }
        type: 'Microsoft.Network/routeTables/routes'
      }
    ]
  }
}
