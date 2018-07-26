variable "project" {
  default = "rebirthdb-infra"
}

variable "region" {
  default = "us-east1"
}

variable "zones" {
  type = "list"

  default = ["us-east1-b", "us-east1-c", "us-east1-d"]
}

variable "network_name" {
  description = "The name of the VPC Network where all resources should be created."
  default     = "default"
}

variable "cluster_name" {
  description = "The name of the Consul cluster (e.g. consul-stage). This variable is used to namespace all resources created by this module."
  default     = "staging"
}

variable "cluster_tag_name" {
  description = "The tag name the Compute Instances will look for to automatically discover each other and form a cluster. TIP: If running more than one Consul Server cluster, each cluster should have its own unique tag name."
  default     = "staging"
}

variable "http_https_network_tags" {
  description = "List of the default network tags for http and https traffic"
  type        = "list"
  default     = ["http-server", "https-server"]
}

variable "allowed_inbound_cidr_blocks_http_api" {
  description = "A list of CIDR-formatted IP address ranges from which the Compute Instances will allow API connections to Consul."
  type        = "list"
  default     = ["0.0.0.0/0"]
}

variable "allowed_inbound_tags_http_api" {
  description = "A list of tags from which the Compute Instances will allow API connections to Consul."
  type        = "list"
  default     = []
}

variable "allowed_inbound_cidr_blocks_dns" {
  description = "A list of CIDR-formatted IP address ranges from which the Compute Instances will allow TCP DNS and UDP DNS connections to Consul."
  type        = "list"
  default     = ["0.0.0.0/0"]
}

variable "allowed_inbound_tags_dns" {
  description = "A list of tags from which the Compute Instances will allow TCP DNS and UDP DNS connections to Consul."
  type        = "list"
  default     = []
}

### Consul specific variables
variable "server_rpc_port" {
  description = "The port used by servers to handle incoming requests from other agents."
  default     = 8300
}

variable "cli_rpc_port" {
  description = "The port used by all agents to handle RPC from the CLI."
  default     = 8400
}

variable "serf_lan_port" {
  description = "The port used to handle gossip in the LAN. Required by all agents."
  default     = 8301
}

variable "serf_wan_port" {
  description = "The port used by servers to gossip over the WAN to other servers."
  default     = 8302
}

variable "http_api_port" {
  description = "The port used by clients to talk to the HTTP API"
  default     = 8500
}

variable "dns_port" {
  description = "The port used to resolve DNS queries."
  default     = 8600
}

variable "vault_port" {
  description = "The port used by Vault for communication"
  default     = 8200
}

variable "ssh_user" {
  description = "The user by which to ssh into the compute instance"
}
