# Configure a scenario

Available scenarios are defined inside the `self-managed/ops/conf` folder.

```
tree self-managed/ops/conf
```

Example output:

```plaintext
self-managed/ops/conf/
├── 00_base_consul_dc.tfvars
├── 01_modular_scenario_sd.tfvars
├── 01_modular_scenario_sm.tfvars
├── automate_configuration_with_consul_template.tfvars
├── manage_permissions_with_acls.tfvars
└── monitor_application_health_with_distributed_checks.tfvars

1 directory, 6 files
```

> **Note:** Scenarios will change over time, the output above is provided as an example.

## Base Consul DC

