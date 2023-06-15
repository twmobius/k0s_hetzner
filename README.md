# Intro

This is a Proof of Concept. Use anything here at your own risk

# Usage

If you use Windows, go get a linux machine.

Create a new SSH key
```
ssh-keygen -t ed25519 -f id_ed25519_k0s_hetzner_poc
```

Get terraform, clone this repo

Edit user-data file and where it says #REPLACEME# put your public key

Now, run the following to get the provider
```
terraform init
```

Then validate that our HCL is sound
```
terraform validate
```

Then spew out the plan and stare at it for a while, to dispel demons etc
```
terraform plan
```

Once you are sure that the demons have been exorcised create the resources
```
terraform apply -auto-approve
```

Wait for the output and fetch the IPv6 and IPv4 addresses. Based on what you have of the 2, ssh to the node.
Note that I am on purpose redirecting to /dev/null the key as I don't want to keep it around for this PoC.

```
ssh -o UserKnownHostsFile=/dev/null -i ~/.ssh/id_ed25519_k0s_hetzner_poc root@<ip_address>
```

# Removal of resources

Cloud isn't free and this is a PoC. Delete everything when done to avoid runaway costs
```
terraform apply -auto-approve -destroy
```
