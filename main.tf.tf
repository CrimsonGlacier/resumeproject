terraform {
  required_version = ">=1.3.7"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.41.0"
    }
  }
}
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
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