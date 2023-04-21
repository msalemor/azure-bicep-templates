param virtualNetworkName string
param location string
param vmSize string = 'Standard_D2s_v3'
param vmName string = 'vmtest'
@description('Username for the Virtual Machine.')
param adminUsername string = 'alex'
@description('Password for the Virtual Machine.')
@minLength(15)
@secure()
param adminPassword string
//param gid string = newGuid()

resource interface 'Microsoft.Network/networkInterfaces@2022-09-01' = {
  name: 'nic-${vmName}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipf-${vmName}'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, 'vmSubnet')
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

// resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
//   name: 'storagetestvmdia'
//   location: location
//   sku: {
//     name: 'Standard_LRS'
//   }
//   kind: 'Storage'
// }

resource virtualMachines_vmtest_name_resource 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'

      }
      osDisk: {
        name: '${vmName}_OsDisk_1_${uniqueString(resourceGroup().id)}'
        osType: 'Windows'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        deleteOption: 'Delete'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
      dataDisks: []
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
          assessmentMode: 'ImageDefault'
          enableHotpatching: false
        }
        enableVMAgentPlatformUpdates: false
      }
      secrets: []
    }
    securityProfile: {
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
      securityType: 'TrustedLaunch'
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: interface.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
  }
}

resource vmShutdownRule 'microsoft.devtestlab/schedules@2018-09-15' = {
  name: '${vmName}-shutdown}'
  location: location
  properties: {
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: '1900'
    }
    timeZoneId: 'Eastern Standard Time'
    notificationSettings: {
      status: 'Enabled'
      timeInMinutes: 30
      emailRecipient: 'alemor@microsoft.com'
      notificationLocale: 'en'
    }
    targetResourceId: virtualMachines_vmtest_name_resource.id
  }
}
