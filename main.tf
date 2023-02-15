terraform {
  backend "azurerm" {
    storage_account_name    = "tfstate65160"
    container_name          = "tfstate"
    key                     = "terraform.tfstate"
    access_key              = "SwYU6dK1Ia4cgD/24aA9TFf4tVeJEwfWOc66trURjvpMT6MGmZHHPHMfodogwNed/sl1FCyvmtr5+AStzk6rcw=="
  }
}

provider "azurerm" {
  features {}
  subscription_id = "570dbaa0-7af7-4a0b-b4f5-3d6720a474b6"
  tenant_id       = "aa99a5c1-3dc9-46c9-b68d-1dd458e5b42f"
  client_id       = "f89b98af-dce5-402a-a75b-a7ba3cb0c377"
  client_secret   = "yWp8Q~OanNcFNBxniLOUHbUDPeuIMUroohfaraX9"
}

resource "azurerm_resource_group" "RG" {
  name     = "terraform12345676"
  location = "eastus2"
}




resource "azurerm_storage_account" "SG" {
  name                     = "terraform12345676"
  location                 = azurerm_resource_group.RG.location
  resource_group_name      = azurerm_resource_group.RG.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_dns_zone" "DNS-Z" {
  name                = "stanleysmith.com"
  resource_group_name = azurerm_resource_group.RG.name
}

resource "azurerm_dns_cname_record" "DNS-CNAME-REC" {
  name                = "cdnverify.www"
  zone_name           = azurerm_dns_zone.DNS-Z.name
  resource_group_name = azurerm_resource_group.RG.name
  ttl                 = 3600
  record              = "cdnverify.stanleysmith.azureedge.net"
}

resource "azurerm_dns_cname_record" "DNS-CNAME-REC-ALIAS" {
  name                = "www"
  zone_name           = azurerm_dns_zone.DNS-Z.name
  resource_group_name = azurerm_resource_group.RG.name
  ttl                 = 3600
  target_resource_id  = "/subscriptions/570dbaa0-7af7-4a0b-b4f5-3d6720a474b6/resourcegroups/CloudChallenge/providers/Microsoft.Cdn/profiles/ResumeCDN/endpoints/allenshapovalov"
}

resource "azurerm_cdn_profile" "CND-PROFILE" {
  name                = "STANLEYCDN"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
  sku                 = "Standard_Microsoft"
}

resource "azurerm_cdn_endpoint" "CDNenpointeeee" {
  name                = "stanleeeeeycdn"
  profile_name        = azurerm_cdn_profile.CND-PROFILE.name
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

  origin {
    name      = "STANLEYorigin"
    host_name = azurerm_storage_account.SG.primary_blob_host
  }
}

/*
data "azurerm_dns_zone" "DNS-Z-Z" {
  name                = "stanleysmith.com"
  resource_group_name = azurerm_resource_group.RG.name
}

resource "azurerm_cdn_endpoint_custom_domain" "CUSTOM-DMNNN" {
  name            = "stanleeeeeycdn"
  cdn_endpoint_id = azurerm_cdn_endpoint.CDNenpointeeee.id
  host_name       = "${azurerm_dns_cname_record.DNS-CNAME-REC-ALIAS.name}.${data.azurerm_dns_zone.DNS-Z-Z.name}"
}
*/


resource "azurerm_resource_group" "RG-API" {
  name     = "terraformapiaccount"
  location = "eastus2"
}
resource "azurerm_storage_account" "SG-API" {
  name                     = "terraformapistorage"
  location                 = azurerm_resource_group.RG-API.location
  resource_group_name      = azurerm_resource_group.RG-API.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

resource "azurerm_cosmosdb_account" "cosmozzz" {
  name                = "terraforme-cosmos-db-${random_integer.ri.result}"
  location            = azurerm_resource_group.RG-API.location
  resource_group_name = azurerm_resource_group.RG-API.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"


  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }

  geo_location {
    location          = azurerm_resource_group.RG-API.location
    failover_priority = 0
  }
  capabilities {
    name = "EnableServerless"
  }
  capabilities {
    name = "EnableTable"

  }
}
data "azurerm_cosmosdb_account" "bruh" {
  name                = azurerm_cosmosdb_account.cosmozzz.name
  resource_group_name = azurerm_resource_group.RG-API.name
}


resource "azurerm_cosmosdb_table" "cosmozdb-tablez" {
  name                = "terraforme-cosmos-table"
  resource_group_name = data.azurerm_cosmosdb_account.bruh.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmozzz.name
}

resource "azurerm_service_plan" "example" {
  name                = "test-app-service-plan"
  resource_group_name = azurerm_resource_group.RG-API.name
  location            = azurerm_resource_group.RG-API.location
  os_type             = "Windows"
  sku_name            = "Y1"
}

resource "azurerm_windows_function_app" "example" {
  name                = "test-windows-function-app"
  resource_group_name = azurerm_resource_group.RG-API.name
  location            = azurerm_resource_group.RG-API.location

  storage_account_name       = azurerm_storage_account.SG.name
  storage_account_access_key = azurerm_storage_account.SG.primary_access_key
  service_plan_id            = azurerm_service_plan.example.id

  site_config {}
}

resource "azurerm_storage_blob" "404blob" {
  name                   = "404.html"
  storage_account_name   = azurerm_storage_account.SG.name
  storage_container_name = "azure-webjobs-secrets"
  type                   = "Block"
  source_uri                 = "https://raw.githubusercontent.com/CrimsonGlacier/resumeproject/main/.website/404.html"
}
resource "azurerm_storage_blob" "indexblob" {
  name                   = "index.html"
  storage_account_name   = azurerm_storage_account.SG.name
  storage_container_name = "azure-webjobs-secrets"
  type                   = "Block"
  source_uri                 = "https://raw.githubusercontent.com/CrimsonGlacier/resumeproject/main/.website/index.html"
}
resource "azurerm_storage_blob" "jsblob" {
  name                   = "jstesting.js"
  storage_account_name   = azurerm_storage_account.SG.name
  storage_container_name = "azure-webjobs-secrets"
  type                   = "Block"
  source_uri                 = "https://raw.githubusercontent.com/CrimsonGlacier/resumeproject/main/.website/jstesting.js"
}
resource "azurerm_storage_blob" "stylesblob" {
  name                   = "styles.css"
  storage_account_name   = azurerm_storage_account.SG.name
  storage_container_name = "azure-webjobs-secrets"
  type                   = "Block"
  source_uri                 = "https://raw.githubusercontent.com/CrimsonGlacier/resumeproject/main/.website/styles.css"
}

