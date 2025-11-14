param vmssName string
param adminUsername string
param sshPublicKey string
param subnetId string
param instanceCount int
param vmSku string

resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2024-11-01' = {
  name: vmssName
  location: resourceGroup().location
  sku: { name: vmSku; capacity: instanceCount }
  properties: {
    upgradePolicy: { mode: 'Automatic' }
    virtualMachineProfile: {
      storageProfile: {
        imageReference: { publisher: 'Canonical'; offer: 'UbuntuServer'; sku: '22.04-LTS'; version: 'latest' }
      }
      osProfile: {
        computerNamePrefix: vmssName
        adminUsername: adminUsername
        linuxConfiguration: {
          disablePasswordAuthentication: true
          ssh: { publicKeys: [ { path: '/home/${adminUsername}/.ssh/authorized_keys'; keyData: sshPublicKey } ] }
        }
      }
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: 'nic1'
            properties: {
              primary: true
              ipConfigurations: [
                {
                  name: 'ipconfig1'
                  properties: {
                    subnet: { id: subnetId }
                    primary: true
                    publicIPAddressConfiguration: {
                      name: 'pubip'
                      properties: { idleTimeoutInMinutes: 10 }
                    }
                  }
                }
              ]
            }
          }
        ]
      }
      extensionProfile: {
        extensions: [
          {
            name: 'DockerExtension'
            properties: {
              publisher: 'Microsoft.Azure.Extensions'
              type: 'CustomScript'
              typeHandlerVersion: '2.1'
              autoUpgradeMinorVersion: true
              settings: {
                commandToExecute: 'bash -c "apt-get update && apt-get install -y docker.io && systemctl enable docker && systemctl start docker"'
              }
            }
          }
        ]
      }
    }
  }
}
output instanceId string = vmss.id
