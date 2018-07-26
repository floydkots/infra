# Normal servers have version 1 of KV mounted by default, so will need these
# paths:
path "secret/driver-python/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Dev servers have version 2 of KV mounted by default, so will need these
# paths:
path "secret/data/driver-python/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
