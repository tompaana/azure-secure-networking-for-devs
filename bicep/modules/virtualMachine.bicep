param vmName string
param computerName string = substring('vm-${vmName}',0,15) //max 15 characters long
param location string = resourceGroup().location

@minLength(2)
@maxLength(64)
param vnetName string

@minLength(1)
@maxLength(80)
param subnetName string

param adminUsername string

@secure()
param adminPassword string


resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' existing  = {
  name: vnetName
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: 'nsg-${vmName}'
  location: location
}

resource vmNic 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: 'nic-${vmName}'
  location: location

  properties: {
    ipConfigurations: [
      {
        name: 'internalIPConfig'

        properties: {
          subnet: {
            id: '${virtualNetwork.id}/subnets/${subnetName}'
          }

          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]

    networkSecurityGroup: {
      id: networkSecurityGroup.id

      properties: {
        securityRules: [
          {
            name: 'DenyAllInbound'
            properties: {
              description: 'Denies all inbound traffic'
              access: 'Deny'
              direction: 'Inbound'
              protocol: '*'
            }
          }
        ]
      }
    }
  }
}

var vnetconfig = { networkInterfaces: [  {    id: vmNic.id  }]}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: 'vm-${vmName}'
  location: location

  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2d_v5'
    }

    networkProfile: vnetconfig

    osProfile: {
      adminPassword: adminPassword
      adminUsername: adminUsername
      computerName: computerName
      windowsConfiguration: {}
    }

    storageProfile: {
      imageReference: {
        offer: 'windowsserver'
        publisher: 'microsoftwindowsserver'
        sku: '2022-datacenter'
        version: 'latest'
      }

      osDisk: {
        createOption: 'FromImage'
        deleteOption: 'Delete'
      }
    }
  }
}
