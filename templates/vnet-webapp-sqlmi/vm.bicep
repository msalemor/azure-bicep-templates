param virtualNetworkName string
param location string
param vmSize string = 'Standard_D2s_v3'
param vmName string = 'vmtest'

@description('Username for the Virtual Machine.')
param adminUsername string = 'alex'

@description('Password for the Virtual Machine.')
@minLength(12)
@secure()
param adminPassword string

resource interface 'Microsoft.Network/networkInterfaces@2022-09-01' = {
  name: 'nic-vmtest'
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
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

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: 'storagetestvmdia'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
}

var OSVersion = '2019-datacenter-gensecond'

resource vm 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: OSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
      dataDisks: [
        {
          diskSizeGB: 1023
          lun: 0
          createOption: 'Empty'
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: interface.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: storageAccount.properties.primaryEndpoints.blob
      }
    }
  }
}
