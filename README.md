# ❄️ All the Nix I have, enjoy! 🎉

> ✨ A magical Nix flake-based dotfiles repository managing multiple machines
> with integrated Flox environment for development tools

<div align="center">

**🍎 macOS** · **🐧 Linux** · **🚀 Cross-platform** · **⚡ Fast**

</div>

---

## ✨ Features

- 🌍 **Multi-platform support**: macOS (nix-darwin) and Linux (NixOS)
- 🔗 **Unified configuration**: Shared profiles with platform-specific
  overrides
- 📦 **Flox integration**: Development tools and AI assistants in reproducible
  environments
- ☁️ **Remote builders**: Hetzner cloud builders for cross-platform
  compilation
- 🛠️ **Modern tooling**: Neovim, Ghostty terminal, tmux, and extensive CLI
  utilities

## 🏗️ Architecture

### 📋 Configuration Hierarchy

1. **flake.nix** 🎯 - Central orchestrator defining all inputs, outputs, and
   machine configurations
2. **Machine configs** 💻 - Minimal files in `darwinConfigurations/` and
   `nixosConfigurations/`
3. **Profile layer** 📁 - Shared configurations in `profiles/`:
   - `common.nix` - Core settings across all systems
   - `darwin.nix` - macOS-specific home-manager config
   - `linux.nix` - Linux-specific home-manager config
   - `common_neovim.nix` - Neovim configuration
   - `wayland.nix` - GUI/Wayland settings for Linux

### 🐉 Machine Naming

Machines are named after Game of Thrones characters:

- **jaime** ⚔️ - macOS work machine (aarch64-darwin)
- **brienne** 🛡️ - macOS personal machine (aarch64-darwin)
- **cercei** 👑 - Linux VM (aarch64-linux)
- **floki** ⚓ - Linux workstation (x86_64-linux)
- **pono** 🏰 - Linux server (x86_64-linux)

## 📋 Prerequisites

### 🍎 For macOS

1. Install Nix with the Determinate Systems installer (supports macOS with
   Flakes enabled):

   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

2. Install nix-darwin:

   ```bash
   nix run nix-darwin -- switch --flake .#<hostname>
   ```

### 🐧 For Linux (NixOS)

NixOS should already have Nix installed. Ensure Flakes are enabled in
`/etc/nixos/configuration.nix`:

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

### 📦 For Flox

Install Flox:

```bash
curl -fsSL https://downloads.flox.dev/by-env/stable/install.sh | bash
```

## 🚀 Installation

1. Clone this repository:

   ```bash
   git clone git@github.com:garbas/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. Install direnv (optional but recommended):

   ```bash
   # macOS
   brew install direnv

   # NixOS - already included in configuration
   ```

3. Allow direnv to load the development environment:

   ```bash
   direnv allow
   ```

4. Build and activate configuration:

   **For macOS:**

   ```bash
   darwin-rebuild switch --flake .#<hostname>
   # Example: darwin-rebuild switch --flake .#jaime
   ```

   **For Linux (NixOS):**

   ```bash
   sudo nixos-rebuild switch --flake .#<hostname>
   # Example: sudo nixos-rebuild switch --flake .#floki
   ```

5. Activate the Flox environment (done automatically via shell init on
   Darwin):

   ```bash
   flox activate
   ```

## 💻 Usage

### 🔧 System Management

```bash
# macOS: Rebuild and switch system configuration
darwin-rebuild switch --flake .#<hostname>

# Linux: Rebuild and switch NixOS configuration
sudo nixos-rebuild switch --flake .#<hostname>

# Home Manager: Update user environment independently
home-manager switch --flake .#<hostname>
```

### 🧪 Testing Configuration Changes

Before applying changes system-wide, test your configuration:

```bash
# Test Darwin config without switching (build only)
nix build .#darwinConfigurations.<hostname>.system

# Test NixOS config without switching
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel

# Test home-manager config
nix build .#homeConfigurations.<hostname>.activationPackage
```

### ❄️ Flake Operations

```bash
# Update all flake inputs
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs-unstable

# Check flake for errors
nix flake check

# Show flake info
nix flake show

# Enter development shell
nix develop
```

### 📦 Flox Environment

```bash
# Activate Flox environment (done automatically via shell init)
flox activate

# Install package
flox install <package>

# Search for packages
flox search <term>

# List installed packages
flox list

# Show package details
flox show <package>

