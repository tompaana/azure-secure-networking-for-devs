// See https://learn.microsoft.com/azure/private-link/private-endpoint-dns
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

resource privateDnsZones 'Microsoft.Network/privateDnsZones@2020-06-01' = [for privateDnsZoneName in privateDnsZoneNames : {
  name: privateDnsZoneName
  location: 'global'
}]



