


resource firewall 'Microsoft.Network/azureFirewalls@2022-01-01' = {
  name: firewallName
  location: location
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
    threatIntelMode: 'Alert'
    ipConfigurations: azureFirewallIpConfigurations
    applicationRuleCollections: [
      {
        name: 'web'
        properties: {
          priority: 100
          action: {
            type: 'Allow'
          }
          rules: [
            {
              name: 'wan-address'
              protocols: [
                {
                  protocolType: 'Http'
                  port: 80
                }
                {
                  protocolType: 'Https'
                  port: 443
                }
              ]
              targetFqdns: [
                'getmywanip.com'
              ]
              sourceAddresses: [
                '*'
              ]
            }
            {
              name: 'google'
              protocols: [
                {
                  protocolType: 'Http'
                  port: 80
                }
                {
                  protocolType: 'Https'
                  port: 443
                }
              ]
              targetFqdns: [
                'www.google.com'
              ]
              sourceAddresses: [
                '10.0.1.0/24'
              ]
            }
            {
              name: 'wupdate'
              protocols: [
                {
                  protocolType: 'Http'
                  port: 80
                }
                {
                  protocolType: 'Https'
                  port: 443
                }
              ]
              fqdnTags: [
                'WindowsUpdate'
              ]
              sourceAddresses: [
                '*'
              ]
            }
          ]
        }
      }
    ]
    natRuleCollections: [
      {
        name: 'Coll-01'
        properties: {
          priority: 100
          action: {
            type: 'Dnat'
          }
          rules: [
            {
              name: 'rdp-01'
              protocols: [
                'TCP'
              ]
              translatedAddress: '10.0.1.4'
              translatedPort: '3389'
              sourceAddresses: [
                '*'
              ]
              destinationAddresses: [
                publicIPAddress[0].properties.ipAddress
              ]
              destinationPorts: [
                '3389'
              ]
            }
            {
              name: 'rdp-02'
              protocols: [
                'TCP'
              ]
              translatedAddress: '10.0.1.5'
              translatedPort: '3389'
              sourceAddresses: [
                '*'
              ]
              destinationAddresses: [
                publicIPAddress[1].properties.ipAddress
              ]
              destinationPorts: [
                '3389'
              ]
            }
          ]
        }
      }
    ]
  }
}
