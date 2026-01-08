{
  pkgs,
  user,
  inputs,
  ...
}:
{
  imports = [
    ./profiles/linux.nix
    inputs.flox.homeModules.flox
  ];

  # XXX: due to some problems in flox homeModule
  nix.settings.substituters = [
    "https://cache.nixos.org"
    "https://cache.flox.dev"
    "https://devenv.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
    "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
  ];

  nix.package = pkgs.nixVersions.latest;
  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      protocol = "ssh-ng";
      sshUser = "nixbld";
      hostName = "hetzner-x86-64-indigo-04";
      systems = [ "x86_64-linux" ];
      #sshKey = "/Users/${user.username}/.ssh/id_ed25519";
      maxJobs = 8;
      speedFactor = 1;
      supportedFeatures = [
        "kvm"
        "benchmark"
        "big-parallel"
        "nixos-test"
        "docker"
      ];
      mandatoryFeatures = [ ];
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSVB0NlA4eGdlMkhpYS84WHRaN2FqNU42Q2FvZWdmQjIwQ252SnlRTG93Q2kgcm9vdEBoZXR6bmVyLXg4Ni02NC1pbmRpZ28tMDQK";
    }
    {
      protocol = "ssh-ng";
      sshUser = "nixbld";
      hostName = "hetzner-x86-64-indigo-05";
      systems = [ "x86_64-linux" ];
      #sshKey = "/Users/${user.username}/.ssh/id_ed25519";
      maxJobs = 8;
      speedFactor = 1;
      supportedFeatures = [
        "kvm"
        "benchmark"
        "big-parallel"
        "nixos-test"
        "docker"
      ];
      mandatoryFeatures = [ ];
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSVBYNzc4Qkl1VXlTNHdDd1JOM0hOQU5NeWowZEp3d1lXYzlGTlNFaTJIZW0gcm9vdEBoZXR6bmVyLXg4Ni02NC1pbmRpZ28tMDUK";
    }
  ];
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  #extra-trusted-public-keys = floxhub-1:0QOAlcobcEvq1mqEf4qAYCaWnTTOXpyoRv/PmqfSixM=

  nixpkgs.config.allowBroken = false;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreeRedistributable = true;

  home.packages = with pkgs; [
    inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default.terminfo
  ];

  xdg.configFile."git/config-flox".text = ''
    [user]
      name = ${user.fullname}
      email = rok@flox.dev
  '';
  programs.git.includes = [
    {
      path = "~/.config/git/config-flox";
      condition = "hasconfig:remote.*.url:git@github.com\:flox/**";
    }
    {
      path = "~/.config/git/config-flox";
      condition = "hasconfig:remote.*.url:git@github.com\:flox-examples/**";
    }
  ];
}
