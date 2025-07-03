// sql.bicep: Azure SQL Database + Private Endpoint
param envName string
param vnetId string
param location string
@secure()
param sqlAdminPassword string

resource sqlServer 'Microsoft.Sql/servers@2022-02-01-preview' = {
  name: '${envName}-sqlsrv'
  location: location
  properties: {
    administratorLogin: 'sqladminuser'
    administratorLoginPassword: sqlAdminPassword
    version: '12.0'
    publicNetworkAccess: 'Disabled'
  }
}

resource sqlDb 'Microsoft.Sql/servers/databases@2022-02-01-preview' = {
  name: '${sqlServer.name}/appdb'
  location: location
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648
    sampleName: 'AdventureWorksLT'
  }
}
output sqlServerName string = sqlServer.name
