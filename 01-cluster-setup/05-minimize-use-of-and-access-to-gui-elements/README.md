# Minimize Use Of And Access To GUI Elements

Documentation available during exam:
* https://v1-19.docskubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
* https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/README.md
* https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md

Additional reading:
* https://blog.heptio.com/on-securing-the-kubernetes-dashboard-16b09b1b7aca

# TL;DR

Don't expose services like dashboard to the internet w/o any authentication.

Use rbac to minimize scope.

## Hands On

`kubectl apply -f manifest.yaml`

Givien you have:
* namespace `01-05`
* two jobs (from ingress controller)
* namespace `kube-dashboard`
* dashboard accessible at `http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/` once you run `kubectl proxy`

**Create:**
* `dashboard-read-only-user` serviceAccount in `01-05` namespace
* RBAC roles/clusterroles/rolebindings/clusterrolebindings so `dashboard-read-only-user` can:
  * list and get jobs in `01-05` namespace
  * list cluster `nodes`

**Solution:**

```
kubectl apply -f rbac.yaml
kubectl proxy
```

In other console run:
```
kubectl -n 01-05 describe secret $(kubectl -n 01-05 get secret | grep dashboard-read-only-user-token | awk '{print $1}')
```

Note down token and use to log in to `http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/`.

You should be able to:
* list nodes
* in namespace 01-05 list and get jobs

**Cleanup:**

`kubectl delete -f manifest.yaml -f rbac.yaml --wait=false`
