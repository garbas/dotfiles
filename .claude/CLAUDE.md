# CLAUDE.md

This file provides guidance to Claude Code when working with code in
this repository.

## Working with the Repository Owner

### Documentation Organization

- **Claude-specific guidance**: Goes in `.claude/CLAUDE.md` (this file)
- **Project documentation**: Goes in root `README.md`
- **Subsystem documentation**: Goes in subdirectory READMEs (e.g.,
  `terraform/README.md`)

### Workflow Style

The repository owner prefers iterative refinement:

- Provide initial implementations based on requirements
- Expect multiple rounds of feedback to refine outputs
- Be prepared to adjust based on additional requirements that emerge
  during review
- Don't assume all requirements will be provided upfront - iterate and
  improve based on feedback

### TODO.md Management

The repository maintains a `TODO.md` file (all caps) for task tracking:

- **Location**: `/TODO.md` in repository root
- **Not tracked in Git**: This file is for local use only, do not commit it
- **Structure**: Three sections: Planning, In Progress, Done
- **Item Format**: Each item has a unique identifier:
  `- [ ] **#N** - Description`
- **Numbering**: Numbers are permanent - when items move to Done, their
  numbers stay with them
- **Moving items**: When completing a task, move from Planning/In Progress
  to Done and change `[ ]` to `[x]`

## Overview

This is a Nix flake-based dotfiles repository that manages multiple
machines (macOS via nix-darwin and Linux via NixOS) with integrated
Flox environment for development tools. The repository uses a
three-tier configuration architecture: machine-specific configs, shared
profiles, and platform-specific overrides.

## File Naming Conventions

The repository follows specific naming conventions for key files:

- **TODO.md** - All caps, not "Todo.md" or "to-do.md"
- **README.md** - Standard capitalization for documentation
- **CLAUDE.md** - All caps for Claude Code instructions

When referencing these files, use the exact capitalization as shown above.

## Architecture

### Configuration Hierarchy

1. **flake.nix** - Central orchestrator defining all inputs, outputs,
   and machine configurations
2. **Machine configs** - Minimal files importing appropriate profiles
   (e.g., `darwinConfigurations/jaime.nix`)
3. **Profile layer** - Shared configurations:
   - `profiles/common.nix` - Core settings across all systems
   - `profiles/darwin.nix` - macOS-specific home-manager config
   - `profiles/linux.nix` - Linux-specific home-manager config
   - `profiles/common_neovim.nix` - Neovim configuration (54KB)
   - `profiles/wayland.nix` - GUI/Wayland settings for Linux

### Machine Naming

Machines are named after Game of Thrones characters:

- **jaime** - macOS work machine (aarch64-darwin)
- **brienne** - macOS personal machine (aarch64-darwin)
- **cercei** - Linux VM (aarch64-linux)
- **floki** - Linux workstation (x86_64-linux)
- **pono** - Linux server (x86_64-linux)
- **solo**, **indigo** - Other systems

User credentials, SSH keys, and per-machine settings are centralized
in flake.nix (lines 205-231).

### Flox Integration

The repository integrates Flox for development tools and AI assistants:

- **Manifest location**: `flox/env/manifest.toml`
- **Custom packages**: `flox/pkgs/` (e.g., `claude-code.nix`)
- **Auto-activation**: Shell initialization runs `flox activate` on
  Darwin systems (see `homeConfigurations/profiles/darwin.nix:17`)

Key Flox packages include:

- AI tools: claude-code, codex, gemini-cli, amazon-q-cli, opencode
- MCP servers: flox-mcp-server, github-mcp-server, playwright-mcp
- CLI utilities: ripgrep, jq, tmux, 1password-cli
- Language runtimes: nodejs, cargo, rustc

### Flox Hooks and Profile

The Flox environment has two initialization phases:

**Phase 1: `on-activate` hooks** (runs first):

1. Authenticates with 1Password and loads secrets (ANTROPIC_API_KEY,
   OPENAI_API_KEY, HF_TOKEN)
2. On macOS: Syncs applications to `~/Applications/Flox (default) Apps`
   using mac-app-util

**Phase 2: `[profile]` section** (runs after hooks):

- **Automatic tmux session management**: When activating the Flox
  environment, a tmux session is automatically created or attached
- **Session name**: Controlled by `TMUX_SESSION_NAME` variable in `[vars]` section
  (default: "flox-session")
- **Smart behavior**: Skips tmux management when already in tmux, inside a
  Neovim terminal, or in a non-interactive shell
- **Consistent sessions**: Always uses the same session name across activations,
  allowing you to detach and reattach to the same session

To customize the tmux session name, edit the `TMUX_SESSION_NAME` variable in
`flox/env/manifest.toml`

