# Appropriately use kernel hardening tools such as AppArmor, seccomp
Documentation available during exam:
* https://kubernetes.io/docs/tutorials/clusters/apparmor/
* https://kubernetes.io/docs/tutorials/clusters/seccomp/

Additional reading:
* https://www.sumologic.com/kubernetes/security/#security-best-practices
* https://cdn2.hubspot.net/hubfs/1665891/Assets/Container%20Security%20by%20Liz%20Rice%20-%20OReilly%20Apr%202020.pdf

# TL;DR

## App Armor
Make sure:

* Kubernetes version is at least v1.4
* AppArmor kernel module is enabled - `cat /sys/module/apparmor/parameters/enabled`
* Profile is loaded - `cat /sys/kernel/security/apparmor/profiles`

AppArmor profiles are specified per-container. To specify the AppArmor profile to run a Pod container with, add an annotation to the Pod's metadata:

```container.apparmor.security.beta.kubernetes.io/<container_name>: <profile_ref>```

Where `<container_name>` is the name of the container to apply the profile to, and `<profile_ref>` specifies the profile to apply. The profile_ref can be one of:
* `runtime/default` to apply the runtime's default profile
* `localhost/<profile_name>` to apply the profile loaded on the host with the name `<profile_name>`
* unconfined to indicate that no profiles will be loaded

To verify that the profile was applied, you can look for the AppArmor security option listed in the container created event:

```
kubectl get events | grep Created
22s        22s         1         hello-apparmor     Pod       spec.containers{hello}   Normal    Created     {kubelet e2e-test-stclair-node-pool-31nt}   Created container with docker id 269a53b202d3; Security:[seccomp=unconfined apparmor=k8s-apparmor-example-deny-write]
```

You can also verify directly that the container's root process is running with the correct profile by checking its proc attr:

```
kubectl exec <pod_name> cat /proc/1/attr/current
k8s-apparmor-example-deny-write (enforce)
```

Kubernetes does not currently provide any native mechanisms for loading AppArmor profiles onto nodes. There are lots of ways to setup the profiles though, such as:
* Through a DaemonSet that runs a Pod on each node to ensure the correct profiles are loaded. An example implementation can be found [here](https://git.k8s.io/kubernetes/test/images/apparmor-loader).
* At node initialization time, using your node initialization scripts (e.g. Salt, Ansible, etc.) or image.
* By copying the profiles to each node and loading them through SSH, as demonstrated in the [Example](https://kubernetes.io/docs/tutorials/clusters/apparmor/#example).

The scheduler is not aware of which profiles are loaded onto which node, so the full set of profiles must be loaded onto every node. An alternative approach is to add a node label for each profile (or class of profiles) on the node, and use a [node selector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/) to ensure the Pod is run on a node with the required profile.

If the PodSecurityPolicy extension is enabled, cluster-wide AppArmor restrictions can be applied. The AppArmor options can be specified as annotations on the PodSecurityPolicy:

```
apparmor.security.beta.kubernetes.io/defaultProfileName: <profile_ref>
apparmor.security.beta.kubernetes.io/allowedProfileNames: <profile_ref>[,others...]
```

The default profile name option specifies the profile to apply to containers by default when none is specified. The allowed profile names option specifies a list of profiles that Pod containers are allowed to be run with. If both options are provided, the default must be allowed. The profiles are specified in the same format as on containers.

Getting AppArmor profiles specified correctly can be a tricky business. Fortunately there are some tools to help with that:
* `aa-genprof` and `aa-logprof` generate profile rules by monitoring an application's activity and logs, and admitting the actions it takes. Further instructions are provided by the [AppArmor documentation](https://gitlab.com/apparmor/apparmor/wikis/Profiling_with_tools).
* [bane](https://github.com/jfrazelle/bane) is an AppArmor profile generator for Docker that uses a simplified profile language.
It is recommended to run your application through Docker on a development workstation to generate the profiles, but there is nothing preventing running the tools on the Kubernetes node where your Pod is running.

To debug problems with AppArmor, you can check the system logs to see what, specifically, was denied. AppArmor logs verbose messages to `dmesg`, and errors can usually be found in the system logs or through `journalctl`. More information is provided in [AppArmor failures](https://gitlab.com/apparmor/apparmor/wikis/AppArmor_Failures).

# Seccomp

Available actions: `["SCMP_ACT_LOG", "SCMP_ACT_ERRNO", "SCMP_ACT_ALLOW"]`

Profiles should be stored under `/var/lib/kubelet/seccomp/profiles`, lab clusters came with few prepared.

To create a pod with seccomp profile, you need to specify `spec.securityContext.seccompProfile.type: Localhost` and `spec.securityContext.seccompProfile.localhostPorfile: profiles/FILE.json` in Pod definition. To use container runtime default seccomp profile, specify `spec.securityContext.seccompProfile.type: RuntimeDefault` instead.

By using audit profile `(profile/audit.json)` and then inspecting `/var/log/syslog | grep syscall` you should be able to identify which syscalls are required for your application to run. Using `profile/violation.json` will most likely not allow you pod to start. `profile/fine-grained` is an example of application specific profile.
