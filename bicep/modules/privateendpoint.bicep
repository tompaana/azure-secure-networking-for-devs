/*
  This template creates a private endpoint for the given resource (service).
  The given private DNS zone, with a virtual network link, must exist prior to using this template.
*/

@minLength(1)
@maxLength(80)
@description('The name of the service to create private link to.')
param serviceName string

@description('The resource ID of private link service.')
param serviceId string

param location string

@minLength(2)
@maxLength(64)
param vnetName string

@minLength(1)
@maxLength(80)
param subnetName string

// See https://learn.microsoft.com/azure/private-link/private-endpoint-overview#private-link-resource for a subset of subresources
@description('The ID of group obtained from the remote resource that this private endpoint should connect to e.g., "azuremonitor" or "sites".')
param groupId string

param privateDnsZoneName string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-01-01' existing  = {
  name: vnetName
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: privateDnsZoneName
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: 'pep-${serviceName}-${groupId}'
  location: location

  properties: {
    subnet: {
      // Ideally we'd want to get the existing subnet resource and use "subnet.id"
      // However, for some reason, that approach generates an invalid ARM template
      id: '${virtualNetwork.id}/subnets/${subnetName}'
    }

    privateLinkServiceConnections: [
      {
        name: 'plsc-${serviceName}-${groupId}'

        properties: {
          privateLinkServiceId: serviceId
          groupIds: [groupId]
        }
      }
    ]
  }
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  name: 'default'
  parent: privateEndpoint

  properties: {
    privateDnsZoneConfigs: [
      {
        name: replace(privateDnsZoneName, '.', '-')

        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}
