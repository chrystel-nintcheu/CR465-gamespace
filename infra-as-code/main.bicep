param adminUsername string
param sshPublicKey string
param instanceCount int
param vmSku string
param imageReference object 

resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: 'cr465-vnet'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: 'nsg-vmss'
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'AllowSSH'
        properties: {
          priority: 1001
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          sourcePortRange: '*'
          destinationPortRange: '22'
        }
      }
      {
        name: 'AllowHTTP'
        properties: {
          priority: 1002
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          sourcePortRange: '*'
          destinationPortRange: '80'
        }
      }
      {
        name: 'AllowHTTPS'
        properties: {
          priority: 1003
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          sourcePortRange: '*'
          destinationPortRange: '443'
        }
      }
    ]
  }
}

// Mise à jour du subnet pour rattacher le NSG
resource subnetupdate 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' = {
  name: '${vnet.name}/default'
  properties: {
    addressPrefix: '10.0.1.0/24'
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2024-11-01' = {
  name: 'mon-vmss'
  location: resourceGroup().location
  sku: {
    name: vmSku
    capacity: instanceCount
  }
  properties: {
    upgradePolicy: {
      mode: 'Automatic'
    }
    virtualMachineProfile: {
      storageProfile: {
        imageReference: imageReference
      }
      osProfile: {
        computerNamePrefix: 'mon-vmss'
        adminUsername: adminUsername
        linuxConfiguration: {
          disablePasswordAuthentication: true
          ssh: {
            publicKeys: [
              {
                path: '/home/${adminUsername}/.ssh/authorized_keys'
                keyData: sshPublicKey
              }
            ]
          }
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
                    subnet: {
                      id: vnet.properties.subnets[0].id
                    }
                    primary: true
                    publicIPAddressConfiguration: {
                      name: 'pubip'
                      properties: {
                        idleTimeoutInMinutes: 10
                      }
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

// Script pour sortir les IPs publiques (nécessite Azure Powershell côté déploiement)
resource getIps 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'getIPs'
  location: resourceGroup().location
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '5.6'
     retentionInterval: 'PT1H'
    scriptContent: '''
      $ips = Get-AzVmssPublicIpAddress -ResourceGroupName "${resourceGroup().name}" -VMScaleSetName "mon-vmss"
      $ips | Foreach-Object { $_.IpAddress }
      $ips | ConvertTo-Json
    '''
    timeout: 'PT30M'
    cleanupPreference: 'OnSuccess'
    forceUpdateTag: 'always'
  }
}
output ips object = getIps.properties.outputs
