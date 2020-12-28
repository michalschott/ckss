# Use CIS benchmark to review the security configuration of Kubernetes components (etcd, kubelet, kubedns, kubeapi)

Documentation:
* https://www.cisecurity.org/benchmark/kubernetes/
* https://github.com/aquasecurity/kube-bench
* https://cloud.google.com/kubernetes-engine/docs/concepts/cis-benchmarks

## TL;DR

CIS for kubernetes 1.19 is not released yet, altho this is good indicator for your security controls.

CIS comes with two recommendation levels. In most cases following L1 guides should be sufficient. L2 extends L1 and it is targeting environments where security is paramount. Keep it mind that L2 may negatively inhibit the utility or performance of the technology.

While using managed services (GKE, AKS, EKS) you share security responsibility with your service provider and you won't be able to reconfigure masterplance services (etcd, kubeapi etc), more over you most likely won't be able to check their configurations. For instance check out [GKE guide](https://cloud.google.com/kubernetes-engine/docs/concepts/cis-benchmarks).

And the most important thing - **it covers kubernetes cluster components configration ONLY and not your running workflows**

## Hands On

**Run:**
* and review CIS benchmark on Kind cluster master node
* and review CIS benchmark on Kind cluster worker node

**Solution:**

`kubectl apply -f manifest.yaml`

**Verify with:**
```
kubectl -n 01-02 logs $(kubectl get pod -n 01-02 -l app=kube-bench,node=master -o jsonpath='{.items[0].metadata.name}')
kubectl -n 01-02 logs $(kubectl get pod -n 01-02 -l app=kube-bench,node=worker -o jsonpath='{.items[0].metadata.name}')
```

**Cleanup:**

`kubectl delete -f manifest.yaml --wait=false`
