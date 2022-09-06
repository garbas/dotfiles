{
  description = "Garbas's dotfiles";

  nixConfig.extra-substituters = [
    "https://nixpkgs-wayland.cachix.org/"
  ];
  nixConfig.extra-trusted-public-keys = [
    "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
  ];

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-22.05";
  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nixpkgs-master.url = "github:NixOS/nixpkgs/master";
  inputs.nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
  inputs.nixpkgs-wayland.inputs.nixpkgs.follows = "nixpkgs-unstable";
  # TODO:
  #nixpkgs-wayland.inputs.lib-aggregate.inputs.flake-utils.follows = "flake-utils";
  #nixpkgs-wayland.inputs.lib-aggregate.inputs.nixpkgs.follows = "nixpkgs-unstable";
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
    , nixpkgs-wayland
    , nixos-hardware
    , home-manager
    , neovim-flake
    , nightfox-src
    }:
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
       {
         "${name}" = home-manager.lib.homeManagerConfiguration rec {
            pkgs = import nixpkgs { inherit system overlays; };
            modules = [
              (import ./homeConfigurations/dev.nix { inherit sshKey username email fullname; })
            ];
          };
      };

      mkNixOSConfiguration =
        { name
        , inputs
        , system ? "x86_64-linux"
        , packages ? []
        }:
        {
          "${name}" = inputs.nixpkgs.lib.nixosSystem
            { inherit system;
              modules =
                [ ((import (./. + "/configurations/${name}.nix")) packages inputs)
                  ({ ... }: {
                    system.configurationRevision = inputs.nixpkgs.lib.mkIf (self ? rev) self.rev;
                    nix.registry.nixpkgs.flake = inputs.nixpkgs;
                    nixpkgs = {
                      overlays = [
                        nixpkgs-wayland.overlay
                        (final: prev: {
                          firefox = prev.firefox-bin.override { forceWayland = true; };
                          vaapiIntel = prev.vaapiIntel.override { enableHybridCodec = true; };
                        })
                      ] ++ overlays;
                    };
                  })
                ];
            };
        };

      flake = flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
        let
          pkgs = import nixpkgs-unstable { inherit system overlays; };
        in rec {
          devShell = pkgs.mkShell {
            packages = [
              pkgs.rnix-lsp
              home-manager.packages.${system}.default
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
        homeConfigurations =
          {}
          // mkHomeConfiguration { name = "build01-tweag-io"; sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGb0GeyZewaSbXpUgcew7HX1x6xOX1xJDTOvYX/j1TKr rok@build01.tweag.io"; }
          // mkHomeConfiguration { name = "iog-gov-dev";      sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGCCNUtXFFDYJelHhh9h2zSkTeYvvpgqWGpIdBogyCQU rok@dev.gov.iog.io"; }
          ;
        nixosConfigurations =
          {}
          // mkNixOSConfiguration { name = "khal"; inputs = { inherit nixos-hardware home-manager; }; }
          // mkNixOSConfiguration { name = "floki"; nixpkgs = nixpkgs-stable; }
          ;
      };
}
