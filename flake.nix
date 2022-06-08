{
  description = "Garbas's dotfiles";

  inputs =
    { flake-utils.url = "github:numtide/flake-utils";
      nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-22.05";
      nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
      nixpkgs-master.url = "github:NixOS/nixpkgs/master";
      nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
      nixpkgs-wayland.inputs.nixpkgs.follows = "nixpkgs-unstable";
      # TODO:
      #nixpkgs-wayland.inputs.lib-aggregate.inputs.flake-utils.follows = "flake-utils";
      #nixpkgs-wayland.inputs.lib-aggregate.inputs.nixpkgs.follows = "nixpkgs-unstable";
      nixos-hardware.url = "github:NixOS/nixos-hardware/master";
      home-manager.url = "github:nix-community/home-manager";
      home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";
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
    , nixpkgs-wayland
    , nixos-hardware
    , home-manager
    , neovim-flake
    , nightfox-src
    }:
    let
      overlays = [
        nixpkgs-wayland.overlay
        (final: prev: {
          firefox = prev.firefox-bin.override { forceWayland = true; };
          vaapiIntel = prev.vaapiIntel.override { enableHybridCodec = true; };
        })
        (import ./pkgs/overlay.nix { inherit neovim-flake nightfox-src; })
      ];

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
                    nix.settings.trusted-public-keys = [
                      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
                    ];
                    nix.settings.substituters = [
                      "https://nixpkgs-wayland.cachix.org/"
                    ];
                    nixpkgs = { inherit overlays; };
                  })
                ];
            };
        };

      flake = flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
        let
          pkgs = import nixpkgs-master { inherit system overlays; };
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
        nixosConfigurations =
          (mkConfiguration
            rec { name = "khal";
                  system = "x86_64-linux";
                  packages = with flake.packages.${system}; [ neovim obs-studio-with-plugins ];
                  inputs = {
                    inherit nixos-hardware home-manager;
                    nixpkgs = nixpkgs-master;
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
