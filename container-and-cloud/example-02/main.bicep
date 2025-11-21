param containerGroupName string
param location string = resourceGroup().location
param imageName string
param containerName string = 'drupal'
param cpuCores int = 1
param memoryInGb int = 2
param port int = 80

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: containerGroupName
  location: location
  properties: {
    containers: [
      {
        name: containerName
        properties: {
          image: imageName
          resources: {
            requests: {
              cpu: cpuCores
              memoryInGB: memoryInGb
            }
          }
          ports: [
            {
              port: port
              protocol: 'TCP'
            }
          ]
        }
      }
    ]
    osType: 'Linux'
    ipAddress: {
      type: 'Public'
      ports: [
        {
          port: port
          protocol: 'TCP'
        }
      ]
    }
  }
}
