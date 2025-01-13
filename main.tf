# build dotnet app 
resource "docker_image" "dotnet_app" {
  name = "my-dotnet-app:latest"
  build {
    context = "./MyDotNetApp"
  }
  force_remove = true
}
# create namespace
resource "kubernetes_namespace" "terraform" {
  metadata {
    name = "terraform-namespace"
  }
}

# Deployment in an existing namespace
resource "kubernetes_deployment" "dotnet_app" {
  metadata {
    name      = "dotnet-app"
    namespace = "terraform-namespace"
    labels = {
      app = "dotnet-app"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "dotnet-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "dotnet-app"
        }
      }

      spec {
        container {
          name              = "dotnet-app"
          image             = "my-dotnet-app:latest"
          image_pull_policy = "Never"
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

# Service in an existing namespace
resource "kubernetes_service" "dotnet_service" {
  metadata {
    name      = "dotnet-service"
    namespace = "terraform-namespace" # Replace with your namespace name
  }

  spec {
    selector = {
      app = "dotnet-app"
    }

    port {
      port        = 80
      target_port = 8080
    }

    type = "NodePort" # Use NodePort for local clusters
  }
}

output "dotnet_service_swagger" {
  value       = "http://localhost:${kubernetes_service.dotnet_service.spec[0].port[0].node_port}/swagger/index.html"
  description = "The NodePort for the dotnet service"
}