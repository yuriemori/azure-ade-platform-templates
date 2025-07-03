// appInsights.bicep: Application Insights
param envName string
param location string

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${envName}-appi'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

output instrumentationKey string = appInsights.properties.InstrumentationKey
