[![Terraform](https://github.com/akosiaris/k0s_hetzner/actions/workflows/terraform.yaml/badge.svg)](https://github.com/akosiaris/k0s_hetzner/actions/workflows/terraform.yaml)

# Intro

This is a Proof of Concept. Use anything here at your own risk

# Usage

If you use Windows, go get a linux machine.

Get terraform, clone this repo with git, cd into the dir

Create a new SSH key
```
$ ssh-keygen -t ed25519 -f id_ed25519_k0s_hetzner_poc
```

Now, go to [Hetzner Cloud console](console.hetzner.cloud), create project, go to security, create an API token

Create a file named terraform.tfvars and put inside the Token from Hetzner's portal and the public key as below. Note that this file is git-ignored
```
hcloud_token = "API_TOKEN_HERE"
ssh_pub_key = "SSH_KEY_HERE"
ssh_priv_key_path = "path_to_priv_key_file"
domain            = "example.com"
```

This are the absolute necessities, look below for all the tunables that you can configure using this file

Now, run the following to get the providers
```
$ terraform init
```

Then validate that our HCL is sound
```
$ terraform validate
```

Then spew out the plan and stare at it for a while, to dispel demons etc
```
$ terraform plan
```

Once you are sure that the demons have been exorcised create the resources
```
$ SSH_KNOWN_HOSTS=/dev/null terraform apply -auto-approve
```

Wait for the output and fetch the IPv6 and IPv4 addresses. Based on what you have of the 2, ssh to the node.
Note that I am on purpose redirecting to /dev/null the host key as I don't want to keep it around for this PoC.

```
ssh -o UserKnownHostsFile=/dev/null -i ~/.ssh/id_ed25519_k0s_hetzner_poc root@<ip_address>
```

## k0s usage

k0s is distribution of Kubernetes that has some interesting properties. Some basic commands:

List nodes
```
# k0s kubectl get nodes -o wide
```

List all pods everywhere
```
# k0s kubectl get pods --all-namespaces -o wide
```

List namespaces
```
# k0s kubectl get ns
```

If you have kubectl (or any other compatible kubernetes client, e.g. Lens,
Helm) locally, there is kubeconfig file saved in the root of the repo after a
successful apply, use it at your discretion.
Note: This file provides FULL access to the cluster. Don't mishandle it

### Deploy a basic pod

```
# k0s kubectl run nginx --image=nginx
```

### Deploy using helm

TBD

### k0s admin notes
Backup the configuration of k0s
```
# mkdir -p backup
# k0s backup --save-path backup
```

Restore the above
```
# k0s backup backup/<file_name>
```

Check the system. Note the IPv4/IPv6 conntrack/nat warnings are expected for
kernels past 4.19 and 5.1 respectively
```
# k0s sysinfo | grep -v pass
```

### Add workers/controllers

TBD

# Removal of resources

Cloud isn't free and this is a PoC. Delete everything when done to avoid runaway costs
```
$ terraform apply -auto-approve -destroy
```

# Tunables

Other settings you can set in terraform.tfvars

* controller\_count - Amount of controllers. Number. Defaults to 3
* controller\_server\_type - Hetzner's server type. Refer to controller\_variables.tf for valid values
* controller\_server\_image - Hetzner's server image. Defaults to Debian 11. Refer to controller\_variables.tf for valid values
* controller\_server\_location - Hetzner's server location. Defaults to Falkenstein. Refer to controller\_variables.tf for valid values
* controller\_role - k0s controller roles. Valid values: controller, controller+worker, single
* worker\_count - Amount of workers. Number. Defaults to 3
* worker\_server\_type - Hetzner's server type. Refer to worker\_variables.tf for valid values
* worker\_server\_image - Hetzner's server image. Defaults to Debian 11. Refer to worker\_variables.tf for valid values
* worker\_server\_location - Hetzner's server location. Defaults to Falkenstein. Refer to worker\_variables.tf for valid values
* k0s\_version - The k0s version to target. Valid values: 1.27.2+k0s.0 for now

# TODO

- [x] Implement an easy way to add more controllers
- [x] Implement an easy way to add more workers
- [x] The controller gets a taint that needs to be deleted (or workloads to apply a toleration)
- [x] sysinfo complains about NAT unknown, figure it out. #1
- [x] Evaluate using k0s's helm integration
- [x] Allow to set a Reverse DNS
- [x] Decide whether to have the ssh key in user-data or as a terraform resource. Need to evaluate how the latter interacts with cloud-init, if at all
- [ ] Support Hetzner "private" networks
- [ ] Support vswitch type in Hetzner "private" networks
- [ ] Evaluate/support [Hetzner's cloud controller manager](https://github.com/hetznercloud/hcloud-cloud-controller-manager)
- [ ] Hetzner right kinda leads us to use the root user. We apparently can use cloud-inits user-data to get away from that
- [ ] Write more docs
