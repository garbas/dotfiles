{
  pkgs,
  user,
  hostname,
  inputs,
  customVimPlugins,
  ...
}:
{

  imports = [
    inputs.flox.darwinModules.flox
  ];

  programs.flox.enable = true;

  system.stateVersion = 6;

  nix.package = pkgs.nixVersions.latest;
  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      protocol = "ssh-ng";
      sshUser = "nixbld";
      hostName = "fd7a:115c:a1e0::2";
      systems = [ "x86_64-linux" ];
      sshKey = "/Users/${user.username}/.ssh/id_ed25519";
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
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUdxT01MZElvZGR6MUppQ1dmbGppcGF1U1ZFMVpVRldCcUk0Rkh0MEdHc1Ugcm9vdEBoZXR6bmVyLXg4Ni02NC1pbmRpZ28tMDEK";
    }
    {
      protocol = "ssh-ng";
      sshUser = "nixbld";
      hostName = "fd7a:115c:a1e0::6";
      systems = [ "x86_64-linux" ];
      sshKey = "/Users/${user.username}/.ssh/id_ed25519";
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
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUFHYmlKejZKWEd4MFlBSDZLS050Y1FrVUxnLzYrVDBjN0RjVkp4bWJ6dTYgcm9vdEBoZXR6bmVyLXg4Ni02NC1pbmRpZ28tMDIK";
    }
    {
      protocol = "ssh-ng";
      sshUser = "nixbld";
      hostName = "fd7a:115c:a1e0::1a";
      systems = [ "aarch64-linux" ];
      sshKey = "/Users/${user.username}/.ssh/id_ed25519";
      maxJobs = 20;
      speedFactor = 1;
      supportedFeatures = [
        "kvm"
        "benchmark"
        "big-parallel"
        "nixos-test"
        "recursive-nix"
        "docker"
      ];
      mandatoryFeatures = [ ];
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUhpQkQ3QlhkZ05MZy8vMmh0cDB3S2hsaFpkSzVZL3R3ajJYcGdEdVh0ZkEgcm9vdEBoZXR6bmVyLWFhcmNoNjQtaW5kaWdvLTAzCg==";
    }
    # ssh-ng://nixbld@fd7a:115c:a1e0::11 x86_64-darwin /root/.ssh/id_ed25519 1 1 benchmark,big-parallel,nixos-test - c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUoxM1lNajNsMjl2YXVyM0pQVlJGanRGNzg0clk3aEw5SnB3QXMzZWp5VU4gCg==
    # ssh-ng://nixbld@fd7a:115c:a1e0::1 x86_64-darwin /root/.ssh/id_ed25519 1 1 benchmark,big-parallel,nixos-test - c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUU2SW5ISytZWVRvZ0tHTHBmVmFHWE9VQkIxa2pWMVFydlZzU21xbHNyb0ggCg==
    # ssh-ng://nixbld@fd7a:115c:a1e0::1c aarch64-darwin,x86_64-darwin /root/.ssh/id_ed25519 1 1 apple-virt,benchmark,big-parallel,nixos-test - c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUVCeFJIT2V3MHpNNFpLeXcrTDRienJSdkk4WTF0TytSRDlBd0x3WFBsYXMgCg==
    # ssh-ng://nixbld@fd7a:115c:a1e0::c aarch64-darwin,x86_64-darwin /root/.ssh/id_ed25519 1 1 apple-virt,benchmark,big-parallel,nixos-test - c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSVBrNllDd2VnOTRrK2pYNTd4djhSY0lrd24xS0RVbXViTGFNOHljY1lZaFAgCg==
  ];
  nix.extraOptions = ''
    experimental-features = nix-command flakes
    trusted-users = root ${user.username}

    system = aarch64-darwin
    extra-platforms = aarch64-darwin x86_64-darwin
    extra-trusted-public-keys = floxhub-1:0QOAlcobcEvq1mqEf4qAYCaWnTTOXpyoRv/PmqfSixM=
  '';

  nixpkgs.config.allowBroken = false;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreeRedistributable = true;

  # Enable Touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  homebrew.enable = true;
  homebrew.casks = [
    "alt-tab"
    "ghostty"
    "chatgpt"
    "zen-browser"
  ];
  homebrew.onActivation.autoUpdate = true;
  homebrew.onActivation.upgrade = true;

  fonts.packages = with pkgs; [
    nerd-fonts.iosevka
  ];

  # this does the trick to load the nix-darwin environment
  programs.zsh.enable = true;

  system.primaryUser = user.username;

  users.users.${user.username} = {
    home = "/Users/${user.username}";
    shell = pkgs.zsh;
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "backup";
  home-manager.users."${user.username}" = import ./../../homeConfigurations/${hostname}.nix;
  home-manager.extraSpecialArgs = {
    inherit
      user
      inputs
      hostname
      customVimPlugins
      ;
  };

  # A lightweight window border system for macOS
  # https://github.com/FelixKratz/JankyBorders
  services.jankyborders.enable = true;
  services.jankyborders.active_color = "0xff00ff00"; # green
  #services.jankyborders.active_color = "gradient(top_right=0x9992B3F5,bottom_left=0x9992B3F5)";
  services.jankyborders.background_color = "0xFFFFFFFF";
  services.jankyborders.blur_radius = 5.0;
  services.jankyborders.hidpi = true;
  services.jankyborders.width = 10.0;

  # AeroSpace is an i3-like tiling window manager for macOS
  # https://github.com/nikitabobko/AeroSpace
  services.aerospace.enable = true;
  services.aerospace.settings = {
    # See: https://nikitabobko.github.io/AeroSpace/guide#default-config

    # You can use it to add commands that run after login to macOS user
    # session. 'start-at-login' needs to be 'true' for 'after-login-command'
    # to work Available commands:
    # https://nikitabobko.github.io/AeroSpace/commands
    after-login-command = [ ];

    # You can use it to add commands that run after AeroSpace startup.
    # 'after-startup-command' is run after 'after-login-command'
    # Available commands : https://nikitabobko.github.io/AeroSpace/commands
    after-startup-command = [ ];

    # Start AeroSpace at login
    # AeroSpace started at login is managed by home-manager and launchd instead
    # of itself via this option.
    start-at-login = false;

    # Normalizations. See: https://nikitabobko.github.io/AeroSpace/guide#normalization
    enable-normalization-flatten-containers = true;
    enable-normalization-opposite-orientation-for-nested-containers = true;

    # See: https://nikitabobko.github.io/AeroSpace/guide#layouts
    # The 'accordion-padding' specifies the size of accordion padding
    # You can set 0 to disable the padding feature
    accordion-padding = 30;

    # Possible values: tiles|accordion
    default-root-container-layout = "tiles";

    # Possible values: horizontal|vertical|auto
    # 'auto' means: wide monitor (anything wider than high) gets horizontal orientation,
    #               tall monitor (anything higher than wide) gets vertical orientation
    default-root-container-orientation = "auto";

    # Mouse follows focus when focused monitor changes
    # Drop it from your config, if you don't like this behavior
    # See https://nikitabobko.github.io/AeroSpace/guide#on-focus-changed-callbacks
    # See https://nikitabobko.github.io/AeroSpace/commands#move-mouse
    # Fallback value (if you omit the key): on-focused-monitor-changed = []
    on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];

    # You can effectively turn off macOS "Hide application" (cmd-h) feature by toggling this flag
    # Useful if you don't use this macOS feature, but accidentally hit cmd-h or cmd-alt-h key
    # Also see: https://nikitabobko.github.io/AeroSpace/goodies#disable-hide-app
    automatically-unhide-macos-hidden-apps = false;

    # Possible values: (qwerty|dvorak)
    # See https://nikitabobko.github.io/AeroSpace/guide#key-mapping
    key-mapping.preset = "qwerty";

    # Gaps between windows (inner-*) and between monitor edges (outer-*).
    # Possible values:
    # - Constant:     gaps.outer.top = 8
    # - Per monitor:  gaps.outer.top = [{ monitor.main = 16 }, { monitor."some-pattern" = 32 }, 24]
    #                 In this example, 24 is a default value when there is no match.
    #                 Monitor pattern is the same as for 'workspace-to-monitor-force-assignment'.
    #                 See:
    #                 https://nikitabobko.github.io/AeroSpace/guide#assign-workspaces-to-monitors
    gaps.inner.horizontal = 8;
    gaps.inner.vertical = 8;
    gaps.outer.left = 8;
    gaps.outer.bottom = 8;
    gaps.outer.top = 8;
    gaps.outer.right = 8;

    # Assign workspaces to monitors
    workspace-to-monitor-force-assignment = {
      "1" = [
        "built-in"
        "main"
      ];
      "2" = [
        "built-in"
        "main"
      ];
      "3" = [ "main" ];
      "4" = [ "main" ];
      "5" = [ "main" ];
      "6" = [ "main" ];
      "7" = [ "main" ];
      "8" = [ "main" ];
      "9" = [
        "secondary"
        "main"
      ];
      "0" = [
        "secondary"
        "main"
      ];
    };

    # 'main' binding mode declaration
    # See: https://nikitabobko.github.io/AeroSpace/guide#binding-modes
    # 'main' binding mode must be always presented
    # Fallback value (if you omit the key): mode.main.binding = {}
    mode.main.binding = {

      # All possible keys:
      # - Letters.        a, b, c, ..., z
      # - Numbers.        0, 1, 2, ..., 9
      # - Keypad numbers. keypad0, keypad1, keypad2, ..., keypad9
      # - F-keys.         f1, f2, ..., f20
      # - Special keys.   minus, equal, period, comma, slash, backslash, quote, semicolon,
      #                   backtick, leftSquareBracket, rightSquareBracket, space, enter, esc,
      #                   backspace, tab
      # - Keypad special. keypadClear, keypadDecimalMark, keypadDivide, keypadEnter, keypadEqual,
      #                   keypadMinus, keypadMultiply, keypadPlus
      # - Arrows.         left, down, up, right

      # All possible modifiers: cmd, alt, ctrl, shift

      # All possible commands: https://nikitabobko.github.io/AeroSpace/commands

      # See: https://nikitabobko.github.io/AeroSpace/commands#exec-and-forget
      # You can uncomment the following lines to open up terminal with alt + enter shortcut
      # (like in i3)
      # alt-enter = '''exec-and-forget osascript -e '
      # tell application "Terminal"
      #     do script
      #     activate
      # end tell'
      # '''

      # See: https://nikitabobko.github.io/AeroSpace/commands#layout
      alt-c = "layout tiles horizontal vertical";
      alt-x = "layout accordion horizontal vertical";

      # See: https://nikitabobko.github.io/AeroSpace/commands#focus
      alt-h = "focus left";
      alt-j = "focus down";
      alt-k = "focus up";
      alt-l = "focus right";

      # See: https://nikitabobko.github.io/AeroSpace/commands#move
      alt-shift-h = "move left";
      alt-shift-j = "move down";
      alt-shift-k = "move up";
      alt-shift-l = "move right";

      alt-ctrl-h = "join-with left";
      alt-ctrl-j = "join-with down";
      alt-ctrl-k = "join-with up";
      alt-ctrl-l = "join-with right";

      # See: https://nikitabobko.github.io/AeroSpace/commands#resize
      alt-ctrl-shift-h = "resize width -50";
      alt-ctrl-shift-j = "resize height +50";
      alt-ctrl-shift-k = "resize height -50";
      alt-ctrl-shift-l = "resize width +50";

      # See: https://nikitabobko.github.io/AeroSpace/commands#workspace
      alt-1 = "workspace 1";
      alt-2 = "workspace 2";
      alt-3 = "workspace 3";
      alt-4 = "workspace 4";
      alt-5 = "workspace 5";
      alt-6 = "workspace 6";
      alt-7 = "workspace 7";
      alt-8 = "workspace 8";
      alt-9 = "workspace 9";
      alt-0 = "workspace 0";

      # See: https://nikitabobko.github.io/AeroSpace/commands#move-node-to-workspace
      alt-shift-1 = "move-node-to-workspace 1";
      alt-shift-2 = "move-node-to-workspace 2";
      alt-shift-3 = "move-node-to-workspace 3";
      alt-shift-4 = "move-node-to-workspace 4";
      alt-shift-5 = "move-node-to-workspace 5";
      alt-shift-6 = "move-node-to-workspace 6";
      alt-shift-7 = "move-node-to-workspace 7";
      alt-shift-8 = "move-node-to-workspace 8";
      alt-shift-9 = "move-node-to-workspace 9";
      alt-shift-0 = "move-node-to-workspace 0";

      # See: https://nikitabobko.github.io/AeroSpace/commands#workspace-back-and-forth
      alt-tab = "workspace-back-and-forth";
      # See: https://nikitabobko.github.io/AeroSpace/commands#move-workspace-to-monitor
      alt-shift-tab = "move-workspace-to-monitor --wrap-around next";

      # See: https://nikitabobko.github.io/AeroSpace/commands#mode
      alt-shift-semicolon = "mode service";

      # Disable annoying and useless "hide application" shortcut
      # https://nikitabobko.github.io/AeroSpace/goodies#disable-hide-app
      cmd-h = [ ]; # Disable "hide application"
      cmd-alt-h = [ ]; # Disable "hide others"
    };

    # 'service' binding mode declaration.
    # See: https://nikitabobko.github.io/AeroSpace/guide#binding-modes
    mode.service.binding = {
      esc = [
        "reload-config"
        "mode main"
      ];
      r = [
        "flatten-workspace-tree"
        "mode main"
      ]; # reset layout
      f = [
        "layout floating tiling"
        "mode main"
      ]; # Toggle between floating and tiling layout
      backspace = [
        "close-all-windows-but-current"
        "mode main"
      ];

      # sticky is not yet supported https://github.com/nikitabobko/AeroSpace/issues/2
      #s = ["layout sticky tiling", "mode main"];

      down = "volume down";
      up = "volume up";
      shift-down = [
        "volume set 0"
        "mode main"
      ];
    };
  };

  ## AeroSpace Goodies
  # https://nikitabobko.github.io/AeroSpace/goodies

  # Move windows by dragging any part of the window
  #   defaults write -g NSWindowShouldDragOnGesture -bool true
  # Now, you can move windows by holding ctrl + cmd and dragging any part of
  # the window (not necessarily the window title)
  system.defaults.NSGlobalDomain.NSWindowShouldDragOnGesture = true;

  # Disable windows opening animations
  system.defaults.NSGlobalDomain.NSAutomaticWindowAnimationsEnabled = true;

}
