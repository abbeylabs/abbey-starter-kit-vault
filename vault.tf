# Create admin policy in the root namespace
resource "vault_policy" "admin_policy" {
  name   = "admins"
  policy = file("policies/admin-policy.hcl")
}

resource "vault_identity_group" "oncall" {
  name = "oncall"
  type = "internal"
  policies = [ "admins" ]
}

resource "vault_identity_entity" "user1" {
  name = "user1"
}
