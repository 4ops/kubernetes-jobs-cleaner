# Jobs cleaner

## Description

Remove all jobs in given namespaces. May be used as Pod/Job/CronJob in cluster or directly from linux console with bash. Required ServiceAccount with namespaces/get and jobs/delete (see RBAC examples). Use environment variables or arguments for configuration.

## Usage

```bash
jobs-cleaner.sh [OPTIONS] namespace1 namespace2 ... namespaceN
```

## Options

`-t|--token [token|file]`

Kubernetes API token or path to file for read from. If no token given, it read from /var/run/secrets/kubernetes.io/serviceaccount/token.

`-s|--server [url]`

URL of Kubernetes API server. Default: <https://kubernetes.default>

`-c|--ca [file]`

Path to kubernetes API certificate authority. Default: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt.

`-d|--dry-run`

Only print job names without removing.

`-v|--verbose`

Show additional information when running. By default only errors are printed.

`-h|--help`

Show script usage

## Environment variables

Variables names optimized for GitLab runner executing in Kubernetes.

`KUBE_TOKEN`

Token string or path to file that contains it.

`KUBE_URL`

URL of Kubernetes API server.

`KUBE_CA`

Path to kubernetes API certificate authority.

`KUBE_NAMESPACE`

List of namespaces.