## Common Commands

### System Management

```bash
# macOS: Rebuild and switch system configuration
darwin-rebuild switch --flake .#jaime

# Linux: Rebuild and switch NixOS configuration
sudo nixos-rebuild switch --flake .#floki

# Home Manager: Update user environment independently
home-manager switch --flake .#jaime
```

### Flake Operations

```bash
# Update all flake inputs
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs-unstable

# Check flake for errors
nix flake check

# Enter development shell
# Provides: nixd, nixfmt, opentofu, home-manager, darwin tools
nix develop
```

### Flox Environment

```bash
# Activate Flox environment (done automatically via .envrc and shell init)
flox activate

# Install package
flox install <package>

# Search for packages
flox search <term>

# List installed packages
flox list

# Edit manifest directly
vim flox/env/manifest.toml
```

### Testing Configuration Changes

```bash
# Test Darwin config without switching (build only)
nix build .#darwinConfigurations.jaime.system

# Test NixOS config without switching
nix build .#nixosConfigurations.floki.config.system.build.toplevel

# Test home-manager config
nix build .#homeConfigurations.jaime.activationPackage
```

## Git Configuration Strategy

The repository uses conditional git includes based on repository
remotes:

- **Personal repos** (`git@github.com:garbas/**`): Uses personal email
- **Work repos** (`git@github.com:flox/**`): Uses work email (Flox)

Commits are signed using SSH-based GPG signing.

### Commit Message Convention

**Format**: This repository follows the Conventional Commits specification.

All commit messages must follow this format:

```text
type(scope): subject

[optional body]

[optional footer]
```

**Commit Types:**

- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Formatting, missing semi-colons, etc (not CSS)
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `perf`: Performance improvement
- `test`: Adding or correcting tests
- `build`: Build system or dependency changes (Nix, Terraform, etc)
- `ci`: CI configuration changes
- `chore`: Other changes that don't modify src or test files
- `revert`: Reverts a previous commit

**Scope** is optional but recommended (e.g., `api`, `ui`, `terraform`,
`nix`, `flox`).

**Examples:**

- `feat(terraform): add Cloudflare R2 binary cache infrastructure`
- `fix(nix): resolve deprecated lspconfig usage`
- `docs: update installation instructions`
- `chore: bump flake dependencies`

**AI Attribution:** Do not include attribution messages like "Generated
with Claude Code" or "Co-Authored-By: Claude". Commits should appear as
regular user commits without AI attribution.

**Pre-commit Hooks:** The repository uses pre-commit hooks that run
automatically on commit:

- `markdownlint` - Markdown linting
- `nixfmt` - Nix code formatting
- `terraform-format` - Terraform/OpenTofu formatting (runs `tofu fmt`)
- `commitizen check` - Validates commit message format

These hooks auto-fix issues when possible (nixfmt, terraform-format) and
will block commits if validation fails (commitizen). You'll see the hook
results after each commit.

## Custom Vim Plugins

The flake includes a custom vim plugin builder (`mkCustomVimPlugins`)
that:

- Scans flake inputs prefixed with `vimPlugin-`
- Builds them as vim plugins with version metadata
- Makes them available to Neovim configuration

To add a new vim plugin:

1. Add input to flake.nix: `inputs.vimPlugin-<name>.url = "github:..."`
2. Set `inputs.vimPlugin-<name>.flake = false`
3. Reference as `custom-<name>` in Neovim config

## Remote Builders

Darwin machines are configured with Hetzner remote builders for Linux
builds:

- hetzner-aarch64-indigo-03 (aarch64-linux, 20 max jobs)
- hetzner-x86-64-indigo-04 (x86_64-linux, 8 max jobs)
- hetzner-x86-64-indigo-05 (x86_64-linux, 8 max jobs)

This enables cross-compilation without native Linux machines.

## Binary Caches

The flake is configured to use multiple substituters:

- cache.nixos.org - Official NixOS cache
- cache.flox.dev - Flox package cache
- devenv.cachix.org - Devenv cache

These significantly speed up builds by downloading pre-built binaries.

### Cloudflare R2 Nix Binary Cache

The repository includes Terraform/OpenTofu infrastructure for a
personal Nix binary cache using Cloudflare R2:

- **Location**: `terraform/` directory
- **Bucket**: `garbas-dotfiles-nix-cache`
- **Cost**: Free tier (10GB storage + unlimited egress)
- **Infrastructure as Code**: Managed via OpenTofu/Terraform

**Resources Created**:

- R2 bucket with auto location
- Read-write API token for GitHub Actions (uploading builds)
- Read-only API token for consumer machines (downloading builds)

**Setup Documentation**: See `terraform/README.md` for complete setup
instructions.