# Edit manifest directly
vim flox/env/manifest.toml
```

## ➕ Adding New Machines

1. Create machine-specific config in `darwinConfigurations/` or
   `nixosConfigurations/`:

   ```nix
   # darwinConfigurations/newmachine.nix
   { pkgs, lib, inputs, ... }:
   {
     imports = [
       ../homeConfigurations/profiles/common.nix
       ../homeConfigurations/profiles/darwin.nix
     ];

     # Machine-specific settings here
   }
   ```

2. Add entry to `flake.nix` outputs:

   ```nix
   darwinConfigurations.newmachine = nix-darwin.lib.darwinSystem {
     system = "aarch64-darwin";
     modules = [ ./darwinConfigurations/newmachine.nix ];
     specialArgs = { inherit inputs; };
   };
   ```

3. Add machine metadata to `machineSettings` in `flake.nix`
   (lines 205-231).

## 📦 Adding Packages

### ❄️ System-Wide Nix Packages

Edit `homeConfigurations/profiles/common.nix` and add to `home.packages`:

```nix
home.packages = with pkgs; [
  ripgrep
  jq
  # Add your package here
];
```

### 📦 Flox Packages

Edit `flox/env/manifest.toml` under the `[install]` section:

```toml
[install]
ripgrep.pkg-path = "ripgrep"
your-package.pkg-path = "your-package"
```

### 🛠️ Custom Nix Packages

1. Create package file in `flox/pkgs/<name>.nix`
2. Reference in `flox/env/manifest.toml`
3. Example: See `flox/pkgs/claude-code.nix`

## 🎨 Key Technologies

- 🐚 **Shell**: Zsh with Powerlevel10k theme
- ✏️ **Editor**: Neovim with extensive LSP/plugin configuration
- 👻 **Terminal**: Ghostty with Catppuccin theme
- 🖥️ **Multiplexer**: tmux with Catppuccin theme
- 🪟 **Window Manager**: AeroSpace (macOS), Hyprland/Sway (Linux)
- 🌳 **Git UI**: lazygit with Catppuccin theme
- 🚀 **Modern CLI**: bat, eza, ripgrep, fd, fzf, zoxide

### 🤖 AI Tools (via Flox)

- 🧠 claude-code - Anthropic's Claude Code CLI
- 💬 codex - OpenAI Codex CLI
- 💎 gemini-cli - Google Gemini CLI
- 🛠️ amazon-q-cli - Amazon Q CLI
- 🔓 opencode - Open source code assistant

### 🔌 MCP Servers (via Flox)

- 📦 flox-mcp-server - Flox environment management
- 🐙 github-mcp-server - GitHub integration
- 🎭 playwright-mcp - Browser automation

## ⚙️ Customization

### 🌳 Git Configuration

The repository uses conditional git includes based on repository remotes:

- **Personal repos** (garbas repositories): Uses personal email
- **Work repos** (flox repositories): Uses work email

Configuration is in `homeConfigurations/profiles/common.nix`
(lines with `programs.git`).

### ✏️ Neovim

Neovim configuration is in `profiles/common_neovim.nix`. It includes:

- 🔌 LSP support for multiple languages
- 🧩 Extensive plugin system
- ⌨️ Custom keybindings
- 🎨 Catppuccin theme

### 🔌 Adding Custom Vim Plugins

To add a new vim plugin from a Git repository:

1. Add input to `flake.nix`:

   ```nix
   inputs.vimPlugin-pluginname = {
     url = "github:author/plugin";
     flake = false;
   };
   ```

2. Reference as `custom-pluginname` in Neovim config

## ☁️ Remote Builders

Darwin machines are configured with Hetzner remote builders for Linux builds:

- 🖥️ hetzner-aarch64-indigo-03 (aarch64-linux, 20 max jobs)
- 🖥️ hetzner-x86-64-indigo-04 (x86_64-linux, 8 max jobs)
- 🖥️ hetzner-x86-64-indigo-05 (x86_64-linux, 8 max jobs)

This enables cross-compilation without native Linux machines.

## 🔧 Troubleshooting

### Flox activation fails

Check 1Password authentication:

```bash
op signin --account my.1password.com
```

### Darwin rebuild fails with "activation would overwrite"

Use the `--impure` flag:

```bash
darwin-rebuild switch --flake .#<hostname> --impure
```

### Home-manager conflicts

Clear old generations:

```bash
home-manager expire-generations "-7 days"
```

### Build errors with remote builders

Check SSH access:

```bash
ssh hetzner-aarch64-indigo-03
```

Verify nix-daemon is running on remote.

### Nix store issues

Run garbage collection:

```bash
nix-collect-garbage -d           # User profile
sudo nix-collect-garbage -d      # System-wide (NixOS)
```

### Full system rebuild (nuclear option)

```bash
# Collect garbage
nix-collect-garbage -d
sudo nix-collect-garbage -d  # NixOS only

# Clear old generations
nix-env --delete-generations old
sudo nix-env --delete-generations old  # NixOS only

# Rebuild
darwin-rebuild switch --flake .#<hostname>  # macOS
sudo nixos-rebuild switch --flake .#<hostname>  # Linux
```

## 📦 Binary Caches

The flake is configured to use multiple substituters for faster builds:

- ❄️ cache.nixos.org - Official NixOS cache
- 📦 cache.flox.dev - Flox package cache
- 🔧 devenv.cachix.org - Devenv cache

## 🤝 Contributing

This is a personal dotfiles repository, but feel free to fork and adapt for
your own use. See `.claude/CLAUDE.md` for detailed architecture documentation.

## 📄 License

MIT License - See LICENSE file for details.

## 🎯 Development & Pre-commit Hooks

This repository uses [git-hooks.nix](https://github.com/cachix/git-hooks.nix)
to manage pre-commit hooks that ensure code quality and consistency.

### Automatic Setup

Pre-commit hooks are automatically installed when you enter the development
shell:

```bash
nix develop
```

Or if using direnv (automatically loads when entering the directory):

```bash
direnv allow
```

### Configured Hooks

#### Markdownlint

All Markdown files are checked for style consistency and line length:

- **Maximum line length**: 80 characters (MD013)
- **Code blocks and tables**: Excluded from line length checks
- **Configuration file**: `markdownlint.json`

**Important**: Markdownlint will report lines longer than 80 characters but
**will not** automatically fix them. This is intentional because line breaks
in Markdown affect readability and should be done manually.

#### nixfmt-rfc-style

All Nix files are automatically formatted using the RFC 166 style standard:

- **Formatter**: nixfmt-rfc-style
- **Auto-fix**: Yes, files are automatically formatted on commit
- **Standard**: RFC 166 (will become the official Nixpkgs standard)

#### Terraform Formatting

All Terraform files are automatically formatted using OpenTofu:

- **Formatter**: tofu fmt (OpenTofu)
- **Auto-fix**: Yes, files are automatically formatted on commit
- **Files**: All `.tf` files

#### Commit Message Linting

All commit messages must follow the Conventional Commits specification:

- **Standard**: Conventional Commits
- **Format**: `type(scope): subject`
- **Configuration file**: `.czrc`
- **Hook**: commitizen

**Commit Types:**

- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Formatting, missing semi-colons, etc.
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `perf`: Performance improvement
- `test`: Adding or correcting tests
- `build`: Build system or dependency changes
- `ci`: CI configuration changes
- `chore`: Other changes that don't modify src or test files
- `revert`: Reverts a previous commit

**Examples:**

- `feat(api): add user authentication endpoint`
- `fix(ui): resolve button alignment issue`
- `docs: update installation instructions`
- `chore: bump dependencies`

### Testing Locally

Run linters manually on specific files:

```bash
# Markdownlint
markdownlint --config markdownlint.json <file.md>

# nixfmt-rfc-style
nixfmt <file.nix>

# Terraform formatting
cd terraform && tofu fmt

# Or from outside the dev shell
nix develop --command markdownlint --config markdownlint.json <file.md>
nix develop --command nixfmt <file.nix>
nix develop --command bash -c "cd terraform && tofu fmt"
```

### Configuration Details

#### Markdownlint Rules

The following rules are configured in `markdownlint.json`:

- MD013: Line length limited to 80 characters
- MD024: Duplicate heading names allowed if siblings only
- MD033: HTML allowed in Markdown
- MD041: First line doesn't need to be a heading

#### nixfmt-rfc-style

Uses default RFC 166 formatting rules with no additional configuration needed.

## ☁️ Binary Cache (Cloudflare R2)

This repository uses Cloudflare R2 for storing Nix build artifacts as a
binary cache. This speeds up builds by downloading pre-built packages
instead of building from source. 🚀

### 🏗️ Infrastructure

The R2 bucket and API tokens are managed using OpenTofu (Terraform) in the
`terraform/` directory.

**Bucket**: `garbas-dotfiles-nix-cache` 🪣

**Cost**: Free tier includes 10GB storage + unlimited egress ($0/month for
typical personal use) 💰✨

### 📖 Setup

See [`terraform/README.md`](terraform/README.md) for complete setup
instructions including:

- 🔧 Terraform/OpenTofu installation and configuration
- 🪣 Creating the R2 bucket and API tokens
- 🔐 Generating Nix signing keys
- 🤖 Configuring GitHub Actions secrets
- 💻 Adding the cache to your local machines
- 📝 Terraform naming conventions

### 🚀 Quick Start (Consumers)

To use the cache on your machines, add to your `flake.nix` or configuration:

```nix
{
  nix.settings = {
    substituters = [
      "https://cache.nixos.org"
      "s3://garbas-dotfiles-nix-cache?endpoint=<account-id>.r2.cloudflarestorage.com&region=auto"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "garbas-dotfiles-nix-cache-1:<your-public-key>"
    ];
  };
}
```

### 📤 Uploading to Cache

Primary uploads come from GitHub Actions. Manual uploads can be done with:

```bash
nix copy --to 's3://garbas-dotfiles-nix-cache?endpoint=<account-id>.r2.cloudflarestorage.com&region=auto' ./result
```

## 📚 References

- ❄️ [Nix](https://nixos.org/)
- 🍎 [nix-darwin](https://github.com/LnL7/nix-darwin)
- 🏠 [Home Manager](https://github.com/nix-community/home-manager)
- 📦 [Flox](https://flox.dev/)
- 🔧 [Determinate Systems Nix Installer](https://github.com/DeterminateSystems/nix-installer)
- 🪝 [git-hooks.nix](https://github.com/cachix/git-hooks.nix)

---

<div align="center">

✨ **Made with ❤️ and Nix** ❄️

</div>
