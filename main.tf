provider "kubernetes" {
  # Configuration options
    config_path = "/etc/rancher/k3s/k3s.yaml"

}
provider "helm" {
  kubernetes {
    config_path = "/etc/rancher/k3s/k3s.yaml"
  }
}

provider "gitlab" {
  token = "glpat-zvrFwYExgXue1Fz9Rmm"  #gitlab token
  base_url = "https://gitlab.com/"
}

