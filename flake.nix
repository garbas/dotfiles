{
  description = "Garbas's dotfiles";

  nixConfig.extra-substituters = [
    "https://cache.nixos.org"
    "https://cache.flox.dev"
    "https://devenv.cachix.org"
  ];
  nixConfig.extra-trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
    "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
  ];

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";

  inputs.nix-darwin.url = "github:lnl7/nix-darwin/master";
  inputs.nix-darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";

  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

  inputs.mac-app-util.url = "github:hraban/mac-app-util";
  #inputs.mac-app-util.inputs.nixpkgs.follows = "nixpkgs-unstable";
  #inputs.mac-app-util.inputs.flake-utils.follows = "flake-utils";

  # Catppuccin olorscheme
  inputs.catppuccin-ghostty.url = "github:catppuccin/ghostty";
  inputs.catppuccin-ghostty.flake = false;
  inputs.catppuccin-lazygit.url = "github:catppuccin/lazygit";
  inputs.catppuccin-lazygit.flake = false;

  inputs.git-hooks.url = "github:cachix/git-hooks.nix";
  inputs.git-hooks.inputs.nixpkgs.follows = "nixpkgs-unstable";

  # Custom vim/neovim plugins
  inputs.vimPlugin-auto-dark-mode.url = "github:f-person/auto-dark-mode.nvim";
  inputs.vimPlugin-auto-dark-mode.flake = false;
  inputs.vimPlugin-telescope-tabs.url = "github:LukasPietzschmann/telescope-tabs";
  inputs.vimPlugin-telescope-tabs.flake = false;

  inputs.llm-agents.url = "github:numtide/llm-agents.nix";

  inputs.flox.url = "github:flox/flox/latest";
  #inputs.flox.url = "github:flox/flox/release-1.9.0";

  outputs =
    {
      self,
      flake-utils,
      nixpkgs-unstable,
      nix-darwin,
      home-manager,
      mac-app-util,
      llm-agents,
      ...
    }@inputs:
    let
      # Shared 1Password secrets helper
      opSecretsLib = import ./lib/op-secrets.nix { lib = nixpkgs-unstable.lib; };
      inherit (opSecretsLib) mkOpSecretsShellHook;

      overlays = [
        llm-agents.overlays.default
      ];

      mkCustomVimPlugins =
        { pkgs }:
        let
          inherit (pkgs.vimUtils) buildVimPlugin;
          pluginsPrefix = "vimPlugin-";
          pluginsNames = builtins.filter (
            n: builtins.substring 0 (builtins.stringLength pluginsPrefix) n == pluginsPrefix
          ) (builtins.attrNames inputs);
          toPluginVersion =
            input:
            let
              year = builtins.substring 0 4 input.lastModifiedDate;
              month = builtins.substring 4 6 input.lastModifiedDate;
              day = builtins.substring 6 8 input.lastModifiedDate;
            in
            "${year}-${month}-${day}-${input.shortRev}";
          normalizeName =
            name:
            "custom-"
            + (builtins.substring (builtins.stringLength pluginsPrefix) (builtins.stringLength name) name);
          plugins =
            final:
            builtins.listToAttrs (
              builtins.map (name: {
                name = normalizeName name;
                value = buildVimPlugin {
                  pname = normalizeName name;
                  version = toPluginVersion inputs.${name};
                  src = inputs.${name};
                  # Disable require check for telescope-tabs (needs telescope.nvim at runtime)
                  doCheck = if name == "vimPlugin-telescope-tabs" then false else true;
                };
              }) pluginsNames
            );
          overrides = final: prev: { };
        in
        pkgs.lib.makeExtensible (pkgs.lib.extends overrides plugins);

      mkHomeConfiguration =
        {
          name,
          nixpkgs ? nixpkgs-unstable,
          system ? "x86_64-linux",
        }:
        {
          "${name}" = home-manager.lib.homeManagerConfiguration rec {
            pkgs = import nixpkgs { inherit system; };
            extraSpecialArgs = {
              inherit inputs system;
              customVimPlugins = mkCustomVimPlugins { inherit pkgs; };
              user = user // user.machines.${name};
              hostname = name;
            };
            modules = [
              (
                { ... }:
                {
                  nixpkgs.overlays = overlays;
                }
              )
              (import (self + "/homeConfigurations/${name}.nix"))
            ];
          };
        };

      mkDarwinConfiguration =
        {
          name,
          nixpkgs ? nixpkgs-unstable,
          system ? "aarch64-darwin",
        }:
        let
          pkgs = import nixpkgs { inherit system overlays; };
        in
        {
          "${name}" = nix-darwin.lib.darwinSystem {
            inherit system;
            specialArgs = {
              inherit inputs system;
              customVimPlugins = mkCustomVimPlugins { inherit pkgs; };
              user = user // user.machines.${name};
              hostname = name;
            };
            modules = [
              mac-app-util.darwinModules.default
              home-manager.darwinModules.home-manager
              (
                { ... }:
                {
                  nixpkgs.overlays = overlays;
                  home-manager.sharedModules = [ mac-app-util.homeManagerModules.default ];
                }
              )

              (import (self + "/darwinConfigurations/${name}.nix"))
            ];
          };
        };

      mkNixOSConfiguration =
        {
          name,
          nixpkgs ? nixpkgs-unstable,
          system ? "x86_64-linux",
        }:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          "${name}" = nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {
              inherit inputs system;
              customVimPlugins = mkCustomVimPlugins { inherit pkgs; };
              user = user // user.machines.${name};
              hostname = name;
            };
            modules = [
              (import (self + "/nixosConfigurations/${name}.nix"))
              (
                { ... }:
                {
                  nixpkgs.overlays = overlays;
                  system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
                  nix.registry.nixpkgs.flake = nixpkgs;
                  networking.hostName = name;
                }
              )
            ];
          };
        };

      flake =
        flake-utils.lib.eachSystem
          [
            "x86_64-linux"
            "aarch64-linux"
            "aarch64-darwin"
          ]
          (
            system:
            let
              pkgs = import nixpkgs-unstable {
                inherit system;
                config.allowUnfree = true;
              };
              pre-commit-check = inputs.git-hooks.lib.${system}.run {
                src = ./.;
                package = pkgs.pre-commit.overridePythonAttrs (
                  final: prev: {
                    checkInputs = [ ];
                    checkPhase = false;
                  }
                );
                hooks = {
                  # Markdown linting to enforce 80 column width
                  markdownlint = {
                    enable = true;
                    name = "markdownlint";
                    description = "Lint Markdown files for 80 column width and style";
                    entry = "${pkgs.markdownlint-cli}/bin/markdownlint --config ${./markdownlint.json}";
                    files = "\\.(md|markdown)$";
                  };
                  # Nix formatting with RFC 166 style
                  nixfmt = {
                    enable = true;
                    package = pkgs.nixfmt;
                  };
                  # Terraform formatting
                  terraform-format = {
                    enable = true;
                    name = "terraform-format";
                    description = "Format Terraform files with tofu fmt";
                    entry = "${pkgs.opentofu}/bin/tofu fmt";
                    files = "\\.tf$";
                  };
                  # Commit message linting (Conventional Commits)
                  commitizen = {
                    enable = true;
                  };
                  # Block commits with AI attribution
                  no-ai-attribution = {
                    enable = true;
                    name = "no-ai-attribution";
                    description = "Block commits with AI attribution footer";
                    entry = toString (
                      pkgs.writeShellScript "no-ai-attribution" ''
                        commit_msg_file="$1"
                        # Block actual attribution footer (with emoji or https://claude.com link)
                        if grep -qE "🤖.*Generated.*claude\.com|Co-Authored-By: Claude <" "$commit_msg_file"; then
                          echo "❌ ERROR: Commit message contains AI attribution footer!"
                          echo "   Remove '🤖 Generated with [Claude Code](https://claude.com/...)' line."
                          echo "   Remove 'Co-Authored-By: Claude <noreply@anthropic.com>' line."
                          echo "   See .claude/CLAUDE.md for commit message guidelines."
                          exit 1
                        fi
                      ''
                    );
                    stages = [ "commit-msg" ];
                  };
                };
              };
            in
            {
              inherit inputs;
              checks.pre-commit = pre-commit-check;
              packages.pre-commit = pkgs.pre-commit.overridePythonAttrs (_: {
                nativeCheckInputs = [ ];
                dontUsePytestCheck = true;
                preCheck = "";
              });
              devShells.default = pkgs.mkShell {
                inherit system;
                packages =
                  with pkgs;
                  [
                    nixd
                    nixfmt
                    home-manager.packages.${system}.default
                    markdownlint-cli
                    opentofu
                    _1password-cli
                    jq
                    bats
                  ]
                  ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [ nix-darwin.packages.${system}.default ];
                shellHook = ''
                  ${pre-commit-check.shellHook}

                  ${mkOpSecretsShellHook {
                    cacheId = "devshell-dotfiles";
                    account = "my.1password.com";
                    item = "dotfiles";
                    secrets = [
                      "TERRAFORM_CLOUDFLARE_ACCOUNT_ID"
                      "TERRAFORM_CLOUDFLARE_R2_ACCESS_KEY_ID"
                    ];
                  }}

                  # Re-export as TF_VAR_ prefixed variables
                  export TF_VAR_cloudflare_account_id="$TERRAFORM_CLOUDFLARE_ACCOUNT_ID"
                  export TF_VAR_cloudflare_api_token="$TERRAFORM_CLOUDFLARE_R2_ACCESS_KEY_ID"
                  echo "  ✓ Exported TF_VAR_cloudflare_account_id"
                  echo "  ✓ Exported TF_VAR_cloudflare_api_token"
                '';
              };
            }
          );

      user = {
        fullname = "Rok Garbas";
        email = "rok@garbas.si";
        username = "rok";
        hashedPassword = "$6$sBFfflUBZtZMD$h.EWNsmmX8iwTM7jShIvYwvS2/h7dncGTNhG.yPN1dOte1Et0TTz7HSFmzkuWjQpnBAfANYdptF3EQoUNSYwx/";
        machines = {
          floki = {
            sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBHCqlV0ZiZtUXhweKabRzyehNYt87pKbs6c0IzDkXoq";
          };
          solo = {
            sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBwOFnH4EHVCV/8/aaNg4n/zywH7IlSWur92iN9eeHGX";
          };
          indigo = {
            sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC9o57frs04674Hft50/95ZrKDlOuFgWAVJIlzPoPEul";
          };
          jaime = {
            sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKex8HTaW5y1IrhxVKU4r9XfLNWl6kvzpBF74VXovfPu";
          };
          cercei = {
            sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICZr0HtRTIngjPGi4yliL4vffUYxx1OMCcfHcecAhgO5";
          };
          brienne = {
            username = "rok.garbas";
            sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE6EoPJOTe245KXcxpXb1qwHH26Bi1C77+qQLXsOUnBS";
          };
          pono = {
            sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICut/WcUHHbTfFiE+5OHIrQguBbC7bXgkRwbPqEK0PcD";
          };
        };
      };
    in
    flake
    // {
      homeConfigurations =
        { }
        // mkHomeConfiguration {
          system = "aarch64-darwin";
          name = "jaime";
        }
        // mkHomeConfiguration {
          system = "aarch64-darwin";
          name = "brienne";
        }
        // mkHomeConfiguration {
          system = "aarch64-linux";
          name = "solo";
        }
        // mkHomeConfiguration {
          system = "aarch64-linux";
          name = "indigo";
        }
        // mkHomeConfiguration {
          system = "x86_64-linux";
          name = "floki";
        };
      darwinConfigurations =
        { }
        // mkDarwinConfiguration {
          system = "aarch64-darwin";
          name = "jaime";
        }
        // mkDarwinConfiguration {
          system = "aarch64-darwin";
          name = "brienne";
        };
      nixosConfigurations =
        { }
        // mkNixOSConfiguration {
          system = "x86_64-linux";
          name = "pono";
        }
        # aws machine (old)
        // mkNixOSConfiguration {
          system = "aarch64-linux";
          name = "cercei";
        } # vm on jaime (not used that much)
        // mkNixOSConfiguration {
          system = "x86_64-linux";
          name = "floki";
        };
    };
}
