terraform {
  required_version = ">= 1.3.0"
  required_providers {
    cloudscale = {
      source  = "cloudscale-ch/cloudscale"
      version = "5.0.1"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 2.1"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.3"
    }
    gitfile = {
      source  = "igal-s/gitfile"
      version = "1.0.0"
    }
  }
}