## Adding Packages

### For System-Wide Nix Packages

Edit `homeConfigurations/profiles/common.nix` and add to
`home.packages`.

### For Flox Packages

Edit `flox/env/manifest.toml` under `[install]` section.

### For Custom Nix Packages

1. Create package file in `flox/pkgs/<name>.nix`
2. Reference in `flox/env/manifest.toml`
3. Example: See `flox/pkgs/claude-code.nix`

## Platform-Specific Notes

### macOS (Darwin)

- Uses AeroSpace for i3-like tiling window management
- JankyBorders provides visual window borders
- Ghostty terminal with Catppuccin theme
- Homebrew integration via nix-darwin (see
  `darwinConfigurations/profiles/common.nix`)

### Linux (NixOS)

- Wayland-based systems use Hyprland or Sway
- Console-only systems use `profiles/console.nix`
- GUI systems additionally import `profiles/wayland.nix`

## Key Technologies

- **Shell**: Zsh with Powerlevel10k theme (config:
  `homeConfigurations/profiles/p10k.zsh`)
- **Editor**: Neovim with extensive LSP/plugin configuration
- **Terminal**: Ghostty
- **Multiplexer**: tmux with Catppuccin theme
- **Git UI**: lazygit with Catppuccin theme
- **Modern CLI**: bat, eza, ripgrep, fd, fzf, zoxide

## Direnv Integration

The `.envrc` file enables automatic environment loading via `use flake`.
This:

- Creates `.direnv/` cache with development tools
- Provides nixd (Nix LSP), nixfmt (formatter), OpenTofu, and build
  tools
- Activates automatically when entering the directory

## Terraform/OpenTofu Conventions

The repository uses OpenTofu (Terraform fork) for infrastructure
management with strict naming conventions:

### File Naming

- Files are named after the service they configure (e.g.,
  `cloudflare_r2.tf`)
- No hardcoded variables - use `variables.tf` for all inputs
- Outputs are included at the end of each service file, not in separate
  `outputs.tf`

### Resource Naming Pattern

All resource names must be **highly descriptive** and follow this
pattern:

```text
<filename_prefix>_<project>_<resource_type>_<purpose>_<specifics>
```

**Rules:**

1. **Always prefix with the filename** (without `.tf`): If the resource
   is in `cloudflare_r2.tf`, it starts with `cloudflare_r2_`
2. **Include project context**: Add `garbas_dotfiles` when the resource
   relates to this repository
3. **Be descriptive**: Names should be self-documenting - anyone reading
   the name should know what it does
4. **Longer names are okay**: Clarity > brevity

**Examples:**

- `cloudflare_r2_garbas_dotfiles_nix_binary_cache_bucket`
- `cloudflare_r2_garbas_dotfiles_nix_cache_readwrite_token_github_actions`
- `cloudflare_r2_garbas_dotfiles_nix_cache_readonly_token_consumers`

### Pre-commit Hooks

The development environment includes automatic formatting for Terraform
files:

- Hook: `terraform-format`
- Command: `tofu fmt`
- Files: All `.tf` files
- Auto-fix: Yes, files are automatically formatted on commit

See `terraform/README.md` for complete Terraform conventions and setup
documentation.

## GitHub Actions / YAML Conventions

### String Quoting

**All strings in YAML files must be double-quoted**, including:

- Workflow names
- Job names
- Step names
- Action versions
- Branch names
- Run commands
- Any other string values

**Example:**

```yaml
name: "CI"

on:
  push:
    branches: ["main"]
  pull_request:
    branches: ["main"]

jobs:
  check:
    runs-on: "ubuntu-latest"
    steps:
      - name: "Checkout repository"
        uses: "actions/checkout@v4"

      - name: "Install Nix"
        uses: "cachix/install-nix-action@v27"

      - name: "Run flake check"
        run: "nix flake check"
```

**Rationale:** Consistent quoting improves readability, prevents parsing
edge cases, and makes the style uniform across all YAML files.

## Troubleshooting

### Flox activation fails

Check 1Password authentication: `op signin --account my.1password.com`

### Darwin rebuild fails with "activation would overwrite"

Use `darwin-rebuild switch --flake .#<hostname> --impure` to allow
overwrites, or investigate conflicts.

### Home-manager conflicts

Clear old generations: `home-manager expire-generations "-7 days"`

### Build errors with remote builders

Check SSH access: `ssh hetzner-aarch64-indigo-03` and verify
nix-daemon is running on remote.

### Nix store issues

Run garbage collection: `nix-collect-garbage -d` (add `sudo` for
system-wide on NixOS)

- Add a name I can refer to or number to each of the issues in my to-do.md
