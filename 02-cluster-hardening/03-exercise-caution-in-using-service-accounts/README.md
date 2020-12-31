# Exercise Caution In Using Service Accounts e.g. disable defaults, minimize permissions on newly created ones

Documentation available during exam:
* https://v1-19.docs.kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/
* https://v1-19.docs.kubernetes.io/docs/reference/access-authn-authz/rbac/#default-roles-and-role-bindings
* https://v1-19.docs.kubernetes.io/docs/reference/access-authn-authz/authorization/#authorization-modules
* https://v1-19.docs.kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/
* https://github.com/kubernetes/kubernetes/issues/57601
* https://v1-19.docs.kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#use-the-default-service-account-to-access-the-api-server


Additional reading:
* https://docs.armory.io/docs/armory-admin/manual-service-account/
* https://thenewstack.io/kubernetes-access-control-exploring-service-accounts/
* https://thenewstack.io/a-primer-on-kubernetes-access-control/
* https://thenewstack.io/a-practical-approach-to-understanding-kubernetes-authentication/
* https://stackoverflow.com/questions/52583497/how-to-disable-the-use-of-a-default-service-account-by-a-statefulset-deployments
* https://www.cyberark.com/resources/threat-research-blog/securing-kubernetes-clusters-by-eliminating-risky-permissions
* https://www.youtube.com/watch?v=G3R24JSlGjY


# TL;DR

Kubernetes distinguishes between the concept of a user account and a service account for a number of reasons:

* User accounts are for humans. Service accounts are for processes, which run in pods.
* User accounts are intended to be global. Names must be unique across all namespaces of a cluster. Service accounts are namespaced.
* Typically, a cluster's user accounts might be synced from a corporate database, where new user account creation requires special privileges and is tied to complex business processes. Service account creation is intended to be more lightweight, allowing cluster users to create service accounts for specific tasks by following the principle of least privilege.
* Auditing considerations for humans and service accounts may differ.
* A config bundle for a complex system may include definition of various service accounts for components of that system. Because service accounts can be created without many constraints and have namespaced names, such config is portable.

Three separate components cooperate to implement the automation around service accounts:

* A ServiceAccount admission controller
* A Token controller
* A ServiceAccount controller

A service account provides an identity for processes that run in a Pod.

When you (a human) access the cluster (for example, using kubectl), you are authenticated by the apiserver as a particular User Account (currently this is usually admin, unless your cluster administrator has customized your cluster). Processes in containers inside pods can also contact the apiserver. When they do, they are authenticated as a particular Service Account (for example, default).

When you create a pod, if you do not specify a service account, it is automatically assigned the default service account in the same namespace. If you get the raw json or yaml for a pod you have created (for example, `kubectl get pods/<podname> -o yaml`), you can see the `spec.serviceAccountName` field has been automatically set.

You can access the API from inside a pod using automatically mounted service account credentials, as described in Accessing the Cluster. The API permissions of the service account depend on the authorization plugin and policy in use.

In version 1.6+, you can opt out of automounting API credentials for a service account by setting `automountServiceAccountToken: false` on the service account:

```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: build-robot
automountServiceAccountToken: false
...
```

In version 1.6+, you can also opt out of automounting API credentials for a particular pod:

```
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  serviceAccountName: build-robot
  automountServiceAccountToken: false
  ...
```

The pod spec takes precedence over the service account if both specify a `automountServiceAccountToken` value.
