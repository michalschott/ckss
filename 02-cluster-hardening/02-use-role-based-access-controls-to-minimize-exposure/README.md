# Use Role Based Access Controls to minimize exposure

Documentation available during exam:
* https://kubernetes.io/docs/reference/access-authn-authz/rbac/
* https://kubernetes.io/docs/reference/access-authn-authz/authorization/#authorization-modules

Additional reading:
* https://rbac.dev/
* https://www.youtube.com/watch?v=G3R24JSlGjY
* https://github.com/David-VTUK/CKA-StudyGuide/blob/master/RevisionTopics/Part-5-Security.md

# TL;DR

4 total authorization modes: `Node`, `ABAC`, `RBAC`, `Webhook`.

Role-based access control (RBAC) is a method of regulating access to computer or network resources based on the roles of individual users within your organization. RBAC authorization uses the `rbac.authorization.k8s.io` API group to drive authorization decisions, allowing you to dynamically configure policies through the Kubernetes API. To enable RBAC, start the API server with the `--authorization-mode` flag set to a comma-separated list that includes RBAC; for example:

`kube-apiserver --authorization-mode=Example,RBAC --other-options --more-options`

An RBAC Role or ClusterRole contains rules that represent a set of permissions. Permissions are purely additive (there are no "deny" rules).

A Role always sets permissions within a particular namespace; when you create a Role, you have to specify the namespace it belongs in.

ClusterRole, by contrast, is a non-namespaced resource. The resources have different names (Role and ClusterRole) because a Kubernetes object always has to be either namespaced or not namespaced; it can't be both.

ClusterRoles have several uses. You can use a ClusterRole to:

define permissions on namespaced resources and be granted within individual namespace(s)
define permissions on namespaced resources and be granted across all namespaces
define permissions on cluster-scoped resources
If you want to define a role within a namespace, use a Role; if you want to define a role cluster-wide, use a ClusterRole.

A role binding grants the permissions defined in a role to a user or set of users. It holds a list of subjects (users, groups, or service accounts), and a reference to the role being granted. A RoleBinding grants permissions within a specific namespace whereas a ClusterRoleBinding grants that access cluster-wide.

A RoleBinding may reference any Role in the same namespace. Alternatively, a RoleBinding can reference a ClusterRole and bind that ClusterRole to the namespace of the RoleBinding. If you want to bind a ClusterRole to all the namespaces in your cluster, you use a ClusterRoleBinding.

You can aggregate several ClusterRoles into one combined ClusterRole. A controller, running as part of the cluster control plane, watches for ClusterRole objects with an aggregationRule set. The aggregationRule defines a label selector that the controller uses to match other ClusterRole objects that should be combined into the rules field of this one. If you create a new ClusterRole that matches the label selector of an existing aggregated ClusterRole, that change triggers adding the new rules into the aggregated ClusterRole.

The default user-facing roles use ClusterRole aggregation. This lets you, as a cluster administrator, include rules for custom resources, such as those served by CustomResourceDefinitions or aggregated API servers, to extend the default roles.

A RoleBinding or ClusterRoleBinding binds a role to subjects. Subjects can be groups, users or ServiceAccounts.

Kubernetes represents usernames as strings. These can be: plain names, such as "alice"; email-style names, like "bob@example.com"; or numeric user IDs represented as a string. It is up to you as a cluster administrator to configure the authentication modules so that authentication produces usernames in the format you want.

Caution: The prefix system: is reserved for Kubernetes system use, so you should ensure that you don't have users or groups with names that start with system: by accident. Other than this special prefix, the RBAC authorization system does not require any format for usernames.
In Kubernetes, Authenticator modules provide group information. Groups, like users, are represented as strings, and that string has no format requirements, other than that the prefix system: is reserved.

ServiceAccounts have names prefixed with system:serviceaccount:, and belong to groups that have names prefixed with system:serviceaccounts:.

Note:
system:serviceaccount: (singular) is the prefix for service account usernames.
system:serviceaccounts: (plural) is the prefix for service account groups.

API servers create a set of default ClusterRole and ClusterRoleBinding objects. Many of these are system: prefixed, which indicates that the resource is directly managed by the cluster control plane. All of the default ClusterRoles and ClusterRoleBindings are labeled with kubernetes.io/bootstrapping=rbac-defaults.

At each start-up, the API server updates default cluster roles with any missing permissions, and updates default cluster role bindings with any missing subjects. This allows the cluster to repair accidental modifications, and helps to keep roles and role bindings up-to-date as permissions and subjects change in new Kubernetes releases.

To opt out of this reconciliation, set the rbac.authorization.kubernetes.io/autoupdate annotation on a default cluster role or rolebinding to false. Be aware that missing default permissions and subjects can result in non-functional clusters.

Auto-reconciliation is enabled by default if the RBAC authorizer is active.

The RBAC API prevents users from escalating privileges by editing roles or role bindings. Because this is enforced at the API level, it applies even when the RBAC authorizer is not in use.

Quickly check your permissions with `kubectl auth can-i` ie. `kubectl auth can-i create deployments --namespace dev` or `kubectl auth can-i create deployments --namespace prod`. Administrators can combine this with user impersonation, ie. `kubectl auth can-i list secrets --namespace dev --as dave`.
