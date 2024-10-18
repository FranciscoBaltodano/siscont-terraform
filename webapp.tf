# App service plan de la UI
resource "azurerm_app_service_plan" "app_service_plan_ui" {
    name                = "asp-ui-${var.project}-${var.environment}"
    location            = var.location
    resource_group_name = azurerm_resource_group.rg.name
    kind                = "Linux"
    reserved            = true
    sku {
        tier = "Standard"
        size = "B1"
    }

    tags = var.tags
}

resource "azurerm_app_service_plan" "app_service_plan_api" {
    name                = "asp-api-${var.project}-${var.environment}"
    location            = var.location
    resource_group_name = azurerm_resource_group.rg.name
    kind                = "Linux"
    reserved            = true
    sku {
        tier = "Standard"
        size = "B1"
    }

    tags = var.tags
}

resource "azurerm_container_registry" "acr" {
    name                = "azurecontainerregistry${var.project}${var.environment}"
    resource_group_name = azurerm_resource_group.rg.name
    location            = var.location
    sku                 = "Basic"
    admin_enabled       = true

    tags                = var.tags
}

resource "azurerm_app_service" "webapp1" {
  name                = "ui-webapp-${var.project}-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan_ui.id
  
  site_config {
    linux_fx_version = "DOCKER|${azurerm_container_registry.acr.login_server}/${var.project}/ui:latest"
    always_on = true
    vnet_route_all_enabled = true
  }

  app_settings = {
    "DOCKER_REGISTRY_SERVER_URL"      = "https://${azurerm_container_registry.acr.login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME" = azurerm_container_registry.acr.admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD" = azurerm_container_registry.acr.admin_password
    "WEBSITE_VNET_ROUTE_ALL"          = "1"
  }

  depends_on = [ 
    azurerm_app_service_plan.app_service_plan_ui,
    azurerm_container_registry.acr,
    azurerm_subnet.subnetweb-ui 
  ]

   tags = var.tags
}

resource "azurerm_app_service_virtual_network_swift_connection" "webapp1_vnet_integration" {
  app_service_id = azurerm_app_service.webapp1.id
  subnet_id      = azurerm_subnet.subnetweb-ui.id
  depends_on     = [ 
    azurerm_app_service.webapp1
  ]
  
}

resource "azurerm_app_service" "webapp2" {
  name                = "api-webapp-${var.project}-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan_api.id
  
  site_config {
    linux_fx_version       = "DOCKER|${azurerm_container_registry.acr.login_server}/${var.project}/api:latest"
    always_on              = true
    vnet_route_all_enabled = true
  }

  app_settings = {
    "DOCKER_REGISTRY_SERVER_URL"      = "https://${azurerm_container_registry.acr.login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME" = azurerm_container_registry.acr.admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD" = azurerm_container_registry.acr.admin_password
    "WEBSITE_VNET_ROUTE_ALL"          = "1"
  }

  depends_on = [ 
    azurerm_app_service_plan.app_service_plan_api,
    azurerm_container_registry.acr,
    azurerm_subnet.subnetweb-api
  ]

   tags = var.tags
}

resource "azurerm_app_service_virtual_network_swift_connection" "webapp2_vnet_integration" {
  app_service_id = azurerm_app_service.webapp2.id
  subnet_id = azurerm_subnet.subnetweb-api.id
  
  depends_on = [ 
    azurerm_app_service.webapp2
  ]
}
