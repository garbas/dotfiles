# Tyrion - ThinkPad X220

Minimal Hyprland desktop on a ThinkPad X220 (x86_64-linux),
used primarily as a server with occasional GUI access.

## Hardware

- **CPU:** Intel Core i5-2520M (Sandy Bridge)
- **GPU:** Intel HD 3000 (OpenGL ES 3.0 via Mesa/Crocus)
- **Storage:** ZFS on root (rpool + bpool)
- **Kernel:** Linux 6.6 LTS (ZFS compatible)
- **Lid close:** ignored (server use)

## Desktop

| Component | Program |
| --------- | ------- |
| WM | Hyprland (animations/blur/shadows disabled) |
| Terminal | ghostty |
| Browser | chromium |
| Bar | waybar (workspaces, clock, network, audio, battery) |
| Launcher | wofi |
| Lock | hyprlock + hypridle (5min lock, 10min dpms off) |
| Notifications | mako |
| Screenshots | grim + slurp (Print / Super+Print) |
| Clipboard | wl-clipboard + cliphist (Super+V) |
| Audio | pipewire + wireplumber + pavucontrol |
| Login | greetd + tuigreet |

## Editor and Dev Tools

| Tool | Purpose |
| ---- | ------- |
| neovim | editor (LSP, telescope, treesitter) |
| tmux | terminal multiplexer (catppuccin theme) |
| git | version control (delta, lazygit, gh) |
| zsh | shell (powerlevel10k, fzf, zoxide) |
| direnv | per-project environments |
| ripgrep | search |
| fd | find files |
| jq | JSON processing |
| htop | process monitor |
| bat | cat replacement |
| eza | ls replacement |
| tree | directory listing |

## AI Tools (via common.nix)

claude-code, gemini-cli, opencode, copilot-cli,
agent-deck, pi, ccstatusline

## MCP Servers (via common.nix)

slack-mcp-server, incidentio-mcp, moviepy-mcp

## Networking and Remote

| Tool | Purpose |
| ---- | ------- |
| openssh | SSH server |
| mosh | mobile shell |
| networkmanager | network management |
| keychain | SSH key agent |
| 1password-cli | secrets |

## System Services

- ZFS auto-scrub and auto-snapshot
- fstrim, thermald, TLP (power management)
- powertop, powersave governor
- GPG agent with SSH support
- locate (file indexing)

## Keybinds (Super = Mod)

| Key | Action |
| --- | ------ |
| Super+Return | ghostty |
| Super+D | wofi launcher |
| Super+Q | close window |
| Super+F | fullscreen |
| Super+Space | toggle floating |
| Super+H/J/K/L | focus left/down/up/right |
| Super+Shift+H/J/K/L | move window |
| Super+1-0 | switch workspace |
| Super+Shift+1-0 | move to workspace |
| Super+Tab | previous workspace |
| Super+V | clipboard history |
| Print | screenshot region |
| Super+Print | screenshot full |
| Super+Shift+E | exit Hyprland |
| XF86Audio* | volume/media controls |
| XF86MonBrightness* | backlight |

## Config Sources

- Machine: `nixosConfigurations/tyrion.nix`
- System profile: `nixosConfigurations/profiles/hyprland.nix`
  (imports `console.nix`)
- User profile: `homeConfigurations/profiles/hyprland.nix`
  (imports `common.nix`)
