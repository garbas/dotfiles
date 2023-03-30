{ pkgs, user, ... }: {

  # use existing nix installation
  nix.useDaemon = true;

  # this does the trick to load the nix-darwin environment
  programs.zsh.enable = true;

  users.users.${user.username} = {
    home = "/Users/${user.username}";
    shell = pkgs.zsh;
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.rok = import ./../homeConfigurations/jaime.nix;
}
