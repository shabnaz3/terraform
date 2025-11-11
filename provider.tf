terraform {
  required_providers {
    gitlab = {
      source = "registry.terraform.io/gitlabhq/gitlab"
      version =  "16.9.1"
    }
     kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.27.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.12.1"
    }
     gitlabci = {
      source = "registry.terraform.io/rsrchboy/gitlabci"
    }

  }
}

