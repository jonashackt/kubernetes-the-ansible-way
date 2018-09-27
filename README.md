# kubernetes-the-ansible-way
[![Build Status](https://travis-ci.org/jonashackt/kubernetes-the-ansible-way.svg?branch=master)](https://travis-ci.org/jonashackt/kubernetes-the-ansible-way)
[![License](http://img.shields.io/:license-mit-blue.svg)](https://github.com/jonashackt/kubernetes-the-ansible-way/blob/master/LICENSE)
[![versionkubernetes](https://img.shields.io/badge/kubernetes-v1.10.2-brightgreen.svg)]()
[![versionkubernetes](https://img.shields.io/badge/etcd-v3.3.5-brightgreen.svg)]()
[![versionkubernetes](https://img.shields.io/badge/docker-18.06.1-brightgreen.svg)]()
[![versionkubernetes](https://img.shields.io/badge/flannel-v0.10.0-brightgreen.svg)]()
[![versionkubernetes](https://img.shields.io/badge/ansible-2.6.4-orange.svg)]()
[![versionkubernetes](https://img.shields.io/badge/vagrant-2.1.0-orange.svg)]()

> There are currently problems with newer Vagrant versions than 2.1.0!

Bootstrap Kubernetes the Ansible way on Everything (here: Vagrant). Inspired by [Kelsey Hightower´s kubernetes-the-hard-way](https://github.com/kelseyhightower/kubernetes-the-hard-way), but refactored to Infrastructure-as-Code. 

But we wanted to focus on different aspects:

* __No__ Google Cloud Platform fixation - open for many infrastructures
* Implement the concept of __[Infrastructure-as-Code](https://en.wikipedia.org/wiki/Infrastructure_as_Code)__, so that... 
* ...all the moving parts of Kubernetes will be __much more controllable & manageable__ 
* and the whole setup will be much more comprehensible
* A more modular setup, where things that relate to one topic (e.g. the Kubernetes master nodes), will be handled where they belong to

The origin of this repository was set by a team of [Johannes Barop](https://github.com/jbarop), [Frank Stibane](https://github.com/f-stibane), [Jan Müller](https://github.com/devpie), [Akhlaq Malik](https://github.com/imalik8088) & [Jonas Hecht](https://github.com/jonashackt) on a Kubernetes workshop in the [codecentric](https://github.com/codecentric)  Finca Mallorca in June 2018.


## Prerequisites

Install [Ansible](https://www.ansible.com/), [Vagrant](https://www.vagrantup.com/) and the following Plugins:
 
* [vagrant-dns](https://github.com/BerlinVagrant/vagrant-dns)
* [vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest)

And then run `vagrant dns --install`. Check, if the domain `.k8s` was registered correctly with:

```
scutil --dns
```

__Alternatively__, use the following scripts depending on your Host´s platform:


```bash
bash prepare.mac.bash
#or
bash prepare.arch.bash
```

Then do the usual:

```bash
vagrant up
```

And check, if you can reach a node:

```
dscacheutil -q host -a name master-0.k8s
```

This setup heavily relies on the Vagrant DNS plugin: https://github.com/BerlinVagrant/vagrant-dns

##### Vagrant DNS howitworks: TODO

# Glossar

![k8s-big-picture](https://res.cloudinary.com/dukp6c7f7/image/upload/f_auto,fl_lossy,q_auto/s3-ghost/2016/06/o7leok.png)

Good introduction: https://www.baeldung.com/kubernetes (german)

* Calico https://www.projectcalico.org/
* CNI Container Network Interface
* etcd Distributed reliable key-value store for the most critical data of a distributed system
* [kube-apiserver][https://kubernetes.io/docs/concepts/overview/components/]: Component on the master that exposes the Kubernetes API
* kube-scheduler: Component on the master that watches newly created pods, selects node to run on
* kube-controller-manager: Component on the master that runs controllers
* kubelet: An agent that runs on each node in the cluster. It makes sure that containers are running in a pod
* kube-proxy: enables the Kubernetes service abstraction by maintaining network rules on the host and performing connection forwarding.

# containerd

see https://blog.docker.com/2017/08/what-is-containerd-runtime/

![containerdoverview](https://i0.wp.com/blog.docker.com/wp-content/uploads/974cd631-b57e-470e-a944-78530aaa1a23-1.jpg?w=906&ssl=1)

https://kubernetes.io/blog/2018/05/24/kubernetes-containerd-integration-goes-ga/


# Creating a K8s cluster from scratch

What we´re actually doing here is to create a K8s cluster from scratch: https://kubernetes.io/docs/setup/scratch/ 

> Nodes: "Many Getting-started-guides make a distinction between the master node and regular nodes. This is not strictly necessary."

> Allocate one CIDR subnet for each node’s PodIPs, or a single large CIDR from which smaller CIDRs are automatically allocated to each node. 

# Networking

https://prefetch.net/blog/2018/01/20/generating-kubernetes-pod-cidr-routes-with-ansible/

## CNI - Container Network Intercafe

"CNI (Container Network Interface), a Cloud Native Computing Foundation project, consists of a specification and libraries for writing plugins to configure network interfaces in Linux containers, along with a number of supported plugins."

https://github.com/containernetworking/cni

Which CNI-Provider to choose:

https://chrislovecnm.com/kubernetes/cni/choosing-a-cni-provider/

## Flannel

"flannel is a virtual network that attaches IP addresses to containers" 

https://coreos.com/flannel/docs/latest/kubernetes.html


"The network in the flannel configuration should match the pod network CIDR."

flannel will be deployed to worker: " deploy the flannel pod on each Node"

### Flannel with Kubernetes on Vagrant

Trouble: https://github.com/coreos/flannel/blob/master/Documentation/troubleshooting.md#vagrant

> Vagrant typically assigns two interfaces to all VMs. The first, for which all hosts are assigned the IP address 10.0.2.15, is for external traffic that gets NATed.
  
  This may lead to problems with flannel. By default, flannel selects the first interface on a host. This leads to all hosts thinking they have the same public IP address. To prevent this issue, pass the --iface eth1 flag to flannel so that the second interface is chosen.

Solution: https://stackoverflow.com/a/48755233/4964553, add the following line:

```
  - --iface=enp0s8
```

in https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

### Flannel with Docker

Docs: https://github.com/coreos/flannel/blob/master/Documentation/running.md

Great Blog: https://icicimov.github.io/blog/kubernetes/Kubernetes-cluster-step-by-step-Part4/

This is a good overview (from https://blog.laputa.io/kubernetes-flannel-networking-6a1cb1f8ec7c):

![network_overview](https://cdn-images-1.medium.com/max/1600/1*EFr8ohzABfStS7o9gGMYKw.png)

To achieve this, we need to install flanneld and then set the following inside the `docker.service.j2`:

```
EnvironmentFile=/run/flannel/subnet.env
ExecStart=/usr/bin/dockerd \
    --bip=${FLANNEL_SUBNET} \
    --mtu=${FLANNEL_MTU} \
    --iptables=false \
    --ip-masq=false \
    --ip-forward=true \
    -H fd://
```
See the following links: 

* https://kubernetes.io/docs/setup/scratch/#docker
* https://docs.docker.com/install/linux/linux-postinstall/#configuring-remote-access-with-systemd-unit-file
* https://coreos.com/flannel/docs/latest/flannel-config.html
* https://icicimov.github.io/blog/kubernetes/Kubernetes-cluster-step-by-step-Part4/


### Flannel also needs to run on the Master nodes!

__This one took me ages to understand...__ If you´re new to a technology and want to learn it, the hardest part always is to ask the right questions. 

It all started out with the need to access the Kubernetes Dashboard, which was the first "real" application, we deployed to our cluster. This didn´t work for several reasons:

https://github.com/jonashackt/kubernetes-the-ansible-way/issues/10

The journey started with that kind of error:

```
Error: 'dial tcp 10.200.27.2:8443: getsockopt: connection timed out'
Trying to reach: 'http://10.200.27.2:8443/'
``` 

After lot´s of reading and debuging, [it became clear that](https://github.com/kubernetes/dashboard/issues/2855#issuecomment-367697539):

> This kind of errors always come from API server, not the application you are trying to reach. Check your cluster config and see if you can access other applications through service proxy first.

__The first problem to solve [was a known Ubuntu bug](https://github.com/jonashackt/kubernetes-the-ansible-way/commit/3091bbe9751674d54500e62d089479dc8c8266f2)__, which then made cluster internal routing from k8s Services to Pods reliable.

The next step was to use the [Kubernetes cluster´s corresponding version of Dashboard](https://github.com/jonashackt/kubernetes-the-ansible-way/commit/9866c71c3d09240f6aa0313ed45adc32285da529)


Finally it became clear, that __absolutely NO app was reachable from outside the cluster correctly__: https://github.com/jonashackt/kubernetes-the-ansible-way/issues/12

The [Kubernetes Debug Guides](https://kubernetes.io/docs/tasks/debug-application-cluster/debug-service) were of great help!

__An interlude__ was to learn how to do a correct `curl` to a Kubernetes cluster, which __is NOT__ to `curl https://localhost:8080/api/v1/namespaces/default/services/http:hostnames:80/proxy/ -v` Alongside the unnecessary `http:` (we only need to set that when `https:` is needed), the correct `cacert` was missing.


Then again after more and more reading and tinkering, the first good looking idea came to my mind: https://github.com/jonashackt/kubernetes-the-ansible-way/issues/12#issuecomment-418136488. [jeroenjacobs1205](https://github.com/jeroenjacobs1205) helped me a lot [with his comment](https://github.com/kubernetes/dashboard/issues/2340#issuecomment-328765833) as I started to question the network design of our `kubernetes-the-ansible-way` cluster... The process of thinking took a while, even if I moved steps forward!

After another interlude of [using the correct cluster-name](https://github.com/jonashackt/kubernetes-the-ansible-way/commit/cbe34d009bddb54d8b770f135222184a65ead78c) when configuring `kubectl` to access the k8s cluster, this __finally (again)__ lead me to the point, where the [first way of accessing services in the cluster](https://kubernetes.io/docs/tasks/administer-cluster/access-cluster-services/#ways-to-connect) finally worked reliable for me ("Access services through public IPs" __directly on the worker nodes__).  

But that wasn´t all for me. I wanted to access my applications also __through the Proxy Verb__ aka `kube-apiserver` ([the second way in the docs](https://kubernetes.io/docs/tasks/administer-cluster/access-cluster-services/#ways-to-connect)).

As I said, I was not convinced of the general cluster design of [kubernetes-the-hard-way](https://github.com/kelseyhightower/kubernetes-the-hard-way) and therefore created https://github.com/kelseyhightower/kubernetes-the-hard-way/issues/389. As I read through the official [create a K8s cluster from scratch guide](https://kubernetes.io/docs/setup/scratch/) I got more and more convinced on that. There are recommendations [like the following](https://kubernetes.io/docs/setup/scratch/#configuring-and-installing-base-software-on-nodes):

> While the basic node services (kubelet, kube-proxy, docker) are typically started and managed using traditional system administration/automation approaches, the remaining master components of Kubernetes are all configured and managed by Kubernetes

[and that](https://kubernetes.io/docs/setup/scratch/#kube-proxy)

> All nodes should run kube-proxy. (Running kube-proxy on a “master” node is not strictly required, but being consistent is easier.)

__BUT__ it turned out, that these are only recommendations! It´s not needed to access our applications, there´s another problem here. And again I´am really glad to have read [jeroenjacobs1205´s comment](https://github.com/kubernetes/dashboard/issues/2340#issuecomment-328765833)! Because `kube-apiserver` can´t access `kube-proxy` on the nodes:

![apiserver-access-nodes](screenshots/apiserver-access-nodes.png)

or looked at it on the big picture:

![apiserver-access-nodes-big-pic](screenshots/apiserver-access-nodes-big-pic.png)
 
 
In the end it is really simple: __[Flannel needs to be present on the master nodes](https://stackoverflow.com/a/39179200/4964553)!__ 

Now after [having Flannel also running and configured on all master nodes](https://github.com/jonashackt/kubernetes-the-ansible-way/commit/fcd203d1355cb75d5586a738472329e756848834), we can access our cluster applications with the help of the proxy verb. After running `kubectl proxy`, just point the browser to http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#! and Dashboard login should show up!



### Kubernetes DNS (kube-dns)

Debug Service DNS: https://kubernetes.io/docs/tasks/debug-application-cluster/debug-service/#does-the-service-work-by-ip

Really helpful from this article -> the kubernetes test [hostnames image](https://github.com/kubernetes/kubernetes/tree/master/test/images/serve-hostname):

```
kubectl run hostnames --image=k8s.gcr.io/serve_hostname \
                        --labels=app=hostnames \
                        --port=9376 \
                        --replicas=3
kubectl expose deployment hostnames --port=80 --target-port=9376
```

Debug kube-dns: https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/

https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/:

> Kubernetes DNS schedules a DNS Pod and Service on the cluster, and configures the kubelets to tell individual containers to use the DNS Service’s IP to resolve DNS names.


#### nslookup for kubernetes not working in kubedns / main.yml

We set `--ip-masq=false` inside the `docker.service`. The problem is

```
vagrant@master-0:~$ kubectl exec -i busybox-68654f944b-rgk5q -- nslookup kubernetes
Server:    10.32.0.10
```

We need to add the following to the `flannel.service.j2` (kubeadm had the problem also https://github.com/kubernetes/kubernetes/issues/45459):

```
  -ip-masq
```

NOW the nslookup finally works:

```
vagrant@master-0:~$ kubectl exec -i busybox-68654f944b-rgk5q -- nslookup kubernetes
Server:    10.32.0.10
Address 1: 10.32.0.10 kube-dns.kube-system.svc.cluster.local

Name:      kubernetes
Address 1: 10.32.0.1 kubernetes.default.svc.cluster.local
```

#### if nslookup still doesnt work - "If the outer resolv.conf points to 127.0.0.1:53, then you will have a DNS lookup loop"

The problem is node DNS configuration inheritance! See https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/#inheriting-dns-from-the-node

> When running a Pod, kubelet prepends the cluster DNS server and searches paths to the node’s DNS settings. If you don’t want this, or if you want a different DNS config for pods, you can use the kubelet’s --resolv-conf flag. Set this flag to “” to prevent Pods from inheriting DNS. 

Also see https://github.com/kubernetes/kubernetes/issues/49411#issuecomment-318096636

> Kubedns inherits the contents of “/etc/resolv.conf” something the maintainers of these pods should document at the following site (https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/dns ) as it takes a lot of research and googling to find such details hidden under forum comments. My two cents

check your Ubuntu boxes `cat /etc/resolve.conf`: 

```
nameserver 127.0.0.53
```

> systemd-resolved on my host listens on 127.0.0.53:53 for dns queries, as soon as I uninstall systemd-resolved and install dnsmasq my node has an entry of 127.0.0.1 in /etc/resolv.conf instead of 127.0.0.53, this gets inherited by the kubedns pods and for some reason its able to forward unresolved queries to my host dnsmasq. Earlier, the kubedns inherited the 127.0.0.53 IP from node “/etc/resolv.conf” and for some reason its not able to talk to the node systemd-resolved at that IP.


__Solution:__

See https://askubuntu.com/a/974482/451114 & https://askubuntu.com/questions/952284/dns-system-is-failing-to-resolve-domain-names-occasionally#comment1589832_952284

```
sudo mv /etc/resolv.conf /etc/resolv.conf_orig
sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
```

Now `cat /etc/resolve.conf` should inherit the correct nameserver (VirtualBox DNS server):

```
nameserver 10.0.2.3
```

See https://stackoverflow.com/questions/45246147/kubernetes-kubedns-sidecar-and-masq-crashes-if-i-do-a-nslookup/52036125#52036125

#### Busybox seems to have nslookup problems

You won´t believe it: But the latest busybox image isn´t able to do a proper `nslookup`:

https://github.com/kubernetes/kubernetes/issues/45479
https://github.com/kubernetes/kubernetes/issues/66924
https://github.com/docker-library/busybox/issues/48
https://github.com/kelseyhightower/kubernetes-the-hard-way/issues/356
https://stackoverflow.com/a/52036125/4964553




## Dashboard

> First thing important: Kubernetes and Dashboard versions need to be compatible! See https://github.com/kubernetes/dashboard/wiki/Compatibility-matrix

https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/

Installation: https://github.com/kubernetes/dashboard/wiki/Installation#recommended-setup

Access: Through API-Server: 

> In case Kubernetes API server is exposed and accessible from outside you can directly access dashboard at: 

```
kubectl -n kube-system get secret
kubectl -n kube-system describe secret kubernetes-dashboard-token-7pxdg

curl -sSk -H "Authorization: Bearer YOURTOKENHERE" https://external.k8s:6443/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/ -v
```

Or use a RESTClient like Postman:

![use-postman-to-access-via-external.k8s-dashboard](screenshots/use-postman-to-access-via-external.k8s-dashboard.png)

Grant Dashboard Admin-Rights: https://github.com/kubernetes/dashboard/wiki/Access-control#admin-privileges

> Make sure that you know what you are doing before proceeding. Granting admin privileges to Dashboard's Service Account might be a security risk.

And the dashboard could´nt be accesses right away, only manually by Johannes with a port forwarding and tiller-deployment to retrieve the Token (key didn´t work).

Usage of Dashboard is described here: https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/


### Accessing Kubernetes Dashboard with the Browser

Accessing Kubernetes Dashboard with the Browser will only work, if you use the `kubectl proxy` command (assuming correctly initialized `kubectl config set-cluster`, `set-credentials`, `set-context` & `use-context` commands beforehand) and point your Browser to:

`http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/`
 
![dashboard-browser-access-proxy](screenshots/dashboard-browser-access-proxy.png)
 
Otherwise, you need to somehow provide a (OAuth) Bearer Token, which isn´t possible in normal Browsers.



### Accessing k8s resources (like the Dashboard)

General docs for k8s service access: https://kubernetes.io/docs/tasks/administer-cluster/access-cluster-services/

> Be sure to know the [service publishing types](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types), especially `ClusterIP` (which is only accessible inside the cluster!), `NodePort` & `Loadbalancer`

Also have a look on how Services are accessing Pods - and are itself accessed by the kube-apiserver: https://kubernetes.io/docs/concepts/services-networking/service/#proxy-mode-iptables

If you´re using [Proxy-mode: iptables](https://kubernetes.io/docs/concepts/services-networking/service/#proxy-mode-iptables) like in this example here, then this looks like:

![iptables-proxy-access](https://d33wubrfki0l68.cloudfront.net/837afa5715eb31fb9ca6516ec6863e810f437264/42951/images/docs/services-iptables-overview.svg)

#### Configure kubectl to access our k8s cluster

If you want to interact with your k8s cluster, you need to setup your CLI for the specific cluster (`config set-cluster`), user (`config set-credentials`) and context (`config set-context`). All three are applied by a subsequent `config use-context`. For our `kubernetes-the-ansible-way` cluster, using the `admin` user, this is the following:

```
kubectl config set-cluster kubernetes-the-ansible-way \
      --certificate-authority=certificates/ca.pem \
      --embed-certs=true \
      --server=https://external.k8s:6443

kubectl config set-credentials admin \
      --client-certificate=certificates/admin.pem \
      --client-key=certificates/admin-key.pem

kubectl config set-context cluster-access \
      --cluster=kubernetes-the-ansible-way \
      --user=admin

kubectl config use-context cluster-access
```

Review the successful configuration by a `kubectl cluster-info`. This should give something like:

```
$ kubectl cluster-info
Kubernetes master is running at https://external.k8s:6443
KubeDNS is running at https://external.k8s:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

or have a look at your configuration with `kubectl config view` (see https://kubernetes.io/docs/tasks/access-application-cluster/access-cluster/#accessing-for-the-first-time-with-kubectl).

> Keep in mind, that a Kubernetes context is a triple out of cluster(name), user(name) & namespace. [See the docs](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/#define-clusters-users-and-contexts)


#### Authentication

See https://kubernetes.io/docs/reference/access-authn-authz/authentication/. 

We always (regardless which access we want to do to our k8s cluster) need to authenticate against the `kube-apiserver`. This can be done through many ways, one is to use a [Bearer Token](https://github.com/kubernetes/dashboard/wiki/Creating-sample-user#bearer-token) inside the Request. Extract the Token with:

```
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep YourDashboardUserHere | awk '{print $1}')
```

or

```
kubectl -n kube-system get secret
kubectl -n kube-system describe secret kubernetes-dashboard-token-7pxdg
```

This gives something like:

```
Name:         kubernetes-dashboard-token-7pxdg
Namespace:    kube-system
Labels:       <none>
Annotations:  kubernetes.io/service-account.name=kubernetes-dashboard
              kubernetes.io/service-account.uid=b7a7d00e-acfe-11e8-9ce0-027a2f310a05

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1314 bytes
namespace:  11 bytes
token:      fooBarYourTokenHere
```

Now use your Token `fooBarYourTokenHere` within a HTTP request to `https://external.k8s:6443/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/`.

If not, you´ll see a message like this:

```
{
    "kind": "Status",
    "apiVersion": "v1",
    "metadata": {},
    "status": "Failure",
    "message": "services \"https:kubernetes-dashboard:\" is forbidden: User \"system:anonymous\" cannot get services/proxy in the namespace \"kube-system\"",
    "reason": "Forbidden",
    "details": {
        "name": "https:kubernetes-dashboard:",
        "kind": "services"
    },
    "code": 403
}
```

If you deployed another app like

```
kubectl run hostnames --image=k8s.gcr.io/serve_hostname \
                        --labels=app=hostnames \
                        --port=9376 \
                        --replicas=3
kubectl expose deployment hostnames --port=80 --target-port=9376
```

and want to access that through `https://external.k8s:6443/api/v1/namespaces/default/services/hostnames/proxy/` (using Bearer Token):

![use-postman-to-access-via-external.k8s](screenshots/use-postman-to-access-via-external.k8s.png)

#### Authorization

See https://kubernetes.io/docs/reference/access-authn-authz/authorization/

kubernetes-the-hard-way configure Node and RBAC authorization modules. [RBAC is defined as](https://kubernetes.io/docs/reference/access-authn-authz/authorization/#authorization-modules):

> RBAC - Role-based access control (RBAC) is a method of regulating access to computer or network resources based on the roles of individual users within an enterprise

For configuring a Dashboard user, see https://github.com/kubernetes/dashboard/wiki/Creating-sample-user#bearer-token

#### Access Dashboard directly on worker-nodes

As we deployed Dashboard with `NodePort`, run `kubectl get services -n kube-system` to get the NodePort of your Dashboard Service:

```
vagrant@master-0:/$ kubectl get services -n kube-system
NAME                   TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)         AGE
kube-dns               ClusterIP   10.32.0.10    <none>        53/UDP,53/TCP   5d
kubernetes-dashboard   NodePort    10.32.0.242   <none>        443:30348/TCP   5d
```

Now enter the following URL into your Browser and accept the SecurityExceptions: `https://worker-1.k8s:30348` (regardless which worker)

Extract the Dashboard Bearer Token with:

```
kubectl -n kube-system get secret
kubectl -n kube-system describe secret kubernetes-dashboard-token-7pxdg
```

and paste the Token into the provided field of the Loginscreen. Now you should see the Dashboard:

![dashboard-browser-access-worker](screenshots/dashboard-browser-access-worker.png)

#### Access a k8s cluster app (pod) through a Service

https://kubernetes.io/docs/tasks/access-application-cluster/service-access-application-cluster/

```
kubectl run hello-world --replicas=2 --labels="run=load-balancer-example" --image=gcr.io/google-samples/node-hello:1.0  --port=8080

kubectl expose deployment hello-world --type=NodePort --name=hello-world-service
```

# Helm

Install Helm / Tiller: https://docs.helm.sh/using_helm/

### Helm client

Mac: `brew install kubernetes-helm`

Windows: `choco install kubernetes-helm`

### Helm server (Tiller)

https://docs.helm.sh/using_helm/#installing-tiller

The role [helm-tiller](/roles/helm-tiller/tasks/main.yml) takes care of the installation:

We need to add some RBAC config for Tiller: https://docs.helm.sh/using_helm/#tiller-and-role-based-access-control

### Verification, if Helm & Tiller were installed correctly

Let´s create a [Hello-Helm-World Chart](https://github.com/helm/helm/blob/master/docs/chart_template_guide/getting_started.md#a-starter-chart), as there doesn´t seem to be a standard one. 

We use a standard `helm create hello-helm-world` and override the nginx image simply. Then we install it, verify if a pod is running and delete it again.

```bash
# Verify, if Helm was installed successfully
- name: Ensure hello-helm-world directory exists (otherwise, the helm create will fail with permission denied)
  file:
    path: /home/vagrant/hello-helm-world/
    state: directory

- name: Create a Hello-Helm-World Chart
  shell: helm create hello-helm-world
  become: yes

- name: Override values.yaml for setting node-hello instead of nginx as image
  copy:
    src: values.yaml
    dest: /home/vagrant/hello-helm-world/values.yaml
    force: yes

- name: Run Hello-Helm-World Chart
  shell: "helm install --name hello-helm-world ./hello-helm-world"

- name: Check if Hello-Helm-World Pod is running
  shell: kubectl get pods -l app=hello-helm-world
  register: helm_result
  until: helm_result.stdout.find("Running") != -1
  retries: 10
  delay: 10

- name: Show Hello-Helm-World Pod
  debug:
    msg: "{{ helm_result.stdout_lines }}"

- name: Delete Hello-Helm-World Release
  shell: "helm delete --purge hello-helm-world"

- name: Delete hello-helm-world directory
  file:
    path: /home/vagrant/hello-helm-world/
    state: absent
```

### Helm Charts

Start browsing here: https://github.com/helm/charts

# Commands

```bash

ansible --private-key=$(pwd)/.vagrant/machines/client-0/virtualbox/private_key client -i hosts -u vagrant -m setup

# kube api server health checks
curl --cacert certificates/ca.pem --key certificates/admin-key.pem --cert certificates/admin.pem https://client-0.k8s:6443/healthz

```

# Links

  * [kubectl cheatsheet][0] 
  * [Exam Experience][1] 
  * [K8s from scratch by offical documentation][2] 
  * [Google Document by codecentric K8s GERMAN Team][3] 
  * [kubernetes by example][4] 
  * [Best practice by google][5] 
  * [Tutorialspoint][6] 
  * Tutorials: https://kubernetes.io/docs/tutorials/kubernetes-basics/explore/explore-intro/


[0]: https://kubernetes.io/docs/reference/kubectl/cheatsheet/
[1]: https://medium.com/@jnowakowski/k8s-admin-exam-tips-22961241ba7d
[2]: https://kubernetes.io/docs/setup/scratch/#designing-and-preparing
[3]: https://docs.google.com/document/u/2/d/1nAQQNjoPzpzvZZhJk0wyKBqz9udgYZjzJgeRAjo6vU4/edit?usp=sharing
[4]: http://kubernetesbyexample.com/
[5]: https://medium.com/google-cloud/kubernetes-best-practices-season-one-11119aee1d10
[6]: https://www.tutorialspoint.com/kubernetes/index.htm