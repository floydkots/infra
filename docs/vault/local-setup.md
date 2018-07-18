# SET UP A NEW LOCAL VAULT SERVER
This set of instructions will guide an operator to set up a vault server locally using Keybase.

It would be preferrable that you first go through Vault's
[getting started guide](https://www.vaultproject.io/intro/getting-started/install.html) 
to gain some familiarity with Vault concepts and  terminologies.

## 1. Install and setup Keybase
We will use **Keybase** from [keybase.io](https://keybase.io)
for simple secure management of PGP keys.

At the [keybase.io download](https://keybase.io/download) page,
click the installation instructions link for your OS. Onwards,
we'll assume a 64 bit Ubuntu machine.

Follow the installation instructions to get started with 
Keybase. You'll be required to either login or signup after a
successfull installation. Thereafter, you will need to prove 
at least one of your online identities. In this case, proving
your github identity is the most relevant.

In case you don't have a PGP key yet, or want to generate a new
one run:
```
$ keybase pgp gen
```
This will generate your new PGP key and write it to your local
secret keychain.

## 2. Install Consul
We will use [Consul](https://www.consul.io) as Vault's storage
backend.

Follow Consul's [installation instructions](https://www.consul.io/intro/getting-started/install.html)
to install Consul on your machine in case you don't have it 
already installed.

## 3. Install Vault
We will use [Vault](https://www.vaultproject.io) to securely
manage RebirthDB's secrets.

Follow Vault's [installation instructions](https://www.vaultproject.io/docs/install/index.html)
to install Vault on your machine in case you don't have it
already installed.

## 4. Configure Vault
### a) Create Vault's configuration file
Create the directory from which we will work.
```
$ mkdir vault && cd vault
```

Copy and paste the configuration below to a file called
`config.hcl`. This will be Vault's basic configuration.
```
# Physical backend that Vault will use for storage
storage "consul" {
  address = "127.0.0.1:8500"
  path    = "vault/"
}

# Determine how Vault listens for API requests.
listener "tcp" {
 address     = "127.0.0.1:8200"
 tls_disable = 1
}
```

### b) Start the Consul instance
In another terminal, execute the following command:
```
$ consul agent -dev
```
This will start the Consul agent in development mode, which is
useful for bringing up a single-node Consul environment quickly
and easily.

### c) Start the Vault server
Run the following command:
```
$ vault server -config=config.hcl
==> Vault server configuration:

         Log Level: info
           Storage: consul
        Listener 1: tcp (addr: "127.0.0.1:8200", tls: "disabled")

==> Vault server started! Log data will stream in below:
```

Vault may fail to start with the following error:
```
$ vault server -config=example.hcl
Error initializing core: Failed to lock memory: cannot allocate memory

This usually means that the mlock syscall is not available.
Vault uses mlock to prevent memory from being swapped to
disk. This requires root privileges as well as a machine
that supports mlock. Please enable mlock on your system or
disable Vault from using it. To disable Vault from using it,
set the `disable_mlock` configuration option in your configuration
file.
```
For guidance on dealing with this issue, see the discussion of `disable_mlock` in the [Server Configuration](https://www.vaultproject.io/docs/configuration/index.html) docs.


## 5. Initialize the Vault
To initialize and unseal vault, we need to generate the unseal key.
Run the following command:
```
$ vault operator init -key-shares=1 -key-threshold=1 \
    -pgp-keys="keybase:<username>"

Unseal Key 1: wcFMAyDT8Ig+h+G+ARAAVzXK8oT3uKec+u/SnyBkbHSYohfby375F83oH+KtqUv0bx42ig8PASQEI6LP1KqqY7kmxUbxdutas2Kgn2SLp+Sfs36LxMGWF3XpKhnZo2q7Aee9qGXNiiEvCL/wM82HsebFmooZ+mp53XLMFTgV3FVmXD1kym40CtQqO+s64da5jiTttvV+uQEK9+wgj2UgfpP7XfHoWjX2ioufTuSZ0T+Yg1uZegv7lvDYlfK724BXfjLeHUOonAkBeHISXa4ZGgpwWypqxtatd4BRP6PSfwFf1JlCGv6GppYBcPuYlV9D4UMfrKy9Xzy1YL3H8AYrEsOIXT4zK4iQrrR1OeSsIqS2vQuGvh31WVKjoWkZw4nj+H0b0IaO+t8tCBfdQtRzATzIo309YPHTbEs30x/tJdg1VvvrsMygkwjBfrZWrJTEpnDX6tyHjrS+olayV+T7C/selqby7zTzQNp3vNlb+EVjHJHRZqg3sqqG2Vhp6TqV4LUFmMU0Gqq6sXtqqoXcW2pLhfRiw4495oMiKVjhnliCvMW+JlVpyP2reZ/tlKbGN2tOM93ziKFcJgnaV0KV4TSbUMjl1oTMJ8AoLkg1SHlfayVGaOOMtn2nhQEjhVw+VnsuPJjV+IqP7sZ+W85I9gsEb90/a5JgXh/EkfuTJzh/YxUgf/uTX0C4PHEGRiDS4AHk+1NZdj3vmZ+v7h/OkarJJeFY2eAk4PDhGTbgCeKgDyRR4FPmpqkCxMkfhLp4j04vyFROhFoyHwVwi9YoivDiJ2+10Dfz1LItsMLlegRN+5ZvC2a53HMKNgdtg33MugKF88W0UOAt5LvuqnBz/yCnMCN0rJPNcg3iJ29mSOHsQAA=

Initial Root Token: b0a1f35f-92da-2abc-2b1a-1d47b320fc1d

...
...
```

Replace `keybase:<username>` with your keybase username e.g 
`keybase:floydkots`. This will generate one encrypted, base64
unseal key. Decrypt this key by running:
```
$ echo "wcFMAyD..." | base64 -d | keybase pgp decrypt
```
Replace `wcFMAyD...` with the encrypted key. You will be prompted
to enter your Keybase passphrase. The output will be the plain-text
unseal key.
```
6ecb46277133e04b29bd0b1b05e60722dab7cdc684a0d3ee2de50ce4c38a357101
```
This is your unseal key in plain text and it should be guarded the
same way you guard a password.

Now run:
```
$ vault operator unseal
Key (will be hidden): ...
```

## 6. Enable Github auth
First, login using the `Initial Root Token`.
```
$ vault login b0a1f35f-92da-2abc-2b1a-1d47b320fc1d
```

Then enable the github auth method:
```
$ vault auth enable github
```

Next, configure the Github auth method.
```
$ vault write auth/github/config organization=rebirthdb
Success! Data written to: auth/github/config
```
This will configure Vault to pull authentication data from the
"rebirthdb" organization on GitHub.

Then map your GitHub team to a policy.
```
$ vault write auth/github/map/teams/<team> value=deafult,<team>-policy
```
For the "driver-python" team, that would be:
```
$ vault write auth/github/map/teams/driver-python value=default,driver-python-policy
Success! Data written to: auth/github/map/teams/driver-python
```
This will tell Vault to map any users who are members of the team
"driver-python" (in the rebirthdb organization) to the policies
"default" and "driver-python-policy".
These policies do not exist yet, we will create them.

## 7. Write the policy
Copy and paste the following policy into a file called `<team>-policy.hcl`.
```
# Normal servers have version 1 of KV mounted by default, so will
# need these paths:
path "secret/<team>/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Dev servers have version 2 of KV mounted by default, so will 
# need these paths:
path "secret/data/<team>/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
```
Replace `<team>` in both the file name and paths with the team's
actual name. This policy gives full permissions to the team
members for the secrets under their path.

Thereafter write the policy by running:
```
$ vault policy write <team>-policy <team>-policy.hcl
Success! Uploaded policy: <team>-policy
```

## 8. Login as a GitHub user and test the policy
[Create your personal access token from GitHub](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/)
in case you don't have one already.

Run the following command to login via github and paste in your
Personal Access Token when required.
```
$ vault login -method=github
GitHub Personal Access Token (will be hidden):
Success! You are now authenticated. The token information
displayed below is already stored in the token helper. You do NOT
need to run "vault login" again. Future Vault requests will
automatically use this token.

...
...
```

To test the policy, run:
```
$ vault kv put secret/<team>/qualities friendliness=excellent
Success! Data written to: secret/<team>/qualities

$ vault kv put secret/<another-team>/qualities skills=super
Error writing data to secret/<another-team>/qualities: Error making API request.

URL: PUT http://127.0.0.1:8200/v1/secret/<another-team>/qualities
Code: 403. Errors:

* permission denied
```

As usual, replace `<team>` and `<another-team>` with the respective
team names.



