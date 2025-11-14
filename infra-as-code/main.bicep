param adminUsername string
param sshPublicKey string
param instanceCount int
param vmSku string

resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: 'mon-vnet'
  location: resourceGroup().location
  properties: {
    addressSpace: { addressPrefixes: ['10.0.0.0/16'] }
    subnets: [
      {
        name: 'default'
        properties: { addressPrefix: '10.0.1.0/24' }
      }
    ]
  }
}

module nsgModule 'modules/nsg.bicep' = {
  name: 'nsgModule'
}

resource subnetUpdate 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' = {
  name: '${vnet.name}/default'
  properties: {
    addressPrefix: '10.0.1.0/24'
    networkSecurityGroup: { id: nsgModule.outputs.nsgId }
  }
}

module vmssModule 'modules/vmss-ubuntu.bicep' = {
  name: 'vmssModule'
  params: {
    vmssName: 'mon-vmss'
    adminUsername: adminUsername
    sshPublicKey: sshPublicKey
    subnetId: vnet.properties.subnets[0].id
    instanceCount: instanceCount
    vmSku: vmSku
  }
}
