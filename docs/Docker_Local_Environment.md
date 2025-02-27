# Test environment locally with Docker

The scenarios can be tested in Docker using custom docker images that mimic a VM with SSH

## Prerequisites

* Terraform installed
* Docker up and running
* `tree` command (or use `ls` as an alternative)

Given these prerequisites the local environment should work both on `bash` and `zsh`.

## Build images

Images are contained in the `images` folder.

```
cd self-managed/infrastructure/docker/images
```

The folder also contains some scripts that help you build images to test the scenarios locally.

### Generate variables

To build the images you require some variables to be set. The `generate_variables.sh` script helps you doing so.

```
./generate_variables.sh
```

> *Note:* You need GNU grep to run the command. If you are on MacOS check https://stackoverflow.com/questions/59232089/how-to-install-gnu-grep-on-mac-os to install the GNU version for the grep tool.

If you do not want to install GNU grep you can populate the `variables.env` file manually:

```
#!/usr/bin/env bash
CONSUL_VERSION=1.17.0
ENVOY_VERSION=1.27.2
DOCKER_REPOSITORY=learn-consul-vms
DOCKER_BASE_IMAGE=base-image
DOCKER_BASE_CONSUL=base-consul
HC_API_PAYMENTS_VERSION=latest
HC_API_PRODUCT_VERSION=v0.0.22
HC_API_PUBLIC_VERSION=v0.0.7
```

Refer to [Envoy supported verion](https://developer.hashicorp.com/consul/docs/connect/proxies/envoy#envoy-and-consul-client-agent) to identify the correct Envoy version for your Consul version.

### Build images

With the variables in place you can run the build script.

```
./build_images.sh
```

## Run environment

Move into `docker` folder

```
cd ..
```

Select scenario

```
tree ../../ops/conf/
```

Output example at the moment of writing this document.

```
../../ops/conf/
├── 00_base_consul_dc.tfvars
├── 01_modular_scenario_sd.tfvars
├── 01_modular_scenario_sm.tfvars
├── automate_configuration_with_consul_template.tfvars
├── manage_permissions_with_acls.tfvars
└── monitor_application_health_with_distributed_checks.tfvars

1 directory, 6 files
```

Each `.tfvars` file represents a scenario configuration. Select one of the files and launch the scenario.

Init terraform

```
terraform init
```

Run scenario

```
terraform destroy --auto-approve && terraform apply --auto-approve -var-file=../../ops/conf/monitor_application_health_with_distributed_checks.tfvars
```

The command will deploy all the required infrastructure for the scenario and perform the needed configuration.

### Interact with the scenario

The end of the output will provide you with useful commands and links to test the deployed scenario.

```
...
Apply complete! Resources: 9 added, 0 changed, 0 destroyed.

Outputs:

connection_string = "ssh -i images/base/certs/id_rsa admin@localhost -p 2222"
consul_bootstrap_token = "ssh -i images/base/certs/id_rsa admin@localhost -p 2222 'cat assets/scenario/conf/secrets/acl-token-bootstrap.json | jq -r .SecretID'"
remote_ops = "export BASTION_HOST=127.0.0.1:2222"
ui_consul = "https://localhost:8443"
ui_grafana = "http://localhost:3001/d/hashicups/hashicups"
ui_hashicups = "http://localhost"
ui_hashicups_api_gw = "https://localhost:9443"
```

- `connection_string` - command to connect with the Bastion Host.
- `consul_bootstrap_token` - command to obtain the Consul management token that was created during the ACL bootstrap phase.
- `remote_ops` - [DEPRECATED] - provides a way to interact with the scenario without re-deploying the hardware. The remote interaction is not actively under development and will be dropped in future releases.
- `ui_consul` - link to access the Consul UI.
- `ui_grafana` - link to access the Grafana UI.
- `ui_hashicups` - link to access the HashiCups UI.
- `ui_hashicups_api_gw` - link to access the HashiCups UI using the API gateway.

> **Note:** some of the links to access UIs might not work depending on the [Scenario Configuration](./Scenario_Configuration.md).

## Clean environment

```
terraform destroy --auto-approve
```
