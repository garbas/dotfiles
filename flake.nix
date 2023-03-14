{
  description = "Garbas's dotfiles";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-22.05";
  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nixpkgs-master.url = "github:NixOS/nixpkgs/master";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";
  inputs.home-manager.inputs.utils.follows = "flake-utils";
  inputs.neovim-flake.url = "github:neovim/neovim?dir=contrib";
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
       , sshKey
       , username ? "rok"
       , email ? "rok@garbas.si"
       , fullname ? "Rok Garbas"
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
              (import homeConfiguration { inherit sshKey username email fullname; })
            ];
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
    in
      flake // {
        homeConfigurations =
          {}
          // mkHomeConfiguration { name = "jaime"; system = "aarch64-darwin"; sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKex8HTaW5y1IrhxVKU4r9XfLNWl6kvzpBF74VXovfPu rok@floxdev.com"; }
          ;
        nixosConfigurations =
          {}
          // mkNixOSConfiguration { name = "pono"; }
          // mkNixOSConfiguration { name = "cercei"; system = "aarch64-linux"; }
          // mkNixOSConfiguration { name = "floki"; nixpkgs = nixpkgs-stable; }
          ;
      };
}
