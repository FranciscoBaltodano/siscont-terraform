resource "azurerm_virtual_network" "vnet" {
  name                  = "vnet-${var.project}-${var.environment}"
  address_space         =  ["10.0.0.0/16"]
  resource_group_name   = azurerm_resource_group.rg.name
  location              = var.location

  tags = var.tags
}

resource "azurerm_subnet" "subnetdb" {
  name                  = "subnet-db-${var.project}-${var.environment}"
  resource_group_name   = azurerm_resource_group.rg.name
  virtual_network_name  = azurerm_virtual_network.vnet.name
  address_prefixes      = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "subnetapp" {
  name                  = "subnet-app-${var.project}-${var.environment}"
  resource_group_name   = azurerm_resource_group.rg.name
  virtual_network_name  = azurerm_virtual_network.vnet.name
  address_prefixes      = ["10.0.2.0/24"]
}  

resource "azurerm_subnet" "subnetweb-ui" {
  name                  = "subnet-web-ui-${var.project}-${var.environment}"
  resource_group_name   = azurerm_resource_group.rg.name
  virtual_network_name  = azurerm_virtual_network.vnet.name
  address_prefixes      = ["10.0.3.0/24"]
  
  delegation {
    name      = "webapp_delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "subnetweb-api" {
  name                  = "subnet-web-api-${var.project}-${var.environment}"
  resource_group_name   = azurerm_resource_group.rg.name
  virtual_network_name  = azurerm_virtual_network.vnet.name
  address_prefixes      = ["10.0.6.0/24"]
  
  delegation {
    name      = "webapp_delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "subnetfunction" {
  name                  = "subnet-function-${var.project}-${var.environment}"
  resource_group_name   = azurerm_resource_group.rg.name
  virtual_network_name  = azurerm_virtual_network.vnet.name
  address_prefixes      = ["10.0.5.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "acceptanceTestSecurityGroup"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = var.tags
}

resource "azurerm_network_security_rule" "sr-ssh" {
  name                       = "Allow-SSH"
  priority                   = 1000
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "22"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "sr-http" {
  name                       = "Allow-HTTP"
  priority                   = 1010
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "80"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "sr-https" {
  name                       = "Allow-HTTPS"
  priority                   = 1020
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "443"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_subnet_network_security_group_association" "subnet_db_nsg_association" {
  subnet_id                 = azurerm_subnet.subnetdb.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet_network_security_group_association" "subnet_app_nsg_association" {
  subnet_id                 = azurerm_subnet.subnetapp.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet_network_security_group_association" "subnet_web_ui_nsg_association" {
  subnet_id                 = azurerm_subnet.subnetweb-ui.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet_network_security_group_association" "subnet_web_api_nsg_association" {
  subnet_id                 = azurerm_subnet.subnetweb-api.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
