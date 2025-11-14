param vmssName string
param resourceGroupName string

resource getIps 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: '${vmssName}-getIPs'
  location: resourceGroup().location
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '5.6'
    scriptContent: '''
      $ips = Get-AzVmssPublicIpAddress -ResourceGroupName "${resourceGroupName}" -VMScaleSetName "${vmssName}"
      $ips | Foreach-Object { $_.IpAddress }
      $ips | ConvertTo-Json
    '''
    timeout: 'PT30M'
    cleanupPreference: 'OnSuccess'
    forceUpdateTag: 'always'
  }
}
output ips array = getIps.properties.outputs
