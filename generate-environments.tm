# Generate the scrips for environment creation

generate_hcl "_create_environment.tm" {
  condition = tm_contains(terramate.stack.tags, "environment")

  lets {
    namespaces = {
      create_cmd = [
        "minikube", "--profile", global.environments.cluster_name,
        "kubectl", "--", "apply", "-f", "_namespace.yml",
      ]
      check_cmd = [
        "minikube", "--profile", global.environments.cluster_name,
        "kubectl", "--", "get", "namespace", terramate.stack.name,
      ]
      delete_cmd = [
        "minikube", "--profile", global.environments.cluster_name,
        "kubectl", "--", "delete", "namespace", terramate.stack.name,
      ]
    }

    clusters = {
      create_cmd = ["minikube", "start", "--profile", "cluster-${terramate.stack.name}", "--network", "bridge"]
      check_cmd  = ["minikube", "status", "--profile", "cluster-${terramate.stack.name}"]
      delete_cmd = ["minikube", "delete", "--profile", "cluster-${terramate.stack.name}"]
    }
  }
  content {
    tm_dynamic "globals" {
      labels = ["environments", "current"]
      content {
        name = terramate.stack.name
      }
    }
    script "k8s" "create" "environment" {
      name = "create environment as a separate ${global.environments.kind}"

      job {
        name = "create environment"
        command = tm_ternary(global.environments.kind == "namespace",
          let.namespaces.create_cmd,
          let.clusters.create_cmd,
        )
      }

      job {
        name = "check created environment"
        command = tm_ternary(global.environments.kind == "namespace",
          let.namespaces.check_cmd,
          let.clusters.check_cmd,
        )
      }
    }

    script "k8s" "delete" "environment" {
      name = "delete environment"

      job {
        name = "delete environment"
        command = tm_ternary(global.environments.kind == "namespace",
          let.namespaces.delete_cmd,
          let.clusters.delete_cmd,
        )
      }
    }
  }
}

generate_file "_namespace.yml" {
  condition = tm_alltrue([
    tm_contains(terramate.stack.tags, "environment"),
    global.environments.kind == "namespace",
  ])
  content = tm_yamlencode({
    apiVersion = "v1",
    kind       = "Namespace",
    metadata = {
      name = "${terramate.stack.name}"
      labels = {
        is-environment = "true"
      }
    }
  })
}

# This bootstraps the default cluster if the global.environments.kind is set to "namespace"
generate_hcl "_bootstrap.tm" {
  condition = tm_alltrue([
    global.environments.kind == "namespace",
    tm_contains(terramate.stack.tags, "bootstrap"),
  ])

  lets {
    default_cluster_name = tm_try(global.environments.cluster_name, "default")
  }

  content {
    tm_dynamic "globals" {
      condition = !tm_can(global.environments.cluster_name)
      labels    = ["environments"]
      attributes = {
        cluster_name = let.default_cluster_name
      }
    }

    script "k8s" "create" "environment" {
      name = "create default cluster"

      job {
        name    = "create default cluster"
        command = ["minikube", "start", "--profile", let.default_cluster_name, "--network", "bridge"]
      }

      job {
        name    = "check created default cluster"
        command = ["minikube", "status", "--profile", let.default_cluster_name]
      }
    }

    script "k8s" "delete" "environment" {
      name = "delete default cluster"

      job {
        name    = "list all namespaces"
        command = ["bash", "-c", "minikube --profile ${let.default_cluster_name} kubectl -- get namespaces -l is-environment=true -o jsonpath='{.items[*].metadata.name}' > all-namespaces.txt"]
      }

      job {
        name    = "delete default cluster"
        command = ["bash", "-c", "if [ -s all-namespaces.txt ]; then echo 'do nothing, cluster still has env namespaces'; else minikube --profile ${let.default_cluster_name} delete; fi"]
      }
    }
  }
}

assert {
  assertion = global.environments.kind == "namespace" || global.environments.kind == "cluster"
  message   = "The global.environments.kind must be either 'namespace' or 'cluster'"
}