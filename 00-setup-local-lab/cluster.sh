#!/usr/bin/env sh

set -e

etc_hosts_add() {
  grep ckss.local /etc/hosts | grep "127.0.0.1" > /dev/null || ( \
      echo "Need to update /etc/hosts with 127.0.0.1 ckss.local entry, you might be asked for sudo password"; \
      echo "127.0.0.1 ckss.local" | sudo tee -a /etc/hosts > /dev/null \
  )
}

etc_hosts_delete() {
  echo "Need to remove 127.0.0.1 ckss.local entry from /etc/hosts, you might be asked for sudo password"
  if [[ $(uname) == "Darwin" ]]; then
    # fallback to linux sed if gnu-sed is used
    sudo sed -i '' '/127.0.0.1 ckss.local/d' /etc/hosts 2>/dev/null || sudo sed -i '/127.0.0.1 ckss.local/d' /etc/hosts
  else
    sudo sed -i '/127.0.0.1 ckss.local/d' /etc/hosts
  fi
}

case $1 in
  "create")
    ls kind-ckss.yaml >/dev/null 2>&1 || ( \
      echo "Ensure to run this script from 00-setup-local-lab directory"; \
      exit 1;
    )
    kind create cluster --config ./kind-ckss.yaml
    kubectl label node ckss-worker ingress-ready=true
    kubectl apply -f https://docs.projectcalico.org/v3.17/manifests/calico.yaml
    etc_hosts_add
    ;;
  "delete")
    etc_hosts_delete
    kind delete cluster --name ckss
    ;;
  *)
    echo "Usage:\n  $0 create\n  $0 delete"
    ;;
esac
