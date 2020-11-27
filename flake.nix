{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";

  outputs = { self, nixpkgs, nixos-hardware }: {
    nixosConfigurations.khal = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        [ ((import ./configurations/khal.nix) nixpkgs nixos-hardware)
          ({ ... }: {
            system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
            nix.registry.nixpkgs.flake = nixpkgs;
          })
        ];
    };
  };
}
