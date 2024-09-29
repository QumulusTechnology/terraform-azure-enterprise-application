terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.0.1"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.10.0"
    }

  }
  required_version = ">= 1.0"
}
