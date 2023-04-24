// az appservice plan create `
//     --name "${AppServicePlanNamePrefix}-eu" `
//     --resource-group $ResourceGroupName `
//     --location $PrimaryLocation `
//     --sku B1 `
//     --is-linux

param appServicePlanName string
param kind string = 'linux'
param sku string = 'B1'
param location string = resourceGroup().location

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: sku
  }
  kind: kind
  properties: {
    reserved: true
  }
}
