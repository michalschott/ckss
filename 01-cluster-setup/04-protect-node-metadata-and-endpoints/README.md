# Protect Node Metadata And Endpoints

Documentation available during exam:
* https://v1-19.docs.kubernetes.io/docs/tasks/administer-cluster/securing-a-cluster/#restricting-cloud-metadata-api-access
* https://v1-19.docs.kubernetes.io/docs/reference/command-line-tools-reference/kubelet-authentication-authorization/
* https://v1-19.docs.kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/

Additional documentation:
* https://cloud.google.com/kubernetes-engine/docs/how-to/protecting-cluster-metadata#concealment
* https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity
* https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instancedata-data-retrieval.html#instance-metadata-limiting-access
* https://docs.aws.amazon.com/eks/latest/userguide/best-practices-security.html#restrict-ec2-credential-access
* https://github.com/uswitch/kiam
* https://github.com/jtblin/kube2iam

# TL;DR

Cloud platforms (AWS, Azure, GCE, etc.) often expose metadata services locally to instances. By default these APIs are accessible by pods running on an instance and can contain cloud credentials for that node, or provisioning data such as kubelet credentials. These credentials can be used to escalate within the cluster or to other cloud services under the same account.

When running Kubernetes on a cloud platform limit permissions given to instance credentials, use network policies to restrict pod access to the metadata API, and avoid using provisioning data to deliver secrets.

You can use Kubernetes network policy to restrict pods access to cloud metadata altho keep in mind this resource is namespaced. Below example assumes AWS cloud, and metadata IP address at 169.254.169.254 should be blocked while all other external addresses are not:

```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-cloud-metadata-access
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  - to:
    - ipBlock:
      cidr: 0.0.0.0/0
      except:
      - 169.254.169.254/32
```

A kubelet's HTTPS endpoint exposes APIs which give access to data of varying sensitivity, and allow you to perform operations with varying levels of power on the node and within containers.

By default, requests to the kubelet's HTTPS endpoint that are not rejected by other configured authentication methods are treated as anonymous requests, and given a username of system:anonymous and a group of system:unauthenticated.

Any request that is successfully authenticated (including an anonymous request) is then authorized. The default authorization mode is AlwaysAllow, which allows all requests.
