## Templates for Diagrams

https://mermaid.live/edit

### Base Sequence

```
sequenceDiagram
    actor User
    User->>Terraform: terraform apply
    box Cloud Provider
        participant Bastion Host
        participant Control Plane
        participant Data Plane
        participant Monitoring
    end
    activate Terraform
    Note over Terraform, Monitoring: Deploy Infrastructure
    %% Terraform->>Bastion Host: Create Bastion Host
    %% Terraform->>Control Plane: Create Consul Servers
    %% Control Plane-->>Terraform: 
    %% Terraform->>Data Plane: Create Consul Clients and Gateways
    %% Data Plane-->>Terraform: 
    %% Terraform->>Monitoring: Create Monitoring nodes
    %% Monitoring-->>Terraform: 
    %% Bastion Host-->>Terraform: Complete infrastructure deployment
    Note over Terraform, Monitoring: Deploy Scenario
    Terraform->>Bastion Host: Start scenario deployment
    activate Bastion Host
    %% par Deploy Control Plane
    %%     Bastion Host->>Control Plane: Start Consul servers
    %%     Bastion Host->>Control Plane: 🔑 Bootstrap ACLs (management token)
    %%     Bastion Host->>Control Plane: 🔑 Create ACL tokens for Consul servers
    %% and Deploy Data Plane
    %%     %% Bastion Host->>Control Plane: 🔑 Create ACL tokens for Consul clients
    %%     Bastion Host->>Data Plane: Start Consul clients (service nodes and gateways)
    %%     Bastion Host->>Data Plane: Register services and health checks
    %%     Bastion Host->>Data Plane: Start Envoy sidecar-proxies
    %%     Bastion Host->>Data Plane: ⚠️ Start services
    %%     Note right of Data Plane: You can start services at any time, <br> starting them after Consul service mesh <br> ensures thay will be able to work <br> right after starting.
    %%     Data Plane-->>Bastion Host: ✅ Services started
    %%     Bastion Host->>Data Plane: Start and configure gateways
    %% and Deploy Monotoring suite
    %%     Bastion Host->>Monitoring: Start monitoring suite (Grafana, Loki, Mimir, ...)
    %%     Bastion Host->>Control Plane: Start metrics collection
    %%     Control Plane-->>Monitoring: Send metrics
    %%     Bastion Host->>Data Plane: Start metrics collection
    %%     Data Plane-->>Monitoring: Send metrics
    %% end
    Bastion Host-->>Terraform: Complete scenario deployment
    deactivate Bastion Host
    Terraform->>User: terraform output
    deactivate Terraform
```

### Full sequence 

```
sequenceDiagram
    actor User
    User->>Terraform: terraform apply
    box Cloud Provider
        participant Bastion Host
        participant Control Plane
        participant Data Plane
        participant Monitoring
    end
    activate Terraform
    Note over Terraform, Monitoring: Deploy Infrastructure
    Terraform->>Bastion Host: Create Bastion Host
    Terraform->>Control Plane: Create Consul Servers
    Control Plane-->>Terraform: 
    Terraform->>Data Plane: Create Consul Clients and Gateways
    Data Plane-->>Terraform: 
    Terraform->>Monitoring: Create Monitoring nodes
    Monitoring-->>Terraform: 
    Bastion Host-->>Terraform: Complete infrastructure deployment
    Note over Terraform, Monitoring: Deploy Scenario
    Terraform->>Bastion Host: Start scenario deployment
    activate Bastion Host
    par Deploy Control Plane
        Bastion Host->>Control Plane: Start Consul servers
        Bastion Host->>Control Plane: 🔑 Bootstrap ACLs (management token)
        Bastion Host->>Control Plane: 🔑 Create ACL tokens for Consul servers
    and Deploy Data Plane
        Bastion Host->>Control Plane: 🔑 Create ACL tokens for Consul clients
        Bastion Host->>Data Plane: Start Consul clients (service nodes and gateways)
        Bastion Host->>Data Plane: Register services and health checks
        Bastion Host->>Data Plane: Start Envoy sidecar-proxies
        Bastion Host->>Data Plane: ⚠️ Start services
        Note right of Data Plane: You can start services at any time, <br> starting them after Consul service mesh <br> ensures thay will be able to work <br> right after starting.
        Data Plane-->>Bastion Host: ✅ Services started
        Bastion Host->>Data Plane: Start and configure gateways
    and Deploy Monotoring suite
        Bastion Host->>Monitoring: Start monitoring suite (Grafana, Loki, Mimir, ...)
        Bastion Host->>Control Plane: Start metrics collection
        Control Plane-->>Monitoring: Send metrics
        Bastion Host->>Data Plane: Start metrics collection
        Data Plane-->>Monitoring: Send metrics
    end
    Bastion Host-->>Terraform: Complete scenario deployment
    deactivate Bastion Host
    Terraform->>User: terraform output
    deactivate Terraform
```