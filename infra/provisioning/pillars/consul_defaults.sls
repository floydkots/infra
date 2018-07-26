consul:
  # Start Consul agent service and enable it at boot time
  service: True

  # Set user and group for Consul config files and running service
  user: consul
  group: consul

  config:
    server: True
    bind_addr: 0.0.0.0
    client_addr: 0.0.0.0
    enable_debug: False
    datacenter: us-east1-gce
    encrypt: "RIxqpNlOXqtr/j4BgvIMEw=="
    bootstrap_expect: 3
    retry_interval: 15s
    retry_join: ["provider=gce project_name=rebirthdb-infra tag_value=staging"]

