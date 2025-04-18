

# ----------------- #
# | NETEWORK      | #
# ----------------- #

resource "docker_network" "primary_network" {
  name = "learn-network"
  labels {
    label = "tag"
    value = "learn-consul-vms-test"
  }
}

# ----------------- #
# | PREREQUISITES | #
# ----------------- #

resource "docker_container" "bastion_host" {
  name     = "bastion"
  image    = "learn-consul-vms-test/base-consul:learn-consul-vms-test"
  hostname = "bastion"

  networks_advanced {
    name = docker_network.primary_network.id
  }

  ports {
    internal = "22"
    external = "2222"
  }

  labels {
    label = "tag"
    value = "learn-consul-vms-test"
  }

  volumes {
    container_path = "/home/${var.vm_username}/assets"
    host_path      = abspath("${path.module}/../../../var/assets")
  }
  
  volumes {
    container_path = "/home/${var.vm_username}/bin"
    host_path      = abspath("${path.module}/../../../bin")
  }

  volumes {
    container_path = "/home/${var.vm_username}/runbooks"
    host_path      = abspath("${path.module}/../../../runbooks")
  }

  connection {
    type        = "ssh"
    user        = "${var.vm_username}"
    private_key = file("./images/base/certs/id_rsa")
    host        = "127.0.0.1"
    port        = 2222
  }

  provisioner "local-exec" {
    command = "chmod 0777 ${path.module}/../../../var/assets"
  }

  provisioner "file" {
    source      = "${path.module}/../../../assets"
    destination = "/home/${var.vm_username}/"
  }

  provisioner "file" {
    source      = "${path.module}/../../ops"
    destination = "/home/${var.vm_username}"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /home/${var.vm_username}/ops && bash ./provision.sh operate ${var.scenario}"
    ]
  }
}

# ----------------- #
# | CONTROL PLANE | #
# ----------------- #

resource "docker_container" "consul_server" {
  name     = "consul-server-${count.index}"
  count    = var.server_number
  image    = "learn-consul-vms-test/base-consul:learn-consul-vms-test"
  hostname = "consul-server-${count.index}"
  
  networks_advanced {
    name = docker_network.primary_network.id
  }
  labels {
    label = "tag"
    value = "learn-consul-vms-test"
  }

  ports {
    internal = "8443"
    external = format("%d", count.index + 8443)
  }

  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/../../../var/logs/${self.name} && chmod 0777 ${path.module}/../../../var/logs/${self.name}"
  }

  volumes {
    container_path = "/tmp/logs"
    host_path      = abspath("${path.module}/../../../var/logs/consul-server-${count.index}")
  }

}

# ----------------- #
# | GATEWAYS      | #
# ----------------- #

resource "docker_container" "gateway_api" {
  name     = "gateway-api-${count.index}"
  count    = var.api_gw_number
  image    = "learn-consul-vms-test/base-consul:learn-consul-vms-test"
  hostname = "gateway-api-${count.index}"
  
  networks_advanced {
    name = docker_network.primary_network.id
  }
  labels {
    label = "tag"
    value = "learn-consul-vms-test"
  }

  ports {
    internal = format("%d", 8443)
    external = format("%d", count.index + 9443)
  }

  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/../../../var/logs/${self.name} && chmod 0777 ${path.module}/../../../var/logs/${self.name}"
  }

  volumes {
    container_path = "/tmp/logs"
    host_path      = abspath("${path.module}/../../../var/logs/gateway-api-${count.index}")
  }

}

resource "docker_container" "gateway_terminating" {
  name     = "gateway-terminating-${count.index}"
  count    = var.term_gw_number
  image    = "learn-consul-vms-test/base-consul:learn-consul-vms-test"
  hostname = "gateway-terminating-${count.index}"
  
  networks_advanced {
    name = docker_network.primary_network.id
  }
  labels {
    label = "tag"
    value = "learn-consul-vms-test"
  }

  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/../../../var/logs/${self.name} && chmod 0777 ${path.module}/../../../var/logs/${self.name}"
  }

  volumes {
    container_path = "/tmp/logs"
    host_path      = abspath("${path.module}/../../../var/logs/gateway-terminating-${count.index}")
  }
}

resource "docker_container" "gateway_mesh" {
  name     = "gateway-mesh-${count.index}"
  count    = var.mesh_gw_number
  image    = "learn-consul-vms-test/base-consul:learn-consul-vms-test"
  hostname = "gateway-mesh-${count.index}"
  
  networks_advanced {
    name = docker_network.primary_network.id
  }
  labels {
    label = "tag"
    value = "learn-consul-vms-test"
  }

  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/../../../var/logs/${self.name} && chmod 0777 ${path.module}/../../../var/logs/${self.name}"
  }

  volumes {
    container_path = "/tmp/logs"
    host_path      = abspath("${path.module}/../../../var/logs/gateway-mesh-${count.index}")
  }

}

# ----------------- #
# | CONSUL ESM    | #
# ----------------- #

resource "docker_container" "consul-esm" {
  name     = "consul-esm-${count.index}"
  count    = var.consul_esm_number
  image    = "learn-consul-vms-test/base-consul:learn-consul-vms-test"
  hostname = "consul-esm-${count.index}"
  
  networks_advanced {
    name = docker_network.primary_network.id
  }
  labels {
    label = "tag"
    value = "learn-consul-vms-test"
  }

  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/../../../var/logs/${self.name} && chmod 0777 ${path.module}/../../../var/logs/${self.name}"
  }

  volumes {
    container_path = "/tmp/logs"
    host_path      = abspath("${path.module}/../../../var/logs/consul-esm-${count.index}")
  }

}


