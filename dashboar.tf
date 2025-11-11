# If you need to install dashbboard then resource helm_release is applicable

resource "helm_release" "my-kubernetes-dashboard" {

  name = "my-kubernetes-dashboard"
  repository = "https://kubernetes.github.io/dashboard/"
  chart      = "kubernetes-dashboard"
  namespace  = "default"
}

resource "kubernetes_namespace" "neuropil" {
  metadata {
    labels = {
      mylabel = "label-value"
    }

    name = "neuropil"
  }
}


resource "kubernetes_service_account_v1" "localadmin" {
   metadata {
     name = "localadmin"
     namespace = "neuropil"
    }
   depends_on = [kubernetes_namespace.neuropil ]
}

resource "kubernetes_secret" "dashbboard" {
   metadata {
     name = "dashboard-token"
     namespace = "neuropil"
     annotations = {
       "kubernetes.io/service-account.name" = "localadmin"
     }
    }

   type                           = "kubernetes.io/service-account-token"

    depends_on = [
     kubernetes_service_account_v1.localadmin ,
     kubernetes_namespace.neuropil
   ]
}


resource "kubernetes_cluster_role_binding_v1" "localadmin" {
   metadata {
     name = "terraform-cluster"
   }
   role_ref {
     api_group = "rbac.authorization.k8s.io"
     kind      = "ClusterRole"
     name      = "cluster-admin"
   }
   subject {
     kind      = "ServiceAccount"
     name      = "localadmin"
     namespace = "neuropil"
   }
   depends_on = [
     kubernetes_namespace.neuropil,
     kubernetes_service_account_v1.localadmin
   ]
}


output "tokenValue" {
   value = nonsensitive(kubernetes_secret.dashbboard.data.token)
 }

