# Network Security Policies

Documentation available during exam:
* https://kubernetes.io/docs/concepts/services-networking/network-policies/
* https://kubernetes.io/docs/tasks/administer-cluster/securing-a-cluster/
* https://kubernetes.io/docs/tasks/administer-cluster/declare-network-policy/
* https://kubernetes.io/blog/2017/10/enforcing-network-policies-in-kubernetes/

## TL;DR

L3 and/or L4 only

Entities that pod can communicate with are identified through combination of:
* Other pods that are allowed (exception: a pod cannot block access to itself)
* Namespaces that are allowed
* IP blocks (exception: traffic to and from the node where a Pod is running is always allowed, regardless of the IP address of the Pod or the node)

When defining a pod or namespace based NetworkPolicy use a selector to specify what traffic is allowed to and from the Pod(s) that match the selector.

When IP based NetworkPolicies are created, we define policies based on IP blocks (CIDR ranges).

Network policies are implemented by the network plugin, to use network policies you must be using a networking solution which supports NetworkPolicy (such as calico or cilium). Creating a NetworkPolicy resource without a controller that implements it will have no effect.

By default, pods are non-isolated; they accept traffic from any source

Pods become isolated by having a NetworkPolicy that selects them. Once there is any NetworkPolicy in a namespace selecting a particular pod, that pod will reject any connections that are not allowed by any NetworkPolicy. (Other pods in the namespace that are not selected by any NetworkPolicy will continue to accept all traffic.)

Network policies do not conflict; they are additive. If any policy or policies select a pod, the pod is restricted to what is allowed by the union of those policies' ingress/egress rules. Thus, order of evaluation does not affect the policy result.

When debuging issues for first time, check if you have whitelisted egress tcp/udp/53 traffic to kube-system/coredns ;)

## Hands On

**Create:**
* two namespaces, `01-01-1` and `01-01-2` with label `ckss=01-01`
* pod named `client` using `alpine:3.12.3` image, labeled with `app=client` in `01-01-1` namespace
* pod named `client` using `alpine:3.12.3` image, labeled with `app=client` in `default` namespace
* pod named `nginx` using `nginx:1.19.6-alpine` image and label it with `app=nginx` in `01-01-2` namespace
* service named `nginx` within `01-01-2` namespace to route incoming traffic on `port 80/TCP` to `nginx` pod on `port 80/TCP`
* networkpolicies in both namespaces to deny all ingress and egress traffic to/from all pods by default
* networkpolicy in `01-01-1` namespace to allow DNS names resolution for all pods
* networkpolicy in `01-01-1` namespace to allow egress traffic to nginx pod from pods labeled as `app=nginx` within `01-01-2` namespace
* networkpolicy in `01-01-2` namespace to allow ingress traffic to nginx pod from pods labeled as `app=client` within `01-01-1` namespace

**Solution:**

`kubectl apply -f manifest.yaml`

**Verify with:**

(1) `kubectl -n 01-01-1 exec client -- wget -qO- --timeout=1 nginx.01-01-2`

(2) `kubectl -n default exec client -- wget -qO- --timeout=1 nginx.01-01-2`

**Expected output from (1):**
```
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

**Expected output from (2):**
```
wget: download timed out
command terminated with exit code 1
```

**Cleanup:**

`kubectl delete -f manifest.yaml --wait=false`
