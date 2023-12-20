locals {
  account_name = ""
  repo_name = ""

  project_path = "github://${local.account_name}/${local.repo_name}"
  policies_path = "${local.project_path}/policies"
}

resource "abbey_grant_kit" "vault_oncall_group" {
  name = "vault_oncall_group"
  description = "Assign me to the vault oncall group"

  workflow = {
    steps = [
      {
        reviewers = {
          one_of = ["replace-me@example.com"] # CHANGEME
        }
      }
    ]
  }

  policies = [
    { bundle = local.policies_path }
  ]

  output = {
    location = "${local.project_path}/access.tf"
    append = <<-EOT
      resource "vault_identity_group_member_entity_ids" "vault_group_{{ .user.vault.user_id }}" { # {{ .user.email }}
        exclusive = false
        member_entity_ids = ["{{ .user.vault.user_id }}"]
        group_id = vault_identity_group.oncall.id
      }
    EOT
  }
}

resource "abbey_grant_kit" "vault_admin_policy" {
  name = "vault_admin_policy"
  description = "Assign the admin policy to my account"

  workflow = {
    steps = [
      {
        reviewers = {
          one_of = ["replace-me@example.com"] # CHANGEME
        }
      }
    ]
  }

  policies = [
    { bundle = local.policies_path }
  ]

  output = {
    location = "${local.project_path}/access.tf"
    append = <<-EOT
      resource "vault_identity_entity_policies" "vault_policy_{{ .user.vault.user_id }}" { # {{ .user.email }}
        exclusive = false
        entity_id = "{{ .user.vault.user_id }}"
        policies = [ vault_policy.admin_policy.name ]
      }
    EOT
  }
}
