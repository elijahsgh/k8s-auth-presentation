# k8s-auth-presentation

More information about the kubernetes auth provider:

https://learn.hashicorp.com/vault/identity-access-management/vault-agent-k8s

- This repository creates a kubernetes cluster in GCP.

- Vault is installed (in demo mode) via the helm chart.

- There is a script in vault/ that configures Kubernetes auth.

- A simple nginx pod is started that you can exec into to experiment.

There is a container that is built with a simple python application to further experiment with but is currently unfinished. :)
