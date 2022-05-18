param virtualMachines_vmdev_name string = 'vmdev'
param disks_vmdev_OsDisk_1_da119e63fe584326a358c600205eb886_externalid string = '/subscriptions/97e6e7ea-a213-4f0e-87e0-ea14b9781c76/resourceGroups/rg-bicepdemo2-poc-eus/providers/Microsoft.Compute/disks/vmdev_OsDisk_1_da119e63fe584326a358c600205eb886'
param networkInterfaces_vmdev82_externalid string = '/subscriptions/97e6e7ea-a213-4f0e-87e0-ea14b9781c76/resourceGroups/rg-bicepdemo2-poc-eus/providers/Microsoft.Network/networkInterfaces/vmdev82'

resource virtualMachines_vmdev_name_resource 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: virtualMachines_vmdev_name
  location: 'eastus'
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
        name: '${virtualMachines_vmdev_name}_OsDisk_1_da119e63fe584326a358c600205eb886'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
          id: disks_vmdev_OsDisk_1_da119e63fe584326a358c600205eb886_externalid
        }
        deleteOption: 'Delete'
        diskSizeGB: 127
      }
      dataDisks: []
    }
    osProfile: {
      computerName: virtualMachines_vmdev_name
      adminUsername: 'alex'
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
      allowExtensionOperations: true
      requireGuestProvisionSignal: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaces_vmdev82_externalid
          properties: {
            deleteOption: 'Detach'
          }
        }
      ]
    }
  }
}