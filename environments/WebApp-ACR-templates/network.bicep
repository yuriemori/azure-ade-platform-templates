// network.bicep: VNet, NSG, Private Endpoint, Application Gateway(WAF)
param envName string
param location string

resource vnet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: '${envName}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [ '10.0.0.0/16' ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.1.0/24'
          serviceEndpoints: [
            {
              service: 'Microsoft.KeyVault'
            }
          ]
        }
      }
    ]
  }
}

output vnetId string = vnet.id
output subnetId string = vnet.properties.subnets[0].id