# ----------------- #
# | DATA PLANE    | #
# ----------------- #

resource "docker_container" "hashicups_nginx" {
  name     = "hashicups-nginx-${count.index}"
  count    = var.hc_lb_number
  image    = "learn-consul-vms-test/hashicups-nginx:learn-consul-vms-test"
  hostname = "hashicups-nginx-${count.index}"
  networks_advanced {
    name = docker_network.primary_network.id
  }
  labels {
    label = "tag"
    value = "learn-consul-vms-test"
  }

  ports {
    internal = "80"
    external = "8${count.index}"
  }

  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/../../../var/logs/${self.name} && chmod 0777 ${path.module}/../../../var/logs/${self.name}"
  }

  volumes {
    container_path = "/tmp/logs"
    host_path      = abspath("${path.module}/../../../var/logs/hashicups-nginx-${count.index}")
  }
}

resource "docker_container" "hashicups_frontend" {
  name     = "hashicups-frontend-${count.index}"
  count    = var.hc_fe_number
  image    = "learn-consul-vms-test/hashicups-frontend:learn-consul-vms-test"
  hostname = "hashicups-frontend-${count.index}"
  networks_advanced {
    name = docker_network.primary_network.id
  }
  labels {
    label = "tag"
    value = "learn-consul-vms-test"
  }

  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/../../../var/logs/${self.name} && chmod 0777 ${path.module}/../../../var/logs/${self.name}"
  }

  volumes {
    container_path = "/tmp/logs"
    host_path      = abspath("${path.module}/../../../var/logs/hashicups-frontend-${count.index}")
  }

}

resource "docker_container" "hashicups_api" {
  name     = "hashicups-api-${count.index}"
  count    = var.hc_api_number
  image    = "learn-consul-vms-test/hashicups-api:learn-consul-vms-test"
  hostname = "hashicups-api-${count.index}"
  networks_advanced {
    name = docker_network.primary_network.id
  }
  labels {
    label = "tag"
    value = "learn-consul-vms-test"
  }

  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/../../../var/logs/${self.name} && chmod 0777 ${path.module}/../../../var/logs/${self.name}"
  }

  volumes {
    container_path = "/tmp/logs"
    host_path      = abspath("${path.module}/../../../var/logs/hashicups-api-${count.index}")
  }

}

resource "docker_container" "hashicups_db" {
  name     = "hashicups-db-${count.index}"
  count    = var.hc_db_number
  image    = "learn-consul-vms-test/hashicups-database:learn-consul-vms-test"
  hostname = "hashicups-db-${count.index}"
  networks_advanced {
    name = docker_network.primary_network.id
  }
  labels {
    label = "tag"
    value = "learn-consul-vms-test"
  }

  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/../../../var/logs/${self.name} && chmod 0777 ${path.module}/../../../var/logs/${self.name}"
  }

  volumes {
    container_path = "/tmp/logs"
    host_path      = abspath("${path.module}/../../../var/logs/hashicups-db-${count.index}")
  }
}


# ----------------- #
# | MONITORING    | #
# ----------------- #

resource "docker_container" "grafana" {
  name     = "grafana"
  count    = "${var.start_monitoring_suite ? 1 : 0}"
  image    = "grafana/grafana:latest"
  hostname = "grafana"

  networks_advanced {
    name = docker_network.primary_network.id
  }

  labels {
    label = "tag"
    value = "learn-consul-vms-test"
  }

  ## External port should be 3000, we use 3001 to not conflic with Tutorials preview.
  ports {
    internal = "3000"
    external = "3001"
  }

  volumes {
    host_path      = abspath("${path.module}/../../../assets/templates/conf/grafana/provisioning/datasources")
    container_path = "/etc/grafana/provisioning/datasources"
  }

  volumes {
    host_path      = abspath("${path.module}/../../../assets/templates/conf/grafana/provisioning/dashboards")
    container_path = "/etc/grafana/provisioning/dashboards"
  }

  volumes {
    host_path      = abspath("${path.module}/../../../assets/templates/conf/grafana/dashboards")
    container_path = "/var/lib/grafana/dashboards"
  }

  env = [
    "GF_AUTH_ANONYMOUS_ENABLED=true",
    "GF_AUTH_ANONYMOUS_ORG_ROLE=Admin",
    "GF_AUTH_DISABLE_LOGIN_FORM=true"
  ]

}

resource "docker_container" "loki" {
  name     = "loki"
  count    = "${var.start_monitoring_suite ? 1 : 0}"
  image    = "grafana/loki:main"
  hostname = "loki"

  networks_advanced {
    name = docker_network.primary_network.id
  }

  labels {
    label = "tag"
    value = "learn-consul-vms-test"
  }

  command = ["-config.file=/etc/loki/local-config.yaml"]

}

resource "docker_container" "mimir" {
  name     = "mimir"
  count    = "${var.start_monitoring_suite ? 1 : 0}"
  image    = "grafana/mimir:latest"
  hostname = "mimir"
  networks_advanced {
    name = docker_network.primary_network.id
  }

  labels {
    label = "tag"
    value = "learn-consul-vms-test"
  }

  volumes {
    host_path      = abspath("${path.module}/../../../assets/templates/conf/mimir/mimir.yaml")
    container_path = "/etc/mimir/mimir.yaml"
  }

  command = ["--config.file=/etc/mimir/mimir.yaml"]
}