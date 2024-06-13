{
  description = "Garbas's dotfiles";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.11";
  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";

  inputs.darwin.url = "github:lnl7/nix-darwin/master";
  inputs.darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";

  #inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.url = "github:garbas/home-manager/gh-fix";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

  inputs.nightfox-src.url = "github:EdenEast/nightfox.nvim";
  inputs.nightfox-src.flake = false;

  inputs.mac-app-util.url = "github:hraban/mac-app-util";
  inputs.mac-app-util.inputs.nixpkgs.follows = "nixpkgs-unstable";
  inputs.mac-app-util.inputs.flake-utils.follows = "flake-utils";

  outputs =
    { self
    , flake-utils
    , nixpkgs-stable
    , nixpkgs-unstable
    , nixos-hardware
    , darwin
    , home-manager
    , nightfox-src
    , mac-app-util
    } @ inputs:
    let
      overlays = [
        (import ./pkgs/overlay.nix { inherit nightfox-src; })
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
              (import (self + "/homeConfigurations/${name}.nix"))
            ];
            extraSpecialArgs = { inherit user inputs; };
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
              specialArgs = { inherit user inputs; };
              modules =
                [ 
                  mac-app-util.darwinModules.default
                  home-manager.darwinModules.home-manager
                  ({ pkgs, config, inputs, ... }:
                   {
                     home-manager.sharedModules = [
                       mac-app-util.homeManagerModules.default
                     ];
                   })

                  (import (self + "/darwinConfigurations/${name}.nix"))
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
                    networking.hostName = name;
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
            system = "aarch64-darwin";
          };
        });

      user = {
        fullname = "Rok Garbas";
        username = "rok";
        email = "rok@garbas.si";
        machines = {
          solo = {
            sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBwOFnH4EHVCV/8/aaNg4n/zywH7IlSWur92iN9eeHGX";
          };
          jaime = {
            sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKex8HTaW5y1IrhxVKU4r9XfLNWl6kvzpBF74VXovfPu";
          };
          cercei = {
            sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICZr0HtRTIngjPGi4yliL4vffUYxx1OMCcfHcecAhgO5";
          };
        };
      };
    in
      flake // {
        homeConfigurations =
          {}
          // mkHomeConfiguration   { system = "aarch64-darwin"; name = "jaime"; }
          // mkHomeConfiguration   { system = "aarch64-linux"; name = "solo"; }
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
