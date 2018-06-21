#Glossar

* Calico https://www.projectcalico.org/
* CNI Container Network Interface
* etcd Distributed reliable key-value store for the most critical data of a distributed system
* [kube-apiserver][0]: Component on the master that exposes the Kubernetes API
* kube-scheduler: Component on the master that watches newly created pods, selects node to run on
* kube-controller-manager: Component on the master that runs controllers
* kubelet: An agent that runs on each node in the cluster. It makes sure that containers are running in a pod
* kube-proxy: enables the Kubernetes service abstraction by maintaining network rules on the host and performing connection forwarding.

# containerd

see https://blog.docker.com/2017/08/what-is-containerd-runtime/

![containerdoverview](https://i0.wp.com/blog.docker.com/wp-content/uploads/974cd631-b57e-470e-a944-78530aaa1a23-1.jpg?w=906&ssl=1)

https://kubernetes.io/blog/2018/05/24/kubernetes-containerd-integration-goes-ga/

# Networking

https://prefetch.net/blog/2018/01/20/generating-kubernetes-pod-cidr-routes-with-ansible/

### CNI - Container Network Intercafe

"CNI (Container Network Interface), a Cloud Native Computing Foundation project, consists of a specification and libraries for writing plugins to configure network interfaces in Linux containers, along with a number of supported plugins."

https://github.com/containernetworking/cni

### Flannel

"flannel is a virtual network that attaches IP addresses to containers" 

https://coreos.com/flannel/docs/latest/kubernetes.html


"The network in the flannel configuration should match the pod network CIDR."

flannel will be deployed to worker: " deploy the flannel pod on each Node"

##### Flannel with Kubernetes on Vagrant

Trouble: https://github.com/coreos/flannel/blob/master/Documentation/troubleshooting.md#vagrant

Solution: https://stackoverflow.com/a/48755233/4964553


[0]: https://kubernetes.io/docs/concepts/overview/components/