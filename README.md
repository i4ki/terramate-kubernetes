# Managing Kubernetes clusters with Terramate

Terramate is a tool for managing Terraform, Tofu, Kubernetes or any other kind of IaC (Infrastructure as Code). 
It's agnostic to the underlying infrastructure and can be used to manage resources or clusters on any cloud provider or on-premises.

This repository is an example of how to manage Kubernetes clusters with Terramate. 
It showcases a configurable approach to managing environments in separate Kubernetes clusters or namespaces
by just switching an option in the [global.tm](global.tm) file.

## Getting started

To get started, you need to have Terramate installed on your machine.
Please head over to the [Terramate installation](https://terramate.io/docs/cli/installation) guide to install Terramate.

Once you have Terramate installed, you can clone this repository and run the following commands:

```bash
cd terramate-kubernetes
terramate list --tags environments
```

This will list all the environments that are available in this repository.
Output:
```
environments/dev
environments/prod
environments/staging
```

By default, each environment is a separate Kubernetes cluster. That's controlled by the [global.environments.kind](global.tm) option. If set to `cluster`, each environment is a separate Kubernetes cluster. If set to `namespace`, each environment is a separate namespace in the same Kubernetes cluster.

If you change the `kind` option to `namespace` then you have to also set the `global.environments.cluster_name` option to the name of the Kubernetes cluster where you want to create the namespaces. After changing it, run the `terramate generate` again to apply the filesystem changes.

## Managing environments

There are Terramate scripts to create and destroy environments.
To create all environments, run:

```bash
terramate script run --tags environment -- k8s create environments
```

[![asciicast](https://asciinema.org/a/695111.svg)](https://asciinema.org/a/695111)

To destroy all environments, run:

```bash
terramate script run --tags environment -- k8s delete environments
```

[![asciicast](https://asciinema.org/a/695110.svg)](https://asciinema.org/a/695110)

To create a specific environment, run:

```bash
terramate -C environments/<name> script run --tags environment -- k8s create environments
```

To delete a specific environment, run:

```bash
terramate -C environments/<name> script run --tags environment -- k8s delete environments
```
