terraform {
  backend "http" {
    address        = "https://api.abbey.io/terraform-http-backend"
    lock_address   = "https://api.abbey.io/terraform-http-backend/lock"
    unlock_address = "https://api.abbey.io/terraform-http-backend/unlock"
    lock_method    = "POST"
    unlock_method  = "POST"
  }

  required_providers {
    abbey = {
      source = "abbeylabs/abbey"
      version = "0.2.4"
    }
    vault = {
      source = "hashicorp/vault"
      version = "3.20.1"
    }
  }
}

provider "abbey" {
  # Configuration options
  bearer_auth = var.abbey_token
}

provider "vault" {
  # Configuration options
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
    { bundle = "github://replace-me-with-organization/replace-me-with-repo/policies" } # CHANGEME
  ]

  output = {
    # Replace with your own path pointing to where you want your access changes to manifest.
    # Path is an RFC 3986 URI, such as `github://{organization}/{repo}/path/to/file.tf`.
    location = "github://replace-me-with-organization/replace-me-with-repo/access.tf" # CHANGEME
    append = <<-EOT
      resource "vault_identity_group_member_entity_ids" "vault_group_{{ .data.system.abbey.identities.vault.user_id }}" { # {{ .data.system.abbey.identities.abbey.email }}
        exclusive = false
        member_entity_ids = ["{{ .data.system.abbey.identities.vault.user_id }}"]
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
    { bundle = "github://replace-me-with-organization/replace-me-with-repo/policies" } # CHANGEME
  ]

  output = {
    # Replace with your own path pointing to where you want your access changes to manifest.
    # Path is an RFC 3986 URI, such as `github://{organization}/{repo}/path/to/file.tf`.
    location = "github://replace-me-with-organization/replace-me-with-repo/access.tf" # CHANGEME
    append = <<-EOT
      resource "vault_identity_entity_policies" "vault_policy_{{ .data.system.abbey.identities.vault.user_id }}" { # {{ .data.system.abbey.identities.abbey.email }}
        exclusive = false
        entity_id = "{{ .data.system.abbey.identities.vault.user_id }}"
        policies = [ vault_policy.admin_policy.name ]
      }
    EOT
  }
}

resource "abbey_identity" "user_1" {
  abbey_account = "replace-me@example.com" # CHANGEME
  source = "vault"
  metadata = jsonencode({
    user_id = vault_identity_entity.user1.id
  })
}
