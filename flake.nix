{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";

  outputs = { self, nixpkgs, nixos-hardware }:
    let
      mkNixosConfigurations name =
        { "${name}" = nixpkgs.lib.nixosSystem
            { system = "x86_64-linux";
              modules =
                [ ((import "./configurations/${name}.nix") nixpkgs nixos-hardware)
                  ({ ... }: {
                    system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
                    nix.registry.nixpkgs.flake = nixpkgs;
                  })
                ];
            };
        };
    in
      { nixosConfigurations = builtins.map mkNixosConfigurations ["khal" "floki"]
      };
}
