var location = resourceGroup().location

resource myVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: 'MyDemoVault1'
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: [
      
    ]
  }
}

resource mySecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: 'MyDemoSecret1'
  parent: myVault
  properties: {
    value: 'super secret'
  }
}

// this is optional as we may already have a resource, but for this demo, we are creating this to create the access policies here itself.
resource myAppSP 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: 'MyDemoAppSP'
  location: location
  kind:'app'
  sku: {
    name:'F1'
  }
}

resource myApp 'Microsoft.Web/sites@2022-09-01' = {
  name: 'MyDemoApp'
  location: location
  kind:'app'
  identity:{
    type:'SystemAssigned'
  }
  properties:{
    serverFarmId: myAppSP.id
  }
}

// we are using a Azure Key Vault URI to reference the secrets, but we also need permissions to do so.
resource mySettings 'Microsoft.Web/sites/config@2022-09-01' = {
  name: 'appsettings'
  parent:myApp
  properties: {
    'my:secret' : '@Microsoft.KeyVault(SecretUri=${mySecret.properties.secretUri})'
  }
}

resource myPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2023-02-01' = {
  name: 'add'
  parent: myVault
  properties: {
    accessPolicies: [
      {
        objectId: myApp.identity.principalId
        tenantId: myApp.identity.tenantId
        permissions: {
          secrets: [
            'get'
          ]
        }
      }
    ]
  }
}
