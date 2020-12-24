#!/usr/bin/env sh

set -e

case $1 in
  "create")
    kind create cluster --config $(dirname $0)/kind-calico.yaml
    kubectl apply -f https://docs.projectcalico.org/v3.17/manifests/calico.yaml
    ;;
  "delete")
    kind delete cluster --name ckss
    ;;
  *)
    echo "Usage:\n  $0 create\n  $0 delete"
    ;;
esac
