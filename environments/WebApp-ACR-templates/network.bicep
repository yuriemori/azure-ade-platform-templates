// network.bicep: VNet, NSG, Private Endpoint, Application Gateway(WAF)
param envName string
param location string

// NSG for Application Gateway subnet
resource appGatewayNsg 'Microsoft.Network/networkSecurityGroups@2022-05-01' = {
  name: '${envName}-appgateway-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-Internet-HTTP'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'Allow-Internet-HTTPS'
        properties: {
          priority: 1010
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'Allow-GatewayManager'
        properties: {
          priority: 1020
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '65200-65535'
          sourceAddressPrefix: 'GatewayManager'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// NSG for App Service subnet
resource appServiceNsg 'Microsoft.Network/networkSecurityGroups@2022-05-01' = {
  name: '${envName}-appservice-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-AppGateway-to-AppService'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '10.0.1.0/24'
          destinationAddressPrefix: '10.0.2.0/24'
        }
      }
      {
        name: 'Allow-AppGateway-to-AppService-HTTPS'
        properties: {
          priority: 1010
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '10.0.1.0/24'
          destinationAddressPrefix: '10.0.2.0/24'
        }
      }
    ]
  }
}

// NSG for default subnet (Key Vault, SQL, etc.)
resource defaultNsg 'Microsoft.Network/networkSecurityGroups@2022-05-01' = {
  name: '${envName}-default-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-AppService-to-KeyVault'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '10.0.2.0/24'
          destinationAddressPrefix: '10.0.3.0/24'
        }
      }
      {
        name: 'Allow-AppService-to-SQL'
        properties: {
          priority: 1010
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '1433'
          sourceAddressPrefix: '10.0.2.0/24'
          destinationAddressPrefix: '10.0.3.0/24'
        }
      }
    ]
  }
}

// Public IP for Application Gateway
resource appGatewayPublicIP 'Microsoft.Network/publicIPAddresses@2022-05-01' = {
  name: '${envName}-appgateway-pip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// Virtual Network with subnets
resource vnet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: '${envName}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [ '10.0.0.0/16' ]
    }
    subnets: [
      {
        name: 'appgateway-subnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: {
            id: appGatewayNsg.id
          }
        }
      }
      {
        name: 'appservice-subnet'
        properties: {
          addressPrefix: '10.0.2.0/24'
          networkSecurityGroup: {
            id: appServiceNsg.id
          }
          delegations: [
            {
              name: 'Microsoft.Web/serverFarms'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.3.0/24'
          networkSecurityGroup: {
            id: defaultNsg.id
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.KeyVault'
            }
            {
              service: 'Microsoft.Sql'
            }
          ]
        }
      }
    ]
  }
}

// Application Gateway with WAF
resource appGateway 'Microsoft.Network/applicationGateways@2022-05-01' = {
  name: '${envName}-appgateway'
  location: location
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
      capacity: 2
    }
    webApplicationFirewallConfiguration: {
      enabled: true
      firewallMode: 'Prevention'
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.0'
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: '${vnet.id}/subnets/appgateway-subnet'
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGatewayFrontendIP'
        properties: {
          publicIPAddress: {
            id: appGatewayPublicIP.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'appGatewayFrontendPort80'
        properties: {
          port: 80
        }
      }
      {
        name: 'appGatewayFrontendPort443'
        properties: {
          port: 443
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'appServiceBackendPool'
        properties: {}
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'appGatewayBackendHttpSettings'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 30
        }
      }
    ]
    httpListeners: [
      {
        name: 'appGatewayHttpListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', '${envName}-appgateway', 'appGatewayFrontendIP')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', '${envName}-appgateway', 'appGatewayFrontendPort80')
          }
          protocol: 'Http'
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'appServiceRoutingRule'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', '${envName}-appgateway', 'appGatewayHttpListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', '${envName}-appgateway', 'appServiceBackendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', '${envName}-appgateway', 'appGatewayBackendHttpSettings')
          }
        }
      }
    ]
  }
}

output vnetId string = vnet.id
output subnetId string = vnet.properties.subnets[2].id // default subnet
output appServiceSubnetId string = vnet.properties.subnets[1].id // appservice subnet
output appGatewayId string = appGateway.id
output appGatewayPublicIPId string = appGatewayPublicIP.id
