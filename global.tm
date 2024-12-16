# Global configuration
# The configurations defined here apply to all stacks.

# 
globals "environments" {
  # The kind of environment to create. It can be either "namespace" or "cluster"
  kind = "cluster"

  # The default cluster name to use when kind=namespace
  cluster_name = "default"
}
