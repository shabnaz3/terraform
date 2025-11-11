resource "kubernetes_namespace" "gitlab-runner" {
  metadata {
  
    labels = {
      mylabel = "label-value"
    }
    name = "gitlab-runner"
  }
}
resource "kubernetes_service_account_v1" "gitlab-runner-serviceaccount" {
   metadata {
     name = "gitlab-runner"
     namespace = "gitlab-runner"
    }
   depends_on = [kubernetes_namespace.gitlab-runner ]
}
resource "kubernetes_role" "terraform-gitlab-runner-role" {
  metadata {
    name = "terraform-gitlab-runner-role"
    namespace = "gitlab-runner"
  }
  rule {
    api_groups     = [""]
    resources      = ["configmaps", "events", "pods", "pods/attach", "pods/exec", "secrets", "services"]
    verbs          = ["list", "get", "watch", "create", "delete", "update"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods/exec"]
    verbs      = ["get", "list"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods/log"]
    verbs      = ["get", "list"]
  }
  rule {
    api_groups = [""]
    resources  = ["namespaces"]
    verbs      = ["delete", "create"]
  }
  rule {
    api_groups = [""]
    resources  = ["serviceacounts"]
    verbs      = ["get"]
  }
  depends_on = [kubernetes_namespace.gitlab-runner]
}
resource "kubernetes_role_binding" "terraform-gitlab-runner-role-binding" {
  metadata {
    name      = "terraform-gitlab-runner-role-binding"
    namespace = "gitlab-runner"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "terraform-gitlab-runner-role"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "gitlab-runner"
    namespace = "gitlab-runner"
  }
  depends_on =[
    kubernetes_namespace.gitlab-runner ,
    kubernetes_service_account_v1.gitlab-runner-serviceaccount

  ]
}
data "gitlab_group" "pi-lar" {
   full_path = "pi-lar"
}
data "gitlab_project" "neuropil-k8s" {
    path_with_namespace = "pi-lar/neuropil-k8s"
}
resource "gitlab_user_runner" "ldap-dev01-runner" {
  runner_type = "project_type"
  project_id  = 59287439
}resource "kubernetes_namespace" "gitlab-runner" {
  metadata {
  
    labels = {
      mylabel = "label-value"
    }
    name = "gitlab-runner"
  }
}
resource "kubernetes_service_account_v1" "gitlab-runner-serviceaccount" {
   metadata {
     name = "gitlab-runner"
     namespace = "gitlab-runner"
    }
   depends_on = [kubernetes_namespace.gitlab-runner ]
}
resource "kubernetes_role" "terraform-gitlab-runner-role" {
  metadata {
    name = "terraform-gitlab-runner-role"
    namespace = "gitlab-runner"
  }
  rule {
    api_groups     = [""]
    resources      = ["configmaps", "events", "pods", "pods/attach", "pods/exec", "secrets", "services"]
    verbs          = ["list", "get", "watch", "create", "delete", "update"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods/exec"]
    verbs      = ["get", "list"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods/log"]
    verbs      = ["get", "list"]
  }
  rule {
    api_groups = [""]
    resources  = ["namespaces"]
    verbs      = ["delete", "create"]
  }
  rule {
    api_groups = [""]
    resources  = ["serviceacounts"]
    verbs      = ["get"]
  }
  depends_on = [kubernetes_namespace.gitlab-runner]
}
resource "kubernetes_role_binding" "terraform-gitlab-runner-role-binding" {
  metadata {
    name      = "terraform-gitlab-runner-role-binding"
    namespace = "gitlab-runner"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "terraform-gitlab-runner-role"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "gitlab-runner"
    namespace = "gitlab-runner"
  }
  depends_on =[
    kubernetes_namespace.gitlab-runner ,
    kubernetes_service_account_v1.gitlab-runner-serviceaccount

  ]
}
data "gitlab_group" "pi-lar" {
   full_path = "pi-lar"
}
data "gitlab_project" "neuropil-k8s" {
    path_with_namespace = "pi-lar/neuropil-k8s"
}
resource "gitlab_user_runner" "ldap-dev01-runner" {
  runner_type = "project_type"
  project_id  = 59287439  #setting>general
}
locals {
  config_toml = <<-EOT
concurrent = 1
check_interval = 0
[session_server]
  session_timeout = 1800
[[runners]]
  name = "ldap-dev01-runner"
  url = "https://gitlab.com"
  token = "${gitlab_user_runner.ldap-dev01-runner.token}"
  executor = "docker"
  rbac.serviceAccountName = "gitlab-runner"
  [runners.custom_build_dir]
  [runners.cache]
    [runners.cache.s3]
    [runners.cache.gcs]
    [runners.cache.azure]
  [runners.docker]
    tls_verify = true
    image = "ubuntu"
    privileged = true
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
    volumes = ["/cache", "/certs/client"]
    shm_size = 0
  EOT
}
resource "helm_release" "ldap-dev01-runner" {
  name       = "gitlab-runner"
  repository = "https://charts.gitlab.io"
  chart      = "gitlab-runner"
  namespace =  "gitlab-runner"
  force_update = true
  wait = true
  set{
    name = "gitlabUrl"
    value = "https://gitlab.com/"
  }
  set{
    name = "runnerRegistrationToken"
    value = gitlab_user_runner.ldap-dev01-runner.token
  }
  set {
    name = "config.image"
    value =  "alpine"
  }
  set {
    name = "pull_policy"

    value = "always"
  }
  set {
    name = "config.namespace"
    value = "gitlab-runner"
  }
  set {
    name = "runners.tags"
    value =  "neuropil-k8s" 
  }
}
locals {
  config_toml = <<-EOT
concurrent = 1
check_interval = 0
[session_server]
  session_timeout = 1800
[[runners]]
  name = "ldap-dev01-runner"
  url = "https://gitlab.com"
  token = "${gitlab_user_runner.ldap-dev01-runner.token}"
  executor = "docker"
  rbac.serviceAccountName = "gitlab-runner"
  [runners.custom_build_dir]
  [runners.cache]
    [runners.cache.s3]
    [runners.cache.gcs]
    [runners.cache.azure]
  [runners.docker]
    tls_verify = true
    image = "ubuntu"
    privileged = true
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
    volumes = ["/cache", "/certs/client"]
    shm_size = 0
  EOT
}
resource "helm_release" "ldap-dev01-runner" {
  name       = "gitlab-runner"
  repository = "https://charts.gitlab.io"
  chart      = "gitlab-runner"
  namespace =  "gitlab-runner"
  force_update = true
  wait = true
  set{
    name = "gitlabUrl"
    value = "https://gitlab.com/"
  }
  set{
    name = "runnerRegistrationToken"
    value = gitlab_user_runner.ldap-dev01-runner.token
  }
  set {
    name = "config.image"
    value =  "alpine"
  }
  set {
    name = "pull_policy"

    value = "always"
  }
  set {
    name = "config.namespace"
    value = "gitlab-runner"
  }
  set {
    name = "runners.tags"
    value =  "neuropil-k8s" 
  }
}
