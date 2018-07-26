// Configure the Google Cloud provider
provider "google" {
  credentials = "${file("../credentials/rebirthdb-infra.json")}"
  project     = "${var.project}"
  region      = "${var.region}"
}

# ------------------------------------------------------------------------------
# CREATE FIREWALL RULES
# ------------------------------------------------------------------------------
# Allow Consul-specific traffic within the cluster
resource "google_compute_firewall" "allow_intracluster_consul" {
  name    = "${var.cluster_name}-rule-cluster"
  network = "${var.network_name}"

  allow {
    protocol = "tcp"

    ports = [
      "${var.server_rpc_port}",
      "${var.cli_rpc_port}",
      "${var.serf_lan_port}",
      "${var.serf_wan_port}",
      "${var.http_api_port}",
      "${var.dns_port}",
      "${var.vault_port}",
    ]
  }

  allow {
    protocol = "udp"

    ports = [
      "${var.serf_lan_port}",
      "${var.serf_wan_port}",
      "${var.dns_port}",
    ]
  }

  source_tags = ["${var.cluster_tag_name}"]
  target_tags = ["${var.cluster_tag_name}"]
}

# Specify which traffic is allowed into the Consul cluster for HTTP API requests
resource "google_compute_firewall" "allow_inbound_http_api" {
  count = "${length(var.allowed_inbound_cidr_blocks_dns) + length(var.allowed_inbound_tags_dns) > 0 ? 1 : 0}"

  name    = "${var.cluster_name}-rule-external-api-access"
  network = "${var.network_name}"

  allow {
    protocol = "tcp"

    ports = [
      "${var.http_api_port}",
      "${var.vault_port}",
    ]
  }

  source_ranges = "${var.allowed_inbound_cidr_blocks_http_api}"
  source_tags   = ["${var.allowed_inbound_tags_http_api}"]
  target_tags   = ["${var.cluster_tag_name}"]
}

# Specify which traffic is allowed into the Consul cluster for DNS requests
resource "google_compute_firewall" "allow_inbound_dns" {
  count = "${length(var.allowed_inbound_cidr_blocks_dns) + length(var.allowed_inbound_tags_dns) > 0 ? 1 : 0}"

  name    = "${var.cluster_name}-rule-external-dns-access"
  network = "${var.network_name}"

  allow {
    protocol = "tcp"

    ports = [
      "${var.dns_port}",
    ]
  }

  allow {
    protocol = "udp"

    ports = [
      "${var.dns_port}",
    ]
  }

  source_ranges = "${var.allowed_inbound_cidr_blocks_dns}"
  source_tags   = ["${var.allowed_inbound_tags_dns}"]
  target_tags   = ["${var.cluster_tag_name}"]
}

//Fetch image data
data "google_compute_image" "ubuntu_14_04_lts" {
  family  = "ubuntu-1404-lts"
  project = "ubuntu-os-cloud"
}

//Create a new instance
resource "google_compute_instance" "server" {
  name         = "server-${count.index}"
  machine_type = "n1-standard-1"
  count        = "${length(var.zones)}"
  zone         = "${element(var.zones, count.index)}"

  tags = ["${concat(var.http_https_network_tags, list(var.cluster_tag_name))}"]

  boot_disk {
    initialize_params {
      image = "${data.google_compute_image.ubuntu_14_04_lts.self_link}"
      size  = "40"
    }
  }

  network_interface {
    network = "default"

    access_config {
      # Exphemeral IP
      nat_ip = ""
    }
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }

  provisioner "salt-masterless" {
    "local_state_tree"    = "provisioning"
    "remote_state_tree"   = "/srv/salt"
    "local_pillar_roots"  = "provisioning/pillars"
    "remote_pillar_roots" = "/srv/pillars"

    # "minion_config_file"  = "provisioning/minion"

    connection {
      type = "ssh"
      user = "${var.ssh_user}"
    }
  }
}
