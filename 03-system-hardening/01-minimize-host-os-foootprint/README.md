# Minimize Host OS Footprint

Documentation available during exam:
* https://kubernetes.io/docs/tasks/administer-cluster/securing-a-cluster/#preventing-containers-from-loading-unwanted-kernel-modules


Additional reading:
* https://blog.sonatype.com/kubesecops-kubernetes-security-practices-you-should-follow#:~:text=Reduce%20Kubernetes%20Attack%20Surfaces
* https://www.cisecurity.org/benchmark/distribution_independent_linux/
* https://www.cisecurity.org/benchmark/ubuntu_linux/
* https://www.cisecurity.org/benchmark/red_hat_linux/
* https://www.cisecurity.org/benchmark/debian_linux/
* https://www.cisecurity.org/benchmark/centos_linux/
* https://www.cisecurity.org/benchmark/suse_linux/
* https://www.cisecurity.org/benchmark/oracle_linux/


# TL;DR

To prevent specific modules from being automatically loaded, you can uninstall them from the node, or add rules to block them. On most Linux distributions, you can do that by creating a file such as /etc/modprobe.d/kubernetes-blacklist.conf with contents like:

```
# DCCP is unlikely to be needed, has had multiple serious
# vulnerabilities, and is not well-maintained.
blacklist dccp

# SCTP is not used in most Kubernetes clusters, and has also had
# vulnerabilities in the past.
blacklist sctp
```

To block module loading more generically, you can use a Linux Security Module (such as SELinux) to completely deny the module_request permission to containers, preventing the kernel from loading modules for containers under any circumstances. (Pods would still be able to use modules that had been loaded manually, or modules that were loaded by the kernel on behalf of some more-privileged process.)
