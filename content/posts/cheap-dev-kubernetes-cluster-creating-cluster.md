---
{
  "type": "post",
  "title": "Cheap development kubernetes cluster. Creating the cluster.",
  "description": "Create a cheap single node (for now) kubernetes cluster using Hetzner cloud and microk8s. Next posts will explain how to configure a pipeline to deploy an app to the cluster using github actions.",
  "image": "/images/article-covers/hello.jpg",
  "draft": true,
  "published": "2021-02-28"
}
---

In this article we will go through the steps to have a fairly cheap development
kubernetes cluster (single node to start). We will use a VM from [hetzner cloud](https://www.hetzner.com/).

I chose a VM with 2 vCPUs and 4GB of RAM that costs ~£5/€6/$7 per month. My intention
is to use the cluster to host varied pet projects instead of having separate servers.
You might get away with a cheaper one.

## Creating an account with Hetzner

First thing we need to do is creating a Hetzner cloud account [here](https://accounts.hetzner.com/signUp).

## Setup the hcloud CLI

You can download the CLI binary from the [releases page](https://github.com/hetznercloud/cli/releases).
If you are using mac you can also use `brew install hcloud` to install it. 

### Generate a access token in web

- From your dashboard, select the default project (or create another one, up to you).
- In the left panel click on security (the key icon).
- On the menu on top click on API TOKENS.
- Click on GENERATE API TOKEN button on the top right.
- Give the token a name and select Read & Write permissions.
![Generating API token](/images/cheap-dev-kubernetes/hetzner-api-token.png)
- Copy the token, it's your only chance. Don't worry you can always generate another one.


### Setup token in cli

Create a context with:

```
hcloud context create microk8s
```

Then paste the API token there.

### Add you key so you can ssh to the VM later

```
hcloud ssh-key create --name microk8s --public-key-from-file ~/.ssh/id_rsa.pub
```

## Create a VM in Hetzner cloud and install microk8s

### Spin up a VM in hetzner

```
hcloud server create --name microk8s-n1 --image ubuntu-20.04 --location fsn1 --type cx21 --ssh-key microk8s
```

You will get an IP address at the end of the output, note it so we can ssh on it later

### ssh into the server

```
ssh root@157.90.155.57
```

### Install microk8s

We are going to use snap to install microk8s, so we need to install snap first.

```
apt-get update
apt install snapd
snap install microk8s --classic --channel=1.19
```

Next we need to set some permissions:

```
usermod -a -G microk8s $USER
chown -f -R $USER ~/.kube
```

You can then check (and wait) if k8s is running with:

```
microk8s status --wait-ready
```

You can now use `microk8s kubectl` as you would usually do with
`kubectl`. For example:

```
microk8s kubectl get nodes
```

You should see your node listed in the output.

### Installing microk8s extensions

We are going to install a few extensions. We don't need them all yet,
but we are going to need them when we deploy our app.

```
microk8s enable dns host-access ingress rbac
```

- **dns** is used to ease the communication between parts of the cluster.
- **host-access** allows pods in the cluster to communicate with hosts services. We will use this to connect to `postgresql` running in the host VM.
- **ingress** installs a simple nginx ingress controller to manage external access.
- **rbac** enable role based access control for authorisation.

You can read more about microk8s addons [here](https://microk8s.io/docs/addons).

## Configure cluster management access from outside

