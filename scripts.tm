script "k8s" "deploy" {
  name = "deploy resources"

  lets {
    cluster_name = tm_ternary(
      global.environments.kind == "namespace",
      global.environments.cluster_name,
      "cluster-${global.environments.current.name}",
    )
    cmd = tm_concat(
      ["minikube", "--profile", let.cluster_name],
      ["kubectl", "--", "apply", "-f", "./"],
      tm_ternary(
        global.environments.kind == "namespace",
        ["--namespace", global.environments.current.name],
        [],
      ),
    )
  }

  job {
    name    = "deploy resources"
    command = let.cmd
  }
}

script "k8s" "destroy" {
  name = "destroy resources"

  lets {
    cluster_name = tm_ternary(
      global.environments.kind == "namespace",
      global.environments.cluster_name,
      "cluster-${global.environments.current.name}",
    )
    cmd = tm_concat(
      ["minikube", "--profile", let.cluster_name],
      ["kubectl", "--", "delete", "-f", "./"],
      tm_ternary(
        global.environments.kind == "namespace",
        ["--namespace", global.environments.current.name],
        [],
      ),
    )
  }
  job {
    name    = "destroy resources"
    command = let.cmd
  }
}
