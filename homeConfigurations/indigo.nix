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

  nix.package = pkgs.nixVersions.latest;
  programs.flox.enable = true;

  programs.zsh.initContent = ''
    #eval "$(flox activate -d ~ -m run)"
  '';

  home.packages = with pkgs; [
    inputs.ghostty.packages.${system}.default.terminfo
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
