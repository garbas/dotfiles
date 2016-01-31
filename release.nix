{ supportedSystems ? [ "x86_64-linux" ] }:

let

  # nixpkgs/pkgs/top-level/release-lib.nix

  pkgs = pkgsFor "x86_64-linux";

  allPackages = args: import <nixpkgs/pkgs/top-level/all-packages.nix> (args // {
    config.allowUnfree = false;
    config.inHydra = true;
    config.packageOverrides = pkgs: import ./pkgs { inherit pkgs; };
  });

  pkgsFor = system:
    if system == "x86_64-linux" then pkgs_x86_64_linux
    else abort "unsupported system type: ${system}";

  pkgs_x86_64_linux = allPackages { system = "x86_64-linux"; };

in {
  weechat = pkgs.lib.genAttrs supportedSystems (system: (pkgsFor system).weechat);
}
