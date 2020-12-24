# 00-setup-local-lab

[Original source](https://alexbrand.dev/post/creating-a-kind-cluster-with-calico-networking/)

Kind is a tool for running Kubernetes inside docker containers. Instead of using VMs or physical hosts as the Kubernetes nodes, Kind spins up docker containers that look like VMs and installs Kubernetes on them. Getting a cluster up and running with Kind is super fast, which makes it an excellent tool for creating test clusters on your laptop.

Kind has a default Container Networking Interface (CNI) plugin called kindnet, which is a minimal implementation of a CNI plugin.

To use Calico as the CNI plugin in Kind clusters, we need to do the following:

* Disable the installation of kindnet
* Configure the pod subnet of the cluster
* Install Calico on the cluster
