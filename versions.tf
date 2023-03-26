terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.36.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.49.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.7.2"
    }

  }
  required_version = ">= 1.0"
}
