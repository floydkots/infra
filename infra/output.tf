output "internal-ips" {
  value = "${google_compute_instance.server.*.network_interface.0.address}"
}

output "external-ips" {
  value = "${google_compute_instance.server.*.network_interface.0.access_config.0.assigned_nat_ip}"
}

output "cluster_name" {
  value = "${var.cluster_name}"
}

output "cluster_tag_name" {
  value = "${var.cluster_tag_name}"
}

output "firewall_rule_intracluster_url" {
  value = "${google_compute_firewall.allow_intracluster_consul.self_link}"
}

output "firewall_rule_intracluster_name" {
  value = "${google_compute_firewall.allow_intracluster_consul.name}"
}

output "firewall_rule_inbound_http_url" {
  value = "${element(concat(google_compute_firewall.allow_inbound_http_api.*.self_link, list("")), 0)}"
}

output "firewall_rule_inbound_http_name" {
  value = "${element(concat(google_compute_firewall.allow_inbound_http_api.*.name, list("")), 0)}"
}

output "firewall_rule_inbound_dns_url" {
  value = "${element(concat(google_compute_firewall.allow_inbound_dns.*.self_link, list("")), 0)}"
}

output "firewall_rule_inbound_dns_name" {
  value = "${element(concat(google_compute_firewall.allow_inbound_dns.*.name, list("")), 0)}"
}
