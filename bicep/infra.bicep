/*
  Deploys infrastructure resources.
*/

param vnetlocations array = ['swedencentral', 'westeurope','eastus']


param vnetlocationsacronym array = ['sw', 'eu','us']
param addressPrefixes array = ['10.0.0.0/22','10.0.4.0/22','10.0.8.0/22']


@minLength(2)
@maxLength(8)
param teamname string = 'mjteamgf'


@allowed(['dev', 'test', 'prod'])
param environment string = 'dev'


param subnets array =  [[{
  name: 'snet-shared-${teamname}-${environment}-${vnetlocations[0]}'
  properties: {
    addressPrefix: '10.0.0.0/26'
  }
},{
  name: 'AzureBastionSubnet'
  properties: {
    addressPrefix: '10.0.1.0/26'
  }
},{
  name: 'AzureFirewallSubnet'
  properties: {
    addressPrefix: '10.0.2.0/25'
  }
}],[
  {
    name: 'snet-shared-${teamname}-${environment}-${vnetlocations[1]}'
    properties: {
      addressPrefix: '10.0.4.0/25'
    } }
  {
    name: 'snet-apps-${teamname}-${environment}-${vnetlocations[1]}'
    properties: {
      addressPrefix: '10.0.4.128/25'
      delegations: [
        {
          name: 'Microsoft.Web/serverFarms'
          properties: {
            serviceName: 'Microsoft.Web/serverFarms'
          }
          type: 'Microsoft.Network/virtualNetworks/subnets/delegations'
        }
      ]
    } }
   ],[{
  name: 'snet-shared-${teamname}-${environment}-${vnetlocations[2]}'
  properties: {
  addressPrefix: '10.0.8.0/25'
  }},{
       name: 'snet-apps-${teamname}-${environment}-${vnetlocations[2]}'
       properties: {
         addressPrefix: '10.0.8.128/25'
         delegations: [
           {
             name: 'Microsoft.Web/serverFarms'
             properties: {
               serviceName: 'Microsoft.Web/serverFarms'
             }
             type: 'Microsoft.Network/virtualNetworks/subnets/delegations'
           }
         ]
       }
     }]
]


module virtualNetworks 'modules/vnet.bicep' = [for vnetindex in range(0, length(vnetlocations)): {
  name: 'VirtualNetwork${vnetlocations[vnetindex]}Deployment'

  params: {
    virtualNetworkName: 'vnet-${teamname}-${environment}-${vnetlocations[vnetindex]}'
    location: vnetlocations[vnetindex]
    addressPrefixes: addressPrefixes[vnetindex]
    subnets: subnets[vnetindex]
  }
}]

module reoutetables 'modules/routeTable.bicep' = [for vnetindex in range(0, length(vnetlocations)): {
  name: 'routeTable${vnetlocations[vnetindex]}Deployment'

  params: {
    routerablename: 'rt-mjteamgf-${vnetlocations[vnetindex]}-${environment}'
    location: vnetlocations[vnetindex]
  }
}]

module virtualNetworksPeering 'modules/vnetpeering.bicep' = [for vnetindex in range(1, 2): {
  name: 'VirtualNetworkPeering${vnetlocations[vnetindex]}Deployment'

  params: {
    remotevirtualNetworkName: 'vnet-${teamname}-${environment}-${vnetlocations[vnetindex]}'
    virtualNetworkName: 'vnet-${teamname}-${environment}-${vnetlocations[0]}'
  }
  dependsOn:[virtualNetworks]
}]

module privatednszones 'modules/privatednszones.bicep' = {
  name: 'privatednszonesdeployment'
}

module privatednszoneslinking 'modules/privatednszonesvnetlink.bicep' = [for vnetindex in range(0, length(vnetlocations)): {
  name: 'privatednszonesvnetlink${vnetlocations[vnetindex]}deployment'
  params: {
    vnetName: 'vnet-${teamname}-${environment}-${vnetlocations[vnetindex]}'
  }
  dependsOn:[virtualNetworks,privatednszones]
}]

module sharedstorageaccounts 'modules/storageAccount.bicep' = {
  name: 'stshard${teamname}${environment}${vnetlocationsacronym[0]}deployment'

  params: {
    storageAccountName: 'stshared${teamname}${environment}'
    location: vnetlocations[0]
    subnetName: 'snet-shared-${teamname}-${environment}-${vnetlocations[0]}'
    vnetName: 'vnet-${teamname}-${environment}-${vnetlocations[0]}'
  }
  dependsOn:[privatednszones]
}

module storageaccounts 'modules/storageAccount.bicep' = [for locationindex in range(1, 2): {
  name: 'st${teamname}${environment}${vnetlocationsacronym[locationindex]}deployment'

  params: {
    storageAccountName: 'st${teamname}${environment}${vnetlocationsacronym[locationindex]}'
    location: vnetlocations[locationindex]
    subnetName: 'snet-shared-${teamname}-${environment}-${vnetlocations[locationindex]}'
    vnetName: 'vnet-${teamname}-${environment}-${vnetlocations[locationindex]}'
  }
  dependsOn:[privatednszones]
}]

module serverFarms 'modules/serverFarms.bicep' = [for locationindex in range(1, 2): {
  name: 'plan${teamname}${environment}${vnetlocationsacronym[locationindex]}deployment'

  params: {
    appServicePlanName: 'plan-${teamname}-${environment}-${vnetlocationsacronym[locationindex]}'
    location: vnetlocations[locationindex]
  }
  dependsOn:[privatednszones]
}]

module appservices 'modules/appService.bicep' = [for locationindex in range(1, 2): {
  name: 'appservice${teamname}${environment}${vnetlocationsacronym[locationindex]}deployment'

  params: {
    appServicePlanName: 'plan-${teamname}-${environment}-${vnetlocationsacronym[locationindex]}'
    location: vnetlocations[locationindex]
    appServiceName: 'app-${teamname}-${environment}-${vnetlocationsacronym[locationindex]}'
    subnetName: 'snet-apps-${teamname}-${environment}-${vnetlocations[locationindex]}'
    privateendpointsubnetName: 'snet-shared-${teamname}-${environment}-${vnetlocations[locationindex]}'
    vnetName: 'vnet-${teamname}-${environment}-${vnetlocations[locationindex]}'
  }
  dependsOn:[serverFarms]
}]

module jumpbox 'modules/virtualMachine.bicep' = {
  name: 'jumpboxdeployment'

  params: {
    adminPassword: 'ThisIsAPassword1!'
    adminUsername: 'jervelund'
    location: vnetlocations[0]
    subnetName: 'snet-shared-${teamname}-${environment}-${vnetlocations[0]}'
    vmName: 'jumpbox-${teamname}-${environment}'
    vnetName: 'vnet-${teamname}-${environment}-${vnetlocations[0]}'
  }
  dependsOn:[virtualNetworks]
}

module azureBasion 'modules/bastion.bicep' = {
  name: 'bastiondeployment'

  params: {
    bastionName: 'bas-mjteamgf-${environment}'
    location: vnetlocations[0]
    virtualNetworkName: 'vnet-${teamname}-${environment}-${vnetlocations[0]}'
  }
  dependsOn:[virtualNetworks]
}
