# Configure the Microsoft Azure Provider
provider "azurerm" {
    subscription_id = "85b2ce3f-888f-4156-b09a-fb163de5108e"
    client_id       = "2d55e18b-3ad4-42d4-bf9c-ba2f24a6c5b5"
    client_secret   = "fUi7_8DReqybCDJH/OXSBy0j3fR:QxA/"
    tenant_id       = "d8325d6b-456c-4eb7-8b79-780d991efb8f"
}

# Create a resource group if it doesn’t exist

resource "azurerm_resource_group" "sonargroup" {
    name     = "TestGroup"
    location = "eastus"

    tags = {
        environment = "Terraform Demo"
    }

}



# Create virtual network

resource "azurerm_virtual_network" "sonarnetwork" {

    name                = "sonarVnet"

    address_space       = ["10.0.0.0/16"]

    location            = "eastus"

    resource_group_name = "${azurerm_resource_group.sonargroup.name}"



    tags = {

        environment = "Terraform Demo"

    }

}



# Create subnet

resource "azurerm_subnet" "sonarsubnet" {

    name                 = "sonarSubnet"

    resource_group_name  = "${azurerm_resource_group.sonargroup.name}"

    virtual_network_name = "${azurerm_virtual_network.sonarnetwork.name}"

    address_prefix       = "10.0.1.0/24"

}



# Create public IPs

resource "azurerm_public_ip" "sonarpublicip" {

    name                         = "sonarPublicIP"

    location                     = "eastus"

    resource_group_name          = "${azurerm_resource_group.sonargroup.name}"

    public_ip_address_allocation = "Dynamic"



    tags = {

        environment = "Terraform Demo"

    }

}




# Generate random text for a unique storage account name

resource "random_id" "sonarrandomId" {

    keepers = {

        # Generate a new ID only when a new resource group is defined

        resource_group = "${azurerm_resource_group.sonargroup.name}"

    }

    

    byte_length = 8

}



# Create virtual machine

resource "azurerm_virtual_machine" "sonarvm" {

    name                  = "sonarVM"

    location              = "eastus"

    resource_group_name   = "${azurerm_resource_group.sonargroup.name}"

    vm_size               = "Standard_DS1_v2"



    storage_os_disk {

        name              = "sonarDisk"

        caching           = "ReadWrite"

        create_option     = "FromImage"

        managed_disk_type = "Premium_LRS"

    }



    storage_image_reference {

        publisher = "OpenLogic"

        offer     = "CentOS"

        sku       = "7.5"

        version   = "latest"

    }



    os_profile {

        computer_name  = "sonarvm"

        admin_username = "azureuser"

        admin_password = "Password1234!"

    }



    os_profile_linux_config {

        disable_password_authentication = false

    }

    

    connection {

       type = "ssh"

       host = "sonarvm"

       user = "azureuser"

       port = "22"

       agent = false

    }

    tags = {

        environment = "Terraform Demo"

    }
}
resource "azurerm_virtual_machine_extension" "sonarextension" {
      name                 = "sonarVM"
      location             = "East US"
      resource_group_name  = "${azurerm_resource_group.sonargroup.name}"
      virtual_machine_name = "${azurerm_virtual_machine.sonarvm.name}"
      publisher            = "Microsoft.OSTCExtensions"
      type                 = "CustomScriptForLinux"
      type_handler_version = "1.2"

      settings = <<SETTINGS
      {
	"fileUris": ["https://storeage1091.blob.core.windows.net/sonarstorage/SonarCentos.sh"],
	"commandToExecute": "sh SonarCentos.sh"
	}
    SETTINGS

    tags = {

        environment = "Terraform Demo"

    }
}
