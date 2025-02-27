[Home](../README.md) > Docs

# Documentation for modular Consul scenario simulator

The code in this repository provides preconfigured scenarios to test Consul in 
single-datacenter configurations with the [HashiCups](HashiCups.md) 
demo application.

The scenarios use [Terraform](https://www.terraform.io/) to deploy the resources 
in the different cloud providers and to provision the necessary configuration 
for the resources.

## Available cloud providers

The scenarios are meant to provide a unified flow across the different cloud 
providers. This minimizes code duplication and speeds up development.

The code currently supports deploying scenarios in the following providers:
* Docker
* AWS
* Azure

### Reconcile provider differences

When a cloud provider presents differences in the UX that cannot be ignored, 
this is signaled in the code with a comment:

```sh
## [ux-diff] [cloud provider] UX differs across different Cloud providers
```

Check the occurrences of the comment in the code to identify differences in UX 
for the available providers.
