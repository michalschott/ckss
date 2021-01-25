# Minimize External Access To The Network

Documentation available during exam:
* https://kubernetes.io/docs/concepts/policy/resource-quotas/ - `services`, `services.loadbalancers`, `services.nodeports`
* https://kubernetes.io/docs/concepts/services-networking/service/ - `spec.loadBalancerSourceRanges`
* https://github.com/kubernetes/community/blob/master/contributors/design-proposals/resource-management/admission_control_resource_quota.md

Additional reading:
* https://help.replicated.com/community/t/managing-firewalls-with-ufw-on-kubernetes/230
* https://www.linode.com/docs/security/firewalls/configure-firewall-with-ufw/
* https://docs.microsoft.com/en-us/azure/aks/concepts-security#azure-network-security-groups
* https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html
* https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-security-groups.html
* https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html
* https://gist.github.com/davydany/0ad377f6de3c70056d2bd0f1549e1017

# TL;DR
