# Inject secrets into Terraform using the Vault provider

This repo serves as a companion to the [Inject secrets into Terraform using the Vault provider Learn guide](https://learn.hashicorp.com/terraform/secrets/inject-secrets-with-vault).

Modified for internal HashiCorp use with Doormat.

## Steps

### Set up Environment

These are referred to by "Required Env" in the following steps.

#### Doormat

[Doormat CLI](https://docs.prod.secops.hashicorp.services/doormat/cli/)
is very convenient!

```shell
account="engserv_sandbox_dev"  # replace with your account name
eval "$(doormat aws --account $account)"
```

#### Vault

```shell
export VAULT_ADDR="http://127.0.0.1:8200"
export VAULT_TOKEN="education"
```

### Run Vault

* Required Env: Doormat

```shell
vault server -dev -dev-root-token-id="education"
```

Vault will use the AWS creds in its environment to assume an AWS role.

### Run TF: vault-admin-workspace

This creates an AWS role and a Vault role that will enable
Vault to assume the AWS role.  (Not confusing at all.)

* Required Env: Doormat, Vault

```shell
terraform init
terraform apply
```

### Run TF: operator-workspace

This asks Vault to provision temporary credentials
via the aforementioned roles, then builds an EC2 instance.

* Required Env: Vault

```shell
terraform init
terraform apply
```

### Teardown

Destroy everything.

* Required Env: Doormat, Vault

```shell
cd operator-workspace
terraform destroy
cd ../vault-admin-workspace
terraform destroy
```

And ctrl+c or otherwise kill the running vault process in whatever terminal you had it in.
