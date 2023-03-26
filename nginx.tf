#-------------------------------------(Select Kubernetes Provider Version)
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
  }
}
#---------------------------------------(Create kubernetes Provider)
provider "kubernetes" {
  config_path = "~/.kube/config"
}
#----------------------------------------(Create "nginx-ns" Namespace)
resource "kubernetes_namespace" "nginx-ns" {
  metadata {
    name = "nginx"
  }
}
#-----------------------------------------(Create "nginx-dep" Deployment)
resource "kubernetes_deployment" "nginx-dep" {
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.nginx-ns.metadata.0.name
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "nginx-dep-label"
      }
    }
    template {
      metadata {
        labels = {
          app = "nginx-dep-label"
        }
      }
      spec {
        container {
          image = "<Registry Name>/nginx"
          name  = "nginx-container"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}
resource "kubernetes_service" "nginx-srv" {
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.nginx-ns.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.nginx-dep.spec.0.template.0.metadata.0.labels.app
    }
    type = "NodePort"
    port {
      node_port   = 30201
      port        = 80
      target_port = 80
    }
  }
}
