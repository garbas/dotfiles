# Terraform / OpenTofu Infrastructure

This directory contains Terraform/OpenTofu configuration for managing
infrastructure resources for the dotfiles repository.

## Terraform Naming Conventions

This repository follows strict naming conventions for Terraform resources
to ensure clarity and maintainability:

### File Naming

- Files are named after the service they configure (e.g.,
  `cloudflare_r2.tf`)
- No hardcoded variables - use `variables.tf` for all inputs
- Outputs are included at the end of each service file, not in separate
  `outputs.tf`

### Resource Naming

All resource names must be **highly descriptive** and follow this pattern:

```text
<filename_prefix>_<project>_<resource_type>_<purpose>_<specifics>
```

**Rules:**

1. **Always prefix with the filename** (without `.tf`): If the resource is
   in `cloudflare_r2.tf`, it starts with `cloudflare_r2_`
2. **Include project context**: Add `garbas_dotfiles` when the resource
   relates to this repository
3. **Be descriptive**: Names should be self-documenting - anyone reading
   the name should know what it does
4. **Longer names are okay**: Clarity > brevity

**Examples:**

- `cloudflare_r2_garbas_dotfiles_nix_binary_cache_bucket`
- `cloudflare_r2_garbas_dotfiles_nix_cache_readwrite_token_github_actions`
- `cloudflare_r2_garbas_dotfiles_nix_cache_readonly_token_consumers`

