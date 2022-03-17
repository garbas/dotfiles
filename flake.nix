{
  description = "Garbas's dotfiles";

  inputs =
    { flake-utils.url = "github:numtide/flake-utils";
      nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-21.11";
      nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
      #nixpkgs-master.url = "github:NixOS/nixpkgs/master";
      nixpkgs-master.url = "github:garbas/nixpkgs/dev";
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
        , packages ? []
        }:
        { "${name}" = inputs.nixpkgs.lib.nixosSystem
            { inherit system;
              modules =
                [ ((import (./. + "/configurations/${name}.nix")) packages inputs)
                  ({ ... }: {
                    system.configurationRevision = inputs.nixpkgs.lib.mkIf (self ? rev) self.rev;
                    nix.registry.nixpkgs.flake = inputs.nixpkgs;
                    nixpkgs.overlays = [ overlay ];
                  })
                ];
            };
        };

      flake = flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
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
              obs-studio-with-plugins
              neovim
              neovim-nightly;
          };
        });
    in
      flake // {
        inherit overlay;
        nixosConfigurations =
          (mkConfiguration
            rec { name = "khal";
                  system = "x86_64-linux";
                  packages = with flake.packages.${system}; [ neovim obs-studio-with-plugins ];
                  inputs = {
                    inherit nixos-hardware;
                    nixpkgs = nixpkgs-unstable;
                  };
                }) //
          (mkConfiguration
            rec { name = "floki";
                  inputs = {
                    nixpkgs = nixpkgs-stable;
                  };
                }) //
          {};
      };
}
