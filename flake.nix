{
  description = "Garbas's dotfiles";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-22.05";
  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nixpkgs-master.url = "github:NixOS/nixpkgs/master";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  inputs.darwin.url = "github:lnl7/nix-darwin/master";
  inputs.darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";
  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";
  inputs.neovim-flake.url = "github:neovim/neovim?dir=contrib";
  inputs.neovim-flake.inputs.flake-utils.follows = "flake-utils";
  inputs.neovim-flake.inputs.nixpkgs.follows = "nixpkgs-unstable";
  inputs.nightfox-src.url = "github:EdenEast/nightfox.nvim";
  inputs.nightfox-src.flake = false;

  outputs =
    { self
    , flake-utils
    , nixpkgs-stable
    , nixpkgs-unstable
    , nixpkgs-master
    , nixos-hardware
    , darwin
    , home-manager
    , neovim-flake
    , nightfox-src
    } @ inputs:
    let
      overlays = [
        (import ./pkgs/overlay.nix { inherit neovim-flake nightfox-src; })
      ];

      mkHomeConfiguration =
       { name
       , nixpkgs ? nixpkgs-unstable
       , system ? "x86_64-linux"
       }:
       let
         homeConfiguration = 
           if builtins.elem system ["x86_64-darwin" "aarch64-darwin"]
           then ./homeConfigurations/darwin.nix
           else ./homeConfigurations/linux.nix;
       in {
         "${name}" = home-manager.lib.homeManagerConfiguration rec {
            pkgs = import nixpkgs { inherit system overlays; };
            modules = [
              (import (self + "/homeConfiguration/${name}.nix"))
            ];
          };
      };

      mkDarwinConfiguration =
        { name
        , nixpkgs ? nixpkgs-unstable
        , system ? "aarch64-darwin"
        }:
        {
          "${name}" = darwin.lib.darwinSystem
            { inherit system;
              specialArgs = { inherit user; };
              modules =
                [ (import (self + "/darwinConfigurations/${name}.nix"))
                  home-manager.darwinModules.home-manager
                ];
              inputs = { inherit nixpkgs home-manager; };
            };
        };

      mkNixOSConfiguration =
        { name
        , nixpkgs ? nixpkgs-unstable
        , system ? "x86_64-linux"
        }:
        {
          "${name}" = nixpkgs.lib.nixosSystem
            { inherit system;
              modules =
                [ ((import (self + "/nixosConfigurations/${name}.nix")) (inputs // { inherit nixpkgs; }))
                  ({ ... }: {
                    system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
                    nix.registry.nixpkgs.flake = nixpkgs;
                    nixpkgs = {
                      overlays = [
                        (final: prev: {
                          vaapiIntel = prev.vaapiIntel.override { enableHybridCodec = true; };
                        })
                      ] ++ overlays;
                    };
                  })
                ];
            };
        };

      flake = flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ] (system:
        let
          pkgs = import nixpkgs-unstable { inherit system overlays; };
        in rec {
          devShell = pkgs.mkShell {
            packages = [
              pkgs.rnix-lsp
            ];
          };
        });

      user = {
        fullname = "Rok Garbas";
        username = "rok";
        email = "rok@garbas.si";
        sshKeys = {
          jaime = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKex8HTaW5y1IrhxVKU4r9XfLNWl6kvzpBF74VXovfPu";
          cercei = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICZr0HtRTIngjPGi4yliL4vffUYxx1OMCcfHcecAhgO5";
        };
      };
    in
      flake // {
        homeConfigurations =
          {}
          // mkHomeConfiguration   { system = "aarch64-darwin"; name = "jaime"; }
          ;
        darwinConfigurations =
          {}
          // mkDarwinConfiguration { system = "aarch64-darwin"; name = "jaime"; }
          ;
        nixosConfigurations =
          {}
          // mkNixOSConfiguration  { system = "x86_64-linux";   name = "pono"; }
          // mkNixOSConfiguration  { system = "aarch64-linux";  name = "cercei"; }
          // mkNixOSConfiguration  { system = "x86_64-linux";   name = "floki"; nixpkgs = nixpkgs-stable; }
          ;
      };
}
