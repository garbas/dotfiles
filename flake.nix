{
  description = "Garbas's dotfiles";

  inputs =
    { flake-utils.url = "github:numtide/flake-utils";
      nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-21.11";
      nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
      nixpkgs-master.url = "github:NixOS/nixpkgs/master";
      nixos-hardware.url = "github:NixOS/nixos-hardware/master";
      neovim-flake.url = "github:neovim/neovim?dir=contrib";
      neovim-flake.inputs.nixpkgs.follows = "nixpkgs-unstable";
      nightfox-src.url = "github:EdenEast/nightfox.nvim";
      nightfox-src.flake = false;
    };

  outputs =
    { self
    , flake-utils
    , nixpkgs-stable
    , nixpkgs-unstable
    , nixpkgs-master
    , nixos-hardware
    , neovim-flake
    , nightfox-src
    }:
    let
      overlay = import ./pkgs/overlay.nix { inherit neovim-flake nightfox-src; };

      mkConfiguration =
        { name
        , inputs
        , system ? "x86_64-linux"
        }:
        { "${name}" = inputs.nixpkgs.lib.nixosSystem
            { inherit system;
              modules =
                [ ((import (./. + "/configurations/${name}.nix")) inputs)
                  ({ ... }: {
                    system.configurationRevision = inputs.nixpkgs.lib.mkIf (self ? rev) self.rev;
                    nix.registry.nixpkgs.flake = inputs.nixpkgs;
                    nixpkgs.overlays = [ overlay ];
                  })
                ];
            };
        };

      packages = flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
        let
          pkgs = import nixpkgs-master {
            inherit system;
            overlays = [ overlay ];
          };
        in rec {
          devShell = pkgs.mkShell {
            packages = [
              pkgs.rnix-lsp
            ];
          };
          packages = flake-utils.lib.flattenTree {
            inherit (pkgs)
              kitty
              neovim
              neovim-nightly;
          };
        });
    in
      packages // {
        inherit overlay;
        nixosConfigurations =
          (mkConfiguration
            { name = "khal";
              inputs = {
                inherit nixos-hardware;
                nixpkgs = nixpkgs-master;
              };
            }) //
          (mkConfiguration
            { name = "floki";
              inputs = {
                nixpkgs = nixpkgs-stable;
              };
            }) //
          {};
      };
}
