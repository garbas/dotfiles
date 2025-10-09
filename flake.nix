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
  inputs.mac-app-util.inputs.nixpkgs.follows = "nixpkgs-unstable";
  inputs.mac-app-util.inputs.flake-utils.follows = "flake-utils";

  # Catppuccin olorscheme
  inputs.catppuccin-ghostty.url = "github:catppuccin/ghostty";
  inputs.catppuccin-ghostty.flake = false;
  inputs.catppuccin-lazygit.url = "github:catppuccin/lazygit";
  inputs.catppuccin-lazygit.flake = false;

  inputs.ghostty.url = "github:ghostty-org/ghostty/v1.1.3";
  inputs.flox.url = "github:flox/flox/v1.7.2";

  # Custom vim/neovim plugins
  inputs.vimPlugin-auto-dark-mode.url = "github:f-person/auto-dark-mode.nvim";
  inputs.vimPlugin-auto-dark-mode.flake = false;

  outputs =
    {
      self,
      flake-utils,
      nixpkgs-unstable,
      nix-darwin,
      home-manager,
      mac-app-util,
      ...
    }@inputs:
    let
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
            modules = [ (import (self + "/homeConfigurations/${name}.nix")) ];
            extraSpecialArgs = {
              inherit inputs system;
              customVimPlugins = mkCustomVimPlugins { inherit pkgs; };
              user = user // user.machines.${name};
              hostname = name;
            };
          };
        };

      mkDarwinConfiguration =
        {
          name,
          nixpkgs ? nixpkgs-unstable,
          system ? "aarch64-darwin",
        }:
        let
          pkgs = import nixpkgs { inherit system; };
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
              pkgs = import nixpkgs-unstable { inherit system; };
            in
            {
              inherit inputs;
              packages.customVimPlugins = mkCustomVimPlugins { inherit pkgs; };
              devShells.default = pkgs.mkShell {
                inherit system;
                packages =
                  with pkgs;
                  [
                    nixd
                    #nixfmt-classic
                    nixfmt-rfc-style
                  ]
                  ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [ nix-darwin.packages.${system}.default ];
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
