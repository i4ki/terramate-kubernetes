// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

globals "environments" "current" {
  name = "staging"
}
script "k8s" "create" "environment" {
  name = "create environment as a separate cluster"
  job {
    command = [
      "minikube",
      "start",
      "--profile",
      "cluster-staging",
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
      "cluster-staging",
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
      "cluster-staging",
    ]
    name = "delete environment"
  }
}
