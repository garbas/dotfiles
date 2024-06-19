{ pkgs, user, inputs, ... }: {

  imports = [
    (import ./flox-remote-builders.nix "/Users/${user.username}/.ssh/id_ed25519")
  ];

  # use existing nix installation
  nix.useDaemon = true;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
    trusted-users = root rok

    system = aarch64-darwin
    extra-platforms = aarch64-darwin x86_64-darwin
  '';

  # this does the trick to load the nix-darwin environment
  programs.zsh.enable = true;

  users.users.${user.username} = {
    home = "/Users/${user.username}";
    shell = pkgs.zsh;
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.rok = import ./../homeConfigurations/jaime.nix;
  home-manager.extraSpecialArgs = { inherit user inputs; };

  services.skhd.enable  = true;
  services.skhd.skhdConfig = ''
    # Spaces: focus/switch

  '';

  services.yabai.enable = true;
  services.yabai.enableScriptingAddition = true;
  services.yabai.config = {
    layout       = "bsp";
    auto_balance = "on";
    window_placement    = "second_child";

    # window border
    window_border = "on";
    window_border_width = 2;
    active_window_border_color = "0xff5c7e81";
    normal_window_border_color = "0xff505050";
    insert_window_border_color = "0xffd75f5f";

    # window paddixg
    top_padding         = 5;
    bottom_padding      = 5;
    left_padding        = 5;
    right_padding       = 5;
    window_gap          = 5;
    window_opacity      = "off";

    # mouse setting
    focus_follows_mouse = "autoraise";
    mouse_follows_focus = "on";
    mouse_modifier      = "alt";
    mouse_action1       = "move";    # left click + drag
    mouse_action2       = "resize";  # righ click + drag
    mouse_drop_action   = "swap";

    # integrate spacebar
    #external_bar        = "all:26";
  };
  services.yabai.extraConfig = ''
    yabai -m rule --add app='System Settings' manage=off
  '';

  services.spacebar.enable  = true;
  services.spacebar.package = pkgs.spacebar;
  services.spacebar.config = {
    clock_format     = "%R";
    background_color = "0xff202020";
    foreground_color = "0xffa8a8a8";
  };
}
