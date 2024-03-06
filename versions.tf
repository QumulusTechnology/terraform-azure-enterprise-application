terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.39.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.58.0"
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
