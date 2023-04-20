param location string
param vm_name string
param user_name string
@secure()
param user_pwd string
param subnetId string
//var storage_name = 'stor${vm_name}'
var nick_name = 'nic-${vm_name}'
var networkSecurityGroupName = 'nsg-${vm_name}'

// resource vmStorage 'Microsoft.Storage/storageAccounts@2021-09-01' = {
//   name: storage_name
//   location: location
//   kind: 'StorageV2'
//   sku: {
//     name: 'Standard_LRS'
//   }
// }

resource vmNic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: nick_name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

resource vmNSGsecurityGroup 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-allow-3389'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '3389'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource vmdev 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: vm_name
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2ms'
    }
    storageProfile: {
      imageReference: {
        publisher: 'microsoftvisualstudio'
        offer: 'visualstudio2022'
        sku: 'vs-2022-ent-latest-win11-n'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        name: '${vm_name}_OsDisk_1_${uniqueString(resourceGroup().id)}'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
        deleteOption: 'Delete'
        diskSizeGB: 127
      }
      dataDisks: []
    }
    osProfile: {
      computerName: vm_name
      adminUsername: user_name
      adminPassword: user_pwd
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
          assessmentMode: 'ImageDefault'
          enableHotpatching: false
        }
      }
      secrets: []
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmNic.id
          properties: {
            deleteOption: 'Detach'
          }
        }
      ]
    }
  }
}
