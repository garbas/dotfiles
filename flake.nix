{
  inputs.nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-20.09";
  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";

  outputs =
    { self
    , nixpkgs-stable
    , nixpkgs-unstable
    , nixos-hardware
    }:
    let
      mkConfiguration =
        { name
        , nixpkgs
        }:
        { "${name}" = nixpkgs.lib.nixosSystem
            { system = "x86_64-linux";
              modules =
                [ ((import (./. + "/configurations/${name}.nix")) nixpkgs nixos-hardware)
                  ({ ... }: {
                    system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
                    nix.registry.nixpkgs.flake = nixpkgs;
                  })
                ];
            };
        };
    in
      { nixosConfigurations =
          (mkConfiguration
            { name = "khal";
              nixpkgs = nixpkgs-unstable;
            }) //
          (mkConfiguration
            { name = "floki";
              nixpkgs = nixpkgs-stable;
            }) //
          {};
      };
}
