// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

globals "environments" "current" {
  name = "dev"
}
script "k8s" "create" "environment" {
  name = "create environment as a separate cluster"
  job {
    command = [
      "minikube",
      "start",
      "--profile",
      "cluster-dev",
      "--network",
      "bridge",
    ]
    name = "create environment"
  }
  job {
    command = [
      "minikube",
      "status",
      "--profile",
      "cluster-dev",
    ]
    name = "check created environment"
  }
}
script "k8s" "delete" "environment" {
  name = "delete environment"
  job {
    command = [
      "minikube",
      "delete",
      "--profile",
      "cluster-dev",
    ]
    name = "delete environment"
  }
}
