terraform {
  required_providers {
    abbey = {
      source = "abbeylabs/abbey"
      version = "~> 0.2.6"
    }
    vault = {
      source = "hashicorp/vault"
      version = "~> 3.20.1"
    }
  }
}
