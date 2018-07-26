# Normal servers have version 1 of KV mounted by default, so will need these
# paths:
path "secret/infra/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Dev servers have version 2 of KV mounted by default, so will need these
# paths:
path "secret/data/infra/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
