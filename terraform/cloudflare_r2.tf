# R2 Bucket for Nix Binary Cache
resource "cloudflare_r2_bucket" "cloudflare_r2_garbas_dotfiles_nix_binary_cache_bucket" {
  account_id = var.cloudflare_account_id
  name       = "garbas-dotfiles-nix-cache"
  location   = "ENAM" # Eastern North America
}

# NOTE: API Token creation requires user-level authentication and cannot be done
# with account-scoped API tokens. Create these tokens manually via the Cloudflare dashboard:
# https://dash.cloudflare.com/profile/api-tokens
#
# Required tokens:
# 1. Read-Write Token (for GitHub Actions):
#    - Name: garbas-dotfiles-nix-cache-readwrite-github-actions
#    - Permissions: Workers R2 Storage (Read & Write)
#    - Resources: Specific bucket (garbas-dotfiles-nix-cache)
#
# 2. Read-Only Token (for consumers):
#    - Name: garbas-dotfiles-nix-cache-readonly-consumers
#    - Permissions: Workers R2 Storage (Read)
#    - Resources: Specific bucket (garbas-dotfiles-nix-cache)

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

output "cloudflare_r2_setup_instructions" {
  description = "Next steps after terraform apply"
  value       = <<-EOT

    ===== Cloudflare R2 Nix Binary Cache Setup =====

    1. Create API tokens manually at https://dash.cloudflare.com/profile/api-tokens:

       a) Read-Write Token (for GitHub Actions):
          - Name: garbas-dotfiles-nix-cache-readwrite-github-actions
          - Permissions: Account > Workers R2 Storage > Edit
          - Account Resources: Include > Specific account > ${var.cloudflare_account_id}
          - R2 Bucket Resources: Include > Specific bucket > ${cloudflare_r2_bucket.cloudflare_r2_garbas_dotfiles_nix_binary_cache_bucket.name}

       b) Read-Only Token (for consumer machines):
          - Name: garbas-dotfiles-nix-cache-readonly-consumers
          - Permissions: Account > Workers R2 Storage > Read
          - Account Resources: Include > Specific account > ${var.cloudflare_account_id}
          - R2 Bucket Resources: Include > Specific bucket > ${cloudflare_r2_bucket.cloudflare_r2_garbas_dotfiles_nix_binary_cache_bucket.name}

    2. Generate Nix signing keys on your build machine:
       sudo nix-store --generate-binary-cache-key garbas-dotfiles-nix-cache-1 \
         /etc/nix/cache-priv-key.pem \
         /etc/nix/cache-pub-key.pem
       sudo chmod 600 /etc/nix/cache-priv-key.pem
       cat /etc/nix/cache-pub-key.pem

    3. Add GitHub Secrets for CI/CD using the read-write token:
       - R2_ACCESS_KEY_ID: <Access Key ID from token>
       - R2_SECRET_ACCESS_KEY: <Secret Access Key from token>

    4. Configure Nix substituters on all machines using the read-only token:
       substituters = s3://${cloudflare_r2_bucket.cloudflare_r2_garbas_dotfiles_nix_binary_cache_bucket.name}?endpoint=${var.cloudflare_account_id}.r2.cloudflarestorage.com&region=auto
       trusted-public-keys = <your-public-key-from-step-2>

    5. Upload builds from GitHub Actions:
       nix copy --to 's3://${cloudflare_r2_bucket.cloudflare_r2_garbas_dotfiles_nix_binary_cache_bucket.name}?endpoint=${var.cloudflare_account_id}.r2.cloudflarestorage.com&region=auto' ./result

    See terraform/README.md for complete documentation.
  EOT
}
