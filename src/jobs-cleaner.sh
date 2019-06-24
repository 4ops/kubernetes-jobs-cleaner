#!/usr/bin/env bash

SADIR=/var/run/secrets/kubernetes.io/serviceaccount
DEFAULT_KUBE_URL=https://kubernetes.default

KUBE_URL=${KUBE_URL:-$DEFAULT_KUBE_URL}
KUBE_CA=${KUBE_CA:-$SADIR/ca.crt}
KUBE_TOKEN=${KUBE_TOKEN:-$SADIR/token}
KUBE_NAMESPACE=${KUBE_NAMESPACE}

VERBOSE=
DRY=
USAGE=

cleanjobs() {
  local ctlcmd="kubectl --server=${KUBE_URL} --certificate-authority=${KUBE_CA} --token=${KUBE_TOKEN}"
  comment "Job started"

  for namespace in "${KUBE_NAMESPACE}"
  do
    comment "Get jobs in namespace $namespace..."
    $ctlcmd --namespace $namespace auth can-i get jobs &> /dev/null || error "List jobs in namespace $namespace with kubectl failed"
    jobs=$($ctlcmd --namespace $namespace get jobs --output=custom-columns=NAME:.metadata.name --no-headers)
    comment "Jobs to delete: ${jobs}"
    [[ "$DRY" == "YES" ]] && comment "Check role can delete jobs: $($ctlcmd --namespace $namespace auth can-i delete jobs)"
    [[ "$DRY" == "YES" ]] || $ctlcmd --namespace $namespace delete jobs --all --ignore-not-found || error "Kubectl exited with error when trying to delete jobs"
  done
}

checkargs() {
  [[ -z "${KUBE_NAMESPACE}" ]] && error "No namespaces are given"
  [[ -z "${KUBE_URL}" ]] && error "Kubernetes API server URL has no value"
  [[ -z "${KUBE_CA}" ]] && error "Kubernetes API server certificate authority has no value"
  [[ -z "${KUBE_TOKEN}" ]] && error "Kubernetes API token has no value or token file not readable"
  return 0
}

comment() {
  [[ "$VERBOSE" == "YES" ]] && echo "$1"
}

error() {
  echo "$1"
  exit 42
}

usage() {
  local HS="\n\033[1;37m"
  local HE="\033[0m\n"

  echo -e "${HS}DESCRIPTION${HE}"
  echo -e "Remove all jobs in given namespaces."
  echo -e "${HS}USAGE${HE}"
  echo -e "$(basename $0) [OPTIONS] namespace1 namespace2 ... namespaceN"
  echo -e "${HS}OPTIONS:${HE}"
  echo -e "-t|--token [token|file]    Kubernetes API token or path to file for read from. If no token given, it read from ${SADIR}/token."
  echo -e "-s|--server [url]          URL of Kubernetes API server. Default: ${DEFAULT_KUBE_URL}."
  echo -e "-c|--ca [file]             Path to kubernetes API certificate authority. Default: ${SADIR}/ca.crt."
  echo -e "-d|--dry-run               Only print job names without removing."
  echo -e "-v|--verbose               Show additional information when running. By default only errors are printed."
  echo -e "-h|--help                  Show this help."
  echo -e "${HS}ENVIRONMENT VARIABLES:${HE}"
  echo -e "KUBE_TOKEN                 Token string or path to file that contains it."
  echo -e "KUBE_URL                   URL of Kubernetes API server."
  echo -e "KUBE_CA                    Path to kubernetes API certificate authority."
  echo -e "KUBE_NAMESPACE             List of namespaces."
  echo
}

values() {
  echo -e "KUBE_URL=${KUBE_URL}"
  echo -e "KUBE_CA=${KUBE_CA}"
  echo -e "KUBE_TOKEN=${#KUBE_TOKEN} chars"
  echo -e "KUBE_NAMESPACE=${KUBE_NAMESPACE}"
  echo -e "VERBOSE=${VERBOSE}"
  echo -e "DRY=${DRY}"
}

while (( "$#" )); do
  case "$1" in
    -t|--token)
      KUBE_TOKEN="$2"
      shift 2
    ;;
    -s|--server)
      KUBE_URL="$2"
      shift 2
    ;;
    -c|--ca)
      KUBE_CA="$2"
      shift 2
    ;;
    -d|--dry-run)
      DRY=YES
      shift
    ;;
      -v|--verbose)
      VERBOSE=YES
      shift
    ;;
    -h|--help)
      USAGE=YES
      shift
    ;;
    *)
      KUBE_NAMESPACE="$KUBE_NAMESPACE $1"
      shift
    ;;
esac
done

eval set -- "${KUBE_NAMESPACE}"

KUBE_NAMESPACE=$(echo $KUBE_NAMESPACE | xargs)
test -r $KUBE_TOKEN && KUBE_TOKEN=$(cat $KUBE_TOKEN)

[[ "$USAGE" == "YES" ]] && usage && exit 0
[[ "$VERBOSE" == "YES" ]] && values

checkargs && cleanjobs
