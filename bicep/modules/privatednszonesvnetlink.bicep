
param privateDnsZoneNames array = [
  // 'privatelink.agentsvc.azure-automation.net'
  'privatelink.azurewebsites.net'
  // 'privatelink.batch.azure.com'
  'privatelink.blob.${environment().suffixes.storage}' // environment().suffixes.storage returns 'core.windows.net'
  // 'privatelink.file.${environment().suffixes.storage}'
  // 'privatelink.monitor.azure.com'
  // 'privatelink.ods.opinsights.azure.com'
  // 'privatelink.oms.opinsights.azure.com'
  // 'privatelink.queue.${environment().suffixes.storage}'
  // 'privatelink.table.${environment().suffixes.storage}'
  // 'privatelink.vaultcore.azure.net'
]

param vnetName string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: vnetName
}

resource privateDnsZones 'Microsoft.Network/privateDnsZones@2020-06-01' existing = [for privateDnsZoneName in privateDnsZoneNames : {
  name: privateDnsZoneName
}]


resource virtualNetworkLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (privateDnsZoneName, i) in privateDnsZoneNames : {
  name: replace('vnetlink-${privateDnsZoneName}-${vnetName}', '.', '-')
  location: 'global'
  parent: privateDnsZones[i]

  properties: {
    registrationEnabled: false

    virtualNetwork: {
      id: virtualNetwork.id
    }
  }

  dependsOn: [
    privateDnsZones
  ]
}]
