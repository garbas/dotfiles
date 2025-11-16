# R2 Bucket for Nix Binary Cache
resource "cloudflare_r2_bucket" "cloudflare_r2_garbas_dotfiles_nix_binary_cache_bucket" {
  account_id = var.cloudflare_account_id
  name       = "garbas-dotfiles-nix-cache"
  location   = "auto"
}

# Read-Write API Token for GitHub Actions (uploading builds)
resource "cloudflare_api_token" "cloudflare_r2_garbas_dotfiles_nix_cache_readwrite_token_github_actions" {
  name = "garbas-dotfiles-nix-cache-readwrite-github-actions"

  policy {
    permission_groups = [
      # Object Read & Write permissions
      data.cloudflare_api_token_permission_groups.cloudflare_r2_permission_groups.r2["Workers R2 Storage Write"],
      data.cloudflare_api_token_permission_groups.cloudflare_r2_permission_groups.r2["Workers R2 Storage Read"],
    ]

    resources = {
      "com.cloudflare.edge.r2.bucket.${var.cloudflare_account_id}_default_${cloudflare_r2_bucket.cloudflare_r2_garbas_dotfiles_nix_binary_cache_bucket.name}" = "*"
    }
  }
}

# Read-Only API Token for consumer machines (downloading builds)
resource "cloudflare_api_token" "cloudflare_r2_garbas_dotfiles_nix_cache_readonly_token_consumers" {
  name = "garbas-dotfiles-nix-cache-readonly-consumers"

  policy {
    permission_groups = [
      # Object Read only
      data.cloudflare_api_token_permission_groups.cloudflare_r2_permission_groups.r2["Workers R2 Storage Read"],
    ]

    resources = {
      "com.cloudflare.edge.r2.bucket.${var.cloudflare_account_id}_default_${cloudflare_r2_bucket.cloudflare_r2_garbas_dotfiles_nix_binary_cache_bucket.name}" = "*"
    }
  }
}

# Data source for R2 permission groups
data "cloudflare_api_token_permission_groups" "cloudflare_r2_permission_groups" {}

# ============================================================================
# Outputs
# ============================================================================

output "cloudflare_r2_bucket_name" {
  description = "Name of the R2 bucket"
  value       = cloudflare_r2_bucket.cloudflare_r2_garbas_dotfiles_nix_binary_cache_bucket.name
}

output "cloudflare_r2_bucket_endpoint" {
  description = "S3-compatible endpoint URL for the R2 bucket"
  value       = "https://${var.cloudflare_account_id}.r2.cloudflarestorage.com"
}

output "cloudflare_r2_nix_substituter_url" {
  description = "Nix substituter URL for use in nix.conf"
  value       = "s3://${cloudflare_r2_bucket.cloudflare_r2_garbas_dotfiles_nix_binary_cache_bucket.name}?endpoint=${var.cloudflare_account_id}.r2.cloudflarestorage.com&region=auto"
}

output "cloudflare_r2_readwrite_token_value" {
  description = "Read-write API token for GitHub Actions (SENSITIVE - for CI/CD only)"
  value       = cloudflare_api_token.cloudflare_r2_garbas_dotfiles_nix_cache_readwrite_token_github_actions.value
  sensitive   = true
}

output "cloudflare_r2_readonly_token_value" {
  description = "Read-only API token for consumer machines (SENSITIVE)"
  value       = cloudflare_api_token.cloudflare_r2_garbas_dotfiles_nix_cache_readonly_token_consumers.value
  sensitive   = true
}

output "cloudflare_r2_readwrite_token_id" {
  description = "Read-write API token ID for GitHub Actions"
  value       = cloudflare_api_token.cloudflare_r2_garbas_dotfiles_nix_cache_readwrite_token_github_actions.id
}

output "cloudflare_r2_readonly_token_id" {
  description = "Read-only API token ID for consumer machines"
  value       = cloudflare_api_token.cloudflare_r2_garbas_dotfiles_nix_cache_readonly_token_consumers.id
}

output "cloudflare_r2_setup_instructions" {
  description = "Next steps after terraform apply"
  value       = <<-EOT

    ===== Cloudflare R2 Nix Binary Cache Setup =====

    1. Retrieve API tokens (sensitive output):
       tofu output -raw cloudflare_r2_readwrite_token_value
       tofu output -raw cloudflare_r2_readonly_token_value

    2. Generate Nix signing keys on your build machine:
       sudo nix-store --generate-binary-cache-key garbas-dotfiles-nix-cache-1 \
         /etc/nix/cache-priv-key.pem \
         /etc/nix/cache-pub-key.pem
       sudo chmod 600 /etc/nix/cache-priv-key.pem
       cat /etc/nix/cache-pub-key.pem

    3. Add GitHub Secrets for CI/CD:
       - R2_ACCESS_KEY_ID: (read-write token ID from above)
       - R2_SECRET_ACCESS_KEY: (read-write token value from above)

    4. Configure Nix substituters on all machines:
       substituters = s3://${cloudflare_r2_bucket.cloudflare_r2_garbas_dotfiles_nix_binary_cache_bucket.name}?endpoint=${var.cloudflare_account_id}.r2.cloudflarestorage.com&region=auto
       trusted-public-keys = <your-public-key-from-step-2>

    5. Upload builds from GitHub Actions:
       nix copy --to 's3://${cloudflare_r2_bucket.cloudflare_r2_garbas_dotfiles_nix_binary_cache_bucket.name}?endpoint=${var.cloudflare_account_id}.r2.cloudflarestorage.com&region=auto' ./result

    See terraform/README.md for complete documentation.
  EOT
}
