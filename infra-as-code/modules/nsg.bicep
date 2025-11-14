resource nsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: 'nsg-vmss'
  location: resourceGroup().location
  properties: {
    securityRules: [
      // Règle SSH
      { 
        name: 'AllowSSH'; 
        properties: { 
          priority: 1001; 
          direction: 'Inbound'; 
          access: 'Allow';
          protocol: 'Tcp'; 
          sourceAddressPrefix: '*'; 
          destinationAddressPrefix: '*';
          sourcePortRange: '*'; 
          destinationPortRange: '22' 
        }
      },
      // Règle HTTP
      { 
        name: 'AllowHTTP'; 
        properties: { 
          priority: 1002; 
          direction: 'Inbound'; 
          access: 'Allow';
          protocol: 'Tcp'; 
          sourceAddressPrefix: '*'; 
          destinationAddressPrefix: '*';
          sourcePortRange: '*'; 
          destinationPortRange: '80' 
        }
      },
      // Règle HTTPS
      { 
        name: 'AllowHTTPS'; 
        properties: { 
          priority: 1003; 
          direction: 'Inbound'; 
          access: 'Allow';
          protocol: 'Tcp'; 
          sourceAddressPrefix: '*'; 
          destinationAddressPrefix: '*';
          sourcePortRange: '*'; 
          destinationPortRange: '443'
         }
      }
    ]
  }
}
output nsgId string = nsg.id