**Bad examples** (don't do this):

- `nix_cache` - Missing file prefix
- `r2_bucket` - Not descriptive enough
- `bucket` - Way too generic

## Current Infrastructure

### Cloudflare R2 - Nix Binary Cache

**File**: `cloudflare_r2.tf`

Manages a Cloudflare R2 bucket for storing Nix build artifacts as a binary
cache.

**Resources:**

- R2 bucket: `garbas-dotfiles-nix-cache`
- Read-write API token for GitHub Actions (uploading builds)
- Read-only API token for consumer machines (downloading builds)

**Cost:** Free tier includes 10GB storage + unlimited egress

## Prerequisites

1. **OpenTofu** or **Terraform** installed (>= 1.0)

   ```bash
   # Install OpenTofu (recommended)
   brew install opentofu

   # Or Terraform
   brew install terraform
   ```

2. **Cloudflare Account** with R2 enabled

3. **Cloudflare API Token** with R2 permissions:
   - Go to <https://dash.cloudflare.com/profile/api-tokens>
   - Click "Create Token"
   - Use "Edit Cloudflare Workers" template or create custom with:
     - Account.Cloudflare R2 (Edit)
   - Note your token (shown only once!)

4. **Cloudflare Account ID**:
   - Find at <https://dash.cloudflare.com/>
   - Look in URL or account settings

## Initial Setup

### 1. Create Variables File

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your credentials:

```hcl
cloudflare_api_token  = "your-actual-token-here"
cloudflare_account_id = "your-account-id-here"
```

**IMPORTANT**: Never commit `terraform.tfvars` - it contains secrets!

### 2. Initialize Terraform

```bash
tofu init
# or: terraform init
```

This downloads the Cloudflare provider.

### 3. Review the Plan

```bash
tofu plan
# or: terraform plan
```

Review what will be created. You should see:

- 1 R2 bucket
- 2 API tokens (read-write, read-only)
- Several outputs

### 4. Apply Configuration

```bash
tofu apply
# or: terraform apply
```

Type `yes` to confirm.

## Post-Deployment Setup

After running `tofu apply`, follow these steps:

### 1. Retrieve API Tokens

```bash
# Get read-write token for GitHub Actions
tofu output -raw cloudflare_r2_readwrite_token_value

# Get read-only token for consumer machines
tofu output -raw cloudflare_r2_readonly_token_value
```

**IMPORTANT**: Save these securely! Treat them like passwords.

### 2. Generate Nix Signing Keys

On any machine (or in CI), generate cache signing keys:

```bash
sudo nix-store --generate-binary-cache-key \
  garbas-dotfiles-nix-cache-1 \
  /etc/nix/cache-priv-key.pem \
  /etc/nix/cache-pub-key.pem

sudo chmod 600 /etc/nix/cache-priv-key.pem
sudo chmod 644 /etc/nix/cache-pub-key.pem

# Display public key (share this with all machines)
cat /etc/nix/cache-pub-key.pem
```

Save the public key - you'll need it for all machines.

### 3. Configure GitHub Actions

Add these secrets to your GitHub repository:

Go to: Settings → Secrets and variables → Actions → New repository secret

- `R2_ACCESS_KEY_ID`: (read-write token ID from step 1)
- `R2_SECRET_ACCESS_KEY`: (read-write token value from step 1)
- `NIX_CACHE_PRIVATE_KEY`: (contents of `/etc/nix/cache-priv-key.pem`)

### 4. Configure Nix on Local Machines

Get the substituter URL:

```bash
tofu output -raw cloudflare_r2_nix_substituter_url
```

Add to your `flake.nix` or machine configuration:

```nix
{
  nix.settings = {
    substituters = [
      "https://cache.nixos.org"
      "s3://garbas-dotfiles-nix-cache?endpoint=<account-id>.r2.cloudflarestorage.com&region=auto"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "garbas-dotfiles-nix-cache-1:<your-public-key-from-step-2>"
    ];
  };
}
```

For consumer machines (read-only), you can optionally use the read-only
token by configuring AWS credentials:

```bash
# In ~/.aws/credentials
[nix-cache-readonly]
aws_access_key_id = <readonly-token-id>
aws_secret_access_key = <readonly-token-value>
```

Then use `&profile=nix-cache-readonly` in the substituter URL.

## Usage

### Uploading to Cache (GitHub Actions)

In your GitHub Actions workflow:

```yaml
- name: Upload to R2 Cache
  env:
    AWS_ACCESS_KEY_ID: ${{ secrets.R2_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.R2_SECRET_ACCESS_KEY }}
  run: |
    nix copy --to 's3://garbas-dotfiles-nix-cache?endpoint=<account-id>.r2.cloudflarestorage.com&region=auto' ./result
```

### Manual Upload (Local)

```bash
# Build something
nix build .#mypackage

# Upload to cache
nix copy --to 's3://garbas-dotfiles-nix-cache?endpoint=<account-id>.r2.cloudflarestorage.com&region=auto' ./result
```

### Downloading from Cache

Once configured in `nix.settings`, downloads happen automatically:

```bash
# Nix will check R2 before building
nix build .#mypackage
```

## Viewing Outputs

```bash
# List all outputs
tofu output

# Get specific output
tofu output cloudflare_r2_bucket_name
tofu output cloudflare_r2_nix_substituter_url

# Get sensitive outputs (API tokens)
tofu output -raw cloudflare_r2_readwrite_token_value
tofu output -raw cloudflare_r2_readonly_token_value

# View setup instructions
tofu output -raw cloudflare_r2_setup_instructions
```

## Updating Infrastructure

After making changes to `.tf` files:

```bash
# Review changes
tofu plan

# Apply changes
tofu apply
```

## Destroying Resources

**WARNING**: This will delete the R2 bucket and all cached builds!

```bash
tofu destroy
```

## Cost Information

### Cloudflare R2 Free Tier

- **Storage**: 10GB per account (pooled across all buckets)
- **Class A Operations** (writes): 10 million/month
- **Class B Operations** (reads): 1 million/month
- **Egress**: Unlimited (free forever!)

### After Free Tier

- **Storage**: $0.015/GB/month
- **Class A Operations**: $4.50/million requests
- **Class B Operations**: $0.36/million requests
- **Egress**: $0 (always free!)

**Estimated cost for 100GB**: ~$1.50/month (just storage, no egress!)

## Troubleshooting

### "Error: Invalid API Token"

- Verify your token has R2 permissions
- Check token hasn't expired
- Ensure `cloudflare_api_token` in `terraform.tfvars` is correct

### "Error: Account ID not found"

- Double-check `cloudflare_account_id` in `terraform.tfvars`
- Ensure your token is scoped to the correct account

### "Error: Bucket already exists"

- R2 bucket names must be globally unique
- Try a different bucket name in `cloudflare_r2.tf`

### "Error: Resource not found" after destroying

- Run `tofu init` to refresh state
- Check if resources were manually deleted in Cloudflare dashboard

### Nix can't access R2 bucket

- Verify AWS credentials are set correctly
- Check region is `auto` not a specific AWS region
- Ensure endpoint URL matches your account ID
- Try with `-vvv` flag for verbose Nix output:

  ```bash
  nix copy -vvv --to 's3://...' ./result
  ```

## Security Best Practices

1. **Never commit secrets**:
   - `terraform.tfvars` is in `.gitignore`
   - Sensitive outputs are marked `sensitive = true`
   - Use `tofu output -raw` to view sensitive values

2. **Use read-only tokens** where possible:
   - GitHub Actions: read-write token (needs to upload)
   - Consumer machines: read-only token (only downloads)

3. **Rotate tokens periodically**:
   - Generate new API tokens in Cloudflare dashboard
   - Update `terraform.tfvars` and run `tofu apply`
   - Update GitHub secrets

4. **Limit token scope**:
   - Tokens are scoped to specific bucket
   - Can't access other R2 buckets or Cloudflare resources

5. **Monitor usage**:
   - Check Cloudflare R2 dashboard for storage/bandwidth usage
   - Set up billing alerts if approaching free tier limits

## Additional Resources

- [Cloudflare R2 Documentation](https://developers.cloudflare.com/r2/)
- [Nix S3 Binary Cache](https://nix.dev/manual/nix/stable/package-management/s3-substituter)
- [OpenTofu Documentation](https://opentofu.org/docs/)
- [Terraform Cloudflare Provider](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs)

## Support

For issues with:

- Terraform configuration: See `terraform/` directory files
- Nix cache setup: See main repository README.md
- Cloudflare R2: Check Cloudflare dashboard and docs
