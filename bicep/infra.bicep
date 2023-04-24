/*
  Deploys Cloudburst infrastructure resources.
*/

param vnetlocations array = ['swedencentral', 'westeurope','eastus']


param vnetlocationsacronym array = ['sw', 'eu','us']
param addressPrefixes array = ['10.0.0.0/22','10.0.4.0/22','10.0.8.0/22']


@minLength(2)
@maxLength(8)
param teamname string = 'mjteamgf'


param subnets array =  [[{
  name: 'snet-shared-${teamname}-dev-${vnetlocations[0]}'
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
    name: 'snet-shared-${teamname}-dev-${vnetlocations[1]}'
    properties: {
      addressPrefix: '10.0.4.0/25'
    } }
  {
    name: 'snet-apps-${teamname}-dev-${vnetlocations[1]}'
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
  name: 'snet-shared-${teamname}-dev-${vnetlocations[2]}'
  properties: {
  addressPrefix: '10.0.8.0/25'
  }},{
       name: 'snet-apps-${teamname}-dev-${vnetlocations[2]}'
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
  name: 'VirtualNetworkDeployment${vnetlocations[vnetindex]}deployment'

  params: {
    virtualNetworkName: 'vnet-${teamname}-dev-${vnetlocations[vnetindex]}'
    location: vnetlocations[vnetindex]
    addressPrefixes: addressPrefixes[vnetindex]
    subnets: subnets[vnetindex]
  }
}]

module virtualNetworksPeering 'modules/vnetpeering.bicep' = [for vnetindex in range(1, 2): {
  name: 'VirtualNetworkPeeringDeployment${vnetlocations[vnetindex]}deployment'

  params: {
    remotevirtualNetworkName: 'vnet-${teamname}-dev-${vnetlocations[vnetindex]}'
    virtualNetworkName: 'vnet-${teamname}-dev-${vnetlocations[0]}'
  }
  dependsOn:[virtualNetworks]
}]

module privatednszones 'modules/privatednszones.bicep' = {
  name: 'privatednszonesdeployment'
}

module privatednszoneslinking 'modules/privatednszonesvnetlink.bicep' = [for vnetindex in range(0, length(vnetlocations)): {
  name: 'privatednszonesvnetlink${vnetlocations[vnetindex]}deployment'
  params: {
    vnetName: 'vnet-${teamname}-dev-${vnetlocations[vnetindex]}'
  }
  dependsOn:[virtualNetworks,privatednszones]
}]

module sharedstorageaccounts 'modules/storageAccount.bicep' = {
  name: 'stshard${teamname}dev${vnetlocationsacronym[0]}deployment'

  params: {
    storageAccountName: 'stshared${teamname}dev'
    location: vnetlocations[0]
    subnetName: 'snet-shared-${teamname}-dev-${vnetlocations[0]}'
    vnetName: 'vnet-${teamname}-dev-${vnetlocations[0]}'
  }
  dependsOn:[privatednszones]
}

module storageaccounts 'modules/storageAccount.bicep' = [for locationindex in range(1, 2): {
  name: 'st${teamname}dev${vnetlocationsacronym[locationindex]}deployment'

  params: {
    storageAccountName: 'st${teamname}dev${vnetlocationsacronym[locationindex]}'
    location: vnetlocations[locationindex]
    subnetName: 'snet-shared-${teamname}-dev-${vnetlocations[locationindex]}'
    vnetName: 'vnet-${teamname}-dev-${vnetlocations[locationindex]}'
  }
  dependsOn:[privatednszones]
}]

module serverFarms 'modules/serverFarms.bicep' = [for locationindex in range(1, 2): {
  name: 'plan${teamname}dev${vnetlocationsacronym[locationindex]}deployment'

  params: {
    appServicePlanName: 'plan-${teamname}-dev-${vnetlocationsacronym[locationindex]}'
    location: vnetlocations[locationindex]
  }
  dependsOn:[privatednszones]
}]

module appservices 'modules/appService.bicep' = [for locationindex in range(1, 2): {
  name: 'appservice${teamname}dev${vnetlocationsacronym[locationindex]}deployment'

  params: {
    appServicePlanName: 'plan-${teamname}-dev-${vnetlocationsacronym[locationindex]}'
    location: vnetlocations[locationindex]
    appServiceName: 'app-${teamname}-dev-${vnetlocationsacronym[locationindex]}'
    subnetName: 'snet-apps-${teamname}-dev-${vnetlocations[locationindex]}'
    privateendpointsubnetName: 'snet-shared-${teamname}-dev-${vnetlocations[locationindex]}'
    vnetName: 'vnet-${teamname}-dev-${vnetlocations[locationindex]}'
  }
  dependsOn:[serverFarms]
}]

module jumpbox 'modules/virtualMachine.bicep' = {
  name: 'jumpboxdeployment'

  params: {
    adminPassword: 'ThisIsAPassword1!'
    adminUsername: 'jervelund'
    location: vnetlocations[0]
    subnetName: 'snet-shared-${teamname}-dev-${vnetlocations[0]}'
    vmName: 'jumpbox-${teamname}-dev'
    vnetName: 'vnet-${teamname}-dev-${vnetlocations[0]}'
  }
  dependsOn:[virtualNetworks]
}

// module azureBasion 'modules/bastion.bicep' = {
//   name: 'bastiondeployment'

//   params: {
//     bastionName: 'bas-mjteamgf-dev'
//     location: vnetlocations[0]
//     virtualNetworkName: 'vnet-${teamname}-dev-${vnetlocations[0]}'
//   }
//   dependsOn:[virtualNetworks]
// }

