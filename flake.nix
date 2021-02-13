{
  inputs.nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-20.09";
  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  inputs.onlyoffice.url = "github:GTrunSec/onlyoffice-desktopeditors-flake/main";

  outputs =
    { self
    , nixpkgs-stable
    , nixpkgs-unstable
    , nixos-hardware
    , onlyoffice
    }:
    let
      system = "x86_64-linux";
      mkConfiguration =
        { name
        , inputs
        }:
        { "${name}" = inputs.nixpkgs.lib.nixosSystem
            { inherit system;
              modules =
                [ ((import (./. + "/configurations/${name}.nix")) inputs)
                  ({ ... }: {
                    system.configurationRevision = inputs.nixpkgs.lib.mkIf (self ? rev) self.rev;
                    nix.registry.nixpkgs.flake = inputs.nixpkgs;
                  })
                ];
            };
        };
    in
      { nixosConfigurations =
          (mkConfiguration
            { name = "khal";
              inputs = {
                inherit nixos-hardware;
                nixpkgs = nixpkgs-unstable;
                onlyoffice = onlyoffice.defaultPackage."${system}";
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
