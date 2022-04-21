{ pkgs, lib, config, ... }:

let
  gtkTheme = "Nordic";  # via nordic
  gtkIconTheme = "Nordzy-dark";  # via nordzy-icon-theme
  gtkCursorTheme = "Nordzy-cursors";  # via nordzy-cursor-theme

  checkNixosUpdates = pkgs.writeShellScript "checkUpdates.sh" ''
    UPDATE='{"icon":"upd","state":"Info", "text": ""}'
    NO_UPDATE='{"icon":"noupd","state":"Good", "text": ""}'
    GITHUB_URL="https://api.github.com/repos/NixOS/nixpkgs/git/refs/heads/nixos-unstable"
    CURRENT_REVISION=$(nixos-version --revision)
    REMOTE_REVISION=$(curl -s $GITHUB_URL | jq '.object.sha' -r )
    [ $CURRENT_REVISION == $REMOTE_REVISION ] && echo $NO_UPDATE || echo $UPDATE
  '';
  idleCmd = ''swayidle -w \
    timeout 300 'swaylock --daemonize --ignore-empty-password --color 3c3836' \
    timeout 600 'swaymsg "output * dpms off"' \
         resume 'swaymsg "output * dpms on"' \
    before-sleep 'swaylock --daemonize --ignore-empty-password --color 3c3836'
  '';
  gsettings = "${pkgs.glib}/bin/gsettings";
  gnomeSchema = "org.gnome.desktop.interface";
  systemdRun = { pkg, bin ? pkg.pname, args ? "" }: ''
    systemd-run --user --scope --collect --quiet --unit=${bin} \
    systemd-cat --identifier=${bin} ${lib.makeBinPath [ pkg ]}/${bin} ${args}
  '';
  importGsettings = pkgs.writeShellScript "import_gsettings.sh" ''
    ${gsettings} set ${gnomeSchema} gtk-theme ${gtkTheme}
    ${gsettings} set ${gnomeSchema} icon-theme ${gtkIconTheme}
    ${gsettings} set ${gnomeSchema} cursor-theme ${gtkCursorTheme}
  '';

  mod = config.wayland.windowManager.sway.config.modifier;

  # outputs
  output = {
    # TODO: left = "DP-5";
    right = "DP-5";
    laptop = "eDP-1";
  };

  # Define names for default workspaces for which we configure key bindings later on.
  # We use variables to avoid repeating the names in multiple places.
  workspace = {
    "01" = "1: ";
    "02" = "2: ";
    "03" = "3: ";
    "04" = "4: ";
    "05" = "5: ";
    "06" = "6: ";
    "07" = "7: ";
    "08" = "8: ";
    "09" = "9: ";
    "10" = "10: ";
  };

  # Nord theme
  # -> https://github.com/sarveshspatil111/i3wm-nord/blob/main/.config/i3/config#L414
  colors = {
    base00 = "#101218";
    base01 = "#1f222d";
    base02 = "#252936";
    base03 = "#5e81ac";
    base04 = "#C0C5CE";
    base05 = "#d1d4e0";
    base06 = "#C9CCDB";
    base07 = "#ffffff";
    base08 = "#ee829f";
    base09 = "#f99170";
    base0A = "#ffefcc";
    base0B = "#a5ffe1";
    base0C = "#97e0ff";
    base0D = "#97bbf7";
    base0E = "#c0b7f9";
    base0F = "#fcc09e";
  };
in

{
  #./home/alacritty

  #./home/firefox.nix
  #programs.firefox = {
  #  enable = true;
  #  extensions = with pkgs.nur.repos.rycee.firefox-addons; [
  #    lastpass-password-manager
  #    decentraleyes
  #    multi-account-containers
  #    ublock-origin
  #    https-everywhere
  #    bitwarden
  #  ];
  #  profiles = {
  #    default = {
  #      isDefault = true;
  #      settings = {
  #        "extensions.pocket.enabled" = false;
  #        "gfx.webrender.all" = true;
  #        "gfx.webrender.enabled" = true;
  #        "layers.acceleration.force-enabled" = true;
  #        "layers.force-active" = true;
  #        "widget.wayland-dmabuf-vaapi.enabled" = true;
  #        "widget.content.allow-gtk-dark-theme" = false;
  #      };
  #    };
  #  };
  #};

  #./home/gammastep.nix
  services.gammastep.enable = true;
  services.gammastep.latitude = "46.056946";
  services.gammastep.longitude = "14.505751";
  services.gammastep.temperature.day = 5500;
  services.gammastep.temperature.night = 3700;
  services.gammastep.tray = true;

  #./home/gtk.nix
  qt.enable = true;
  qt.platformTheme = "gtk";
  gtk = {
    enable = true;
    theme = {
      package = pkgs.nordic;
      name = gtkTheme;
    };
    iconTheme = {
      package = pkgs.nordzy-icon-theme;
      name = gtkIconTheme;
    };
    gtk2.extraConfig = ''
      gtk-cursor-theme-size = 16
      gtk-cursor-theme-name = "${gtkCursorTheme}"
    '';
    gtk3.extraConfig = {
      gtk-cursor-theme-size = 16;
      gtk-cursor-theme-name = gtkCursorTheme;
    };
  };

  #./home/mako.nix
# TODO: services.fnott.enable
  programs.mako = {
    backgroundColor = "#3c3836";
    borderColor = "#b16286";
    borderRadius = 6;
    borderSize = 2;
    defaultTimeout = 5000;
    enable = true;
    font = "Iosevka 12";
    layer = "overlay";
    textColor = "#ebdbb2";
  };

  #./home/sway.nix
  wayland.windowManager.sway.enable = true;
  wayland.windowManager.sway.wrapperFeatures.gtk = true;
  wayland.windowManager.sway.systemdIntegration = true;
  wayland.windowManager.sway.config.gaps.smartBorders = "on";
  wayland.windowManager.sway.config.fonts.names = [ "Fira Code Light" ];
  wayland.windowManager.sway.config.fonts.size = 8.0;
  wayland.windowManager.sway.config.modifier = "Mod4";
  wayland.windowManager.sway.config.menu = "dmenu-wl_run -i";
  wayland.windowManager.sway.config.terminal = "kitty";
  wayland.windowManager.sway.config.floating.modifier = "Mod4";
  wayland.windowManager.sway.config.keybindings = {
    "${mod}+Return" = "exec ${config.wayland.windowManager.sway.config.terminal}";

    # kill focused window
    "${mod}+Shift+q" = "kill";

    # reload the configuration file
    "${mod}+Shift+c" = "reload";

    # restart inplace (preserves your layout/session, can be used to upgrade i3)
    "${mod}+Shift+r" = "restart";

    # start dmenu (a program launcher)
    # TODO: bindsym $mod+space exec --no-startup-id rofi -show drun
    "${mod}+Space" = "exec dmenu-wl_run -i";
    "${mod}+d" = "exec dmenu-wl_run -i";

    # TODO: exit
    #bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -b 'Yes, exit i3' 'i3-msg exit'"
    #bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -b 'Yes, exit i3' 'xfce4-session-logout'"

    "${mod}+t" = "border normal";
    "${mod}+y" = "border 1pixel";
    "${mod}+u" = "border none";
    "${mod}+b" = "border toggle";

    # change focus
    "${mod}+h" = "focus left";
    "${mod}+j" = "focus down";
    "${mod}+k" = "focus up";
    "${mod}+l" = "focus right";

    # move focused window
    "${mod}+Shift+h" = "move left";
    "${mod}+Shift+j" = "move down";
    "${mod}+Shift+k" = "move up";
    "${mod}+Shift+l" = "move right";

    # split in horizontal orientation
    "${mod}+x" = "split h";

    # split in vertical orientation
    "${mod}+z" = "split v";

    # enter fullscreen mode for the focused container
    "${mod}+f" = "fullscreen toggle";

    # change container layout (stacked, tabbed, toggle split)
    "${mod}+s" = "layout stacking";
    "${mod}+w" = "layout tabbed";
    "${mod}+e" = "layout toggle split";

    # change between 2 recent workspaces
    "${mod}+Tab" = "workspace back_and_forth";

    # focus the parent container
    "${mod}+Shift+a" = "focus parent";

    # focus the child container
    "${mod}+Shift+d" = "focus child";

    # toggle tiling / floating
    "${mod}+Shift+space" = "floating toggle";

    # Make the currently focused window a scratchpad
    "${mod}+Shift+BackSpace" = "move scratchpad";

    # Show the first scratchpad window
    "${mod}+BackSpace" = "scratchpad show";

    # switch to workspace
    "${mod}+1" = "workspace ${workspace."01"}";
    "${mod}+2" = "workspace ${workspace."02"}";
    "${mod}+3" = "workspace ${workspace."03"}";
    "${mod}+4" = "workspace ${workspace."04"}";
    "${mod}+5" = "workspace ${workspace."05"}";
    "${mod}+6" = "workspace ${workspace."06"}";
    "${mod}+7" = "workspace ${workspace."07"}";
    "${mod}+8" = "workspace ${workspace."08"}";
    "${mod}+9" = "workspace ${workspace."09"}";
    "${mod}+0" = "workspace ${workspace."10"}";

    # move focused container to workspace
    "${mod}+Shift+1" = "move container to workspace ${workspace."01"}";
    "${mod}+Shift+2" = "move container to workspace ${workspace."02"}";
    "${mod}+Shift+3" = "move container to workspace ${workspace."03"}";
    "${mod}+Shift+4" = "move container to workspace ${workspace."04"}";
    "${mod}+Shift+5" = "move container to workspace ${workspace."05"}";
    "${mod}+Shift+6" = "move container to workspace ${workspace."06"}";
    "${mod}+Shift+7" = "move container to workspace ${workspace."07"}";
    "${mod}+Shift+8" = "move container to workspace ${workspace."08"}";
    "${mod}+Shift+9" = "move container to workspace ${workspace."09"}";
    "${mod}+Shift+0" = "move container to workspace ${workspace."10"}";

    "${mod}+r" = "mode \"resize\"";

    "XF86AudioPlay" = "exec playerctl play-pause";
    "XF86AudioNext" = "exec playerctl next";
    "XF86AudioPrev" = "exec playerctl previous";
    "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
    "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
    "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
    "XF86MonBrightnessDown" = "exec light -U 5%";
    "XF86MonBrightnessUp" = "exec light -A 5%";
    "--release Print" = "exec grimshot --notify save area ~/scr/scr_`date +%Y%m%d.%H.%M.%S`.png";
    "--release ${mod}+Print" = "exec grimshot --notify save output ~/scr/scr_`date +%Y%m%d.%H.%M.%S`.png";
    # TODO: services.flameshot.enable

    # bindsym XF86AudioRaiseVolume exec --no-startup-id pactl set-sink-volume $out_sink +5% && killall -s USR1 py3status
    # bindsym XF86AudioLowerVolume exec --no-startup-id pactl set-sink-volume $out_sink -5% && killall -s USR1 py3status
    # bindsym XF86AudioMute exec --no-startup-id pactl set-sink-mute $out_sink toggle && killall -s USR1 py3status
    # bindsym XF86AudioMicMute exec --no-startup-id pactl set-source-mute $in_source toggle && killall -s USR1 py3status
    # bindsym XF86MonBrightnessDown exec --no-startup-id xbacklight -dec 5 && killall -s USR1 py3status
    # bindsym XF86MonBrightnessUp exec --no-startup-id xbacklight -inc 10 && killall -s USR1 py3status

  };

  # assign workspace to screen
  wayland.windowManager.sway.config.workspaceOutputAssign = [
    { workspace = workspace."01"; output = output.laptop; }
    { workspace = workspace."02"; output = output.laptop; }
    { workspace = workspace."03"; output = output.laptop; }
    { workspace = workspace."04"; output = output.right;  }
    { workspace = workspace."05"; output = output.right;  }
    { workspace = workspace."06"; output = output.right;  }
    { workspace = workspace."07"; output = output.right;  }
    { workspace = workspace."08"; output = output.right;  }
    { workspace = workspace."09"; output = output.right;  }
    { workspace = workspace."10"; output = output.right;  }
  ];

  # resize window (you can also use the mouse for that)
  wayland.windowManager.sway.config.modes.resize = {
    "${mod}+r" = "mode default";
    "Escape" = "mode default";
    "Return" = "mode default";
    "h" = "resize shrink width 20 px";
    "j" = "resize grow height 20 px";
    "k" = "resize shrink height 20 px";
    "l" = "resize grow width 20 px";
  };


  ## Start i3bar to display a workspace bar (plus the system information
  ## i3status finds out, if available)
  #bar {
  #  position bottom
  #  status_command i3status-rs
  #  tray_output $laptop_screen
  #  tray_padding 0
  #  separator_symbol "‖"

  #  colors {
  #    separator  $base01
  #    background $base01
  #    statusline #81a1c1

  #    #                   border  background text
  #    focused_workspace  $base01 $base01    #81a1c1 
  #    active_workspace   $base01 $base02    $base03
  #    inactive_workspace $base01 $base01    #4c566a
  #    urgent_workspace   $base01 $base01    $base08
  #    binding_mode       $base01 #81a1c1    #2e3440
  #  }
  #}

    #lib.mkOptionDefault {
    #  "${mod}+Tab" = "workspace back_and_forth";
    #  "${mod}+Shift+f" = "exec ${systemdRun { pkg = pkgs.firefox; bin = "firefox";} }";
    #  "${mod}+Shift+o" = "exec ${systemdRun { pkg = pkgs.obs-studio; bin = "obs";} }";
    #  "${mod}+Shift+s" = "exec ${systemdRun { pkg = pkgs.slack; args= "--logLevel=error";} }";
    #};


  # GAPS
  wayland.windowManager.sway.config.gaps.smartGaps = true;


  # SWAY / COLORS
  wayland.windowManager.sway.config.colors.background      = "#242424";
  wayland.windowManager.sway.config.colors.focused         = { background = "#81a1c1"; border = "#81a1c1"; childBorder = "#81a1c1"; indicator = "#81a1c1"; text = "#ffffff"; };
  wayland.windowManager.sway.config.colors.focusedInactive = { background = "#2e3440"; border = "#2e3440"; childBorder = "#2e3440"; indicator = "#2e3440"; text = "#888888"; };
  wayland.windowManager.sway.config.colors.placeholder     = { background = "#2e3440"; border = "#2e3440"; childBorder = "#2e3440"; indicator = "#2e3440"; text = "#888888"; };
  wayland.windowManager.sway.config.colors.unfocused       = { background = "#2e3440"; border = "#2e3440"; childBorder = "#2e3440"; indicator = "#2e3440"; text = "#888888"; };
  wayland.windowManager.sway.config.colors.urgent          = { background = "#900000"; border = "#900000"; childBorder = "#900000"; indicator = "#900000"; text = "#ffffff"; };

  # BAR
  wayland.windowManager.sway.config.bars = [];

  # INPUTS
  wayland.windowManager.sway.config.input."type:keyboard".repeat_delay = "300";
  wayland.windowManager.sway.config.input."type:keyboard".repeat_rate = "20";
  wayland.windowManager.sway.config.input."type:keyboard".xkb_options = "ctrl:nocaps";

  wayland.windowManager.sway.config.input."type:touchpad".dwt = "enabled";
  wayland.windowManager.sway.config.input."type:touchpad".middle_emulation = "enabled";
  wayland.windowManager.sway.config.input."type:touchpad".tap = "enabled";

  # TODO:
  #wayland.windowManager.sway.config.output.eDP-1 = { pos = "0 0"; scale = "2"; };
  #wayland.windowManager.sway.config.output.DP-1 = { pos = "0 0"; scale = "2"; };

  # WINDOWS
  wayland.windowManager.sway.config.window.titlebar = false;
  wayland.windowManager.sway.config.window.hideEdgeBorders = "smart";
  wayland.windowManager.sway.config.window.commands = [
    {
      criteria = { app_id = "gsimplecal"; };
      command = "floating enable";
    }
    { 
      criteria = { app_id = "firefox";
                   title = "About Mozilla Firefox";
                 };
      command = "floating enable"; 
    }
    { 
      criteria = { app_id = "^(?i)slack$"; };
      command = "move container to workspace 2";
    }
    { 
      criteria = { app_id = "firefox"; };
      command = "move container to workspace 3";
    }
    { 
      criteria = { title = "Save File"; };
      command = "floating enable, resize set width 600px height 800px";
    }
    { # browser zoom|meet|bluejeans
      criteria = { title = "(Blue Jeans)|(Meet)|(Zoom Meeting)"; };
      command = "inhibit_idle visible";
    }
    { 
      criteria = { title = "(Sharing Indicator)"; };
      command = "inhibit_idle visible, floating enable";
    }
    { 
      criteria = { class = "pavucontrol"; };
      command = "floating enable";
    }
    { 
      criteria = { class = "1Password"; };
      command = "floating enable";
    }
  ];

  wayland.windowManager.sway.config.startup = [
    { command = "dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY DBUS_SESSION_BUS_ADDRESS SWAYSOCK XDG_SESSION_TYPE XDG_SESSION_DESKTOP XDG_CURRENT_DESKTOP"; } #workaround
    { command = "${idleCmd}"; }
    { command = "${importGsettings}"; always = true; }
    #{ command = "systemctl --user restart waybar"; always = true; }
    { command = "kitty"; }
    { command = "nm-applet --indicator"; }
    #{ command = "pasystray"; }
    #{ command = "element-desktop --no-update --hidden"; }
    { command = "blueman-applet"; }
  ];

  wayland.windowManager.sway.extraConfig = ''
    seat seat0 xcursor_theme "${gtkCursorTheme}"
    seat seat0 hide_cursor 60000
  '';

  programs.waybar.enable = true;
  programs.waybar.settings.main.layer = "bottom";
  programs.waybar.settings.main.position = "bottom";
  programs.waybar.settings.main.output = builtins.attrValues output;
  programs.waybar.settings.main.height = 25;
  programs.waybar.settings.main.spacing = 4;
  programs.waybar.settings.main.modules-left = [
    "sway/workspaces"
    "sway/mode"
  ];
  programs.waybar.settings.main.modules-center = [
    "sway/window"
  ];
  programs.waybar.settings.main.modules-right = [
    "network"
    "cpu"
    "memory"
    "temperature"
    "backlight"
    "pulseaudio"
    "battery"
    "clock"
    "tray"
  ];
  programs.waybar.settings.main."sway/workspaces".disable-scroll = true;
  programs.waybar.settings.main."sway/workspaces".disable-markup = false;
  programs.waybar.settings.main."sway/mode".format = "<span style=\"italic\">{}</span>";
  programs.waybar.settings.main."network".format-wifi = "{essid} ({signalStrength}%) ";
  programs.waybar.settings.main."network".format-ethernet = "{ifname}: {ipaddr}/{cidr} ";
  programs.waybar.settings.main."network".format-disconnected = "Disconnected ⚠";
  programs.waybar.settings.main."network".interval = 7;
  programs.waybar.settings.main."cpu".format = "CPU: {usage}% ";
  programs.waybar.settings.main."memory".format = "MEM: {}% ";
  programs.waybar.settings.main."temperature".critical-threshold = 80;
  programs.waybar.settings.main."temperature".format = "{temperatureC}°C ";
  programs.waybar.settings.main."backlight".format = "{percent}% {icon}";
  programs.waybar.settings.main."backlight".states = [0 50];
  programs.waybar.settings.main."backlight".format-icons = ["" ""];
  programs.waybar.settings.main."pulseaudio".format = "{volume}% {icon}";
  programs.waybar.settings.main."pulseaudio".format-bluetooth = ": {volume}% {icon}";
  programs.waybar.settings.main."pulseaudio".format-muted = "";
  programs.waybar.settings.main."pulseaudio".format-icons.headphones = "";
  programs.waybar.settings.main."pulseaudio".format-icons.handsfree = "";
  programs.waybar.settings.main."pulseaudio".format-icons.headset = "";
  programs.waybar.settings.main."pulseaudio".format-icons.phone = "";
  programs.waybar.settings.main."pulseaudio".format-icons.portable = "";
  programs.waybar.settings.main."pulseaudio".format-icons.car = "";
  programs.waybar.settings.main."pulseaudio".format-icons.default = ["" ""];
  programs.waybar.settings.main."pulseaudio".on-click = "pavucontrol";
  programs.waybar.settings.main."battery".states.good = 95;
  programs.waybar.settings.main."battery".states.warning = 30;
  programs.waybar.settings.main."battery".states.critical = 15;
  programs.waybar.settings.main."battery".format = "{capacity}% {icon}";
  programs.waybar.settings.main."battery".format-icons = ["" "" "" "" ""];
  programs.waybar.settings.main."clock".format = "{:%F %H:%M}";
  programs.waybar.settings.main."tray".icon-size = 21;
  programs.waybar.settings.main."tray".spacing = 10;
  programs.waybar.systemd.enable = true;
  programs.waybar.systemd.target = "sway-session.target";
  systemd.user.services.waybar.Service.ExecStart = lib.mkForce "${pkgs.waybar}/bin/waybar -b 0";


  # TODO: KANSHI - Dynamic display configuration
  #services.kanshi.enable = true;
  #services.kanshi.profiles.undocked.outputs = [{ criteria = output.laptop; }];
  #services.kanshi.profiles.docked.outputs = [
  #  { criteria = output.laptop; }
  #  #{ criteria = output.left; }
  #  { criteria = output.right; }
  #];
  #services.kanshi.systemdTarget = "sway-session.target";


  # NETWORK MANAGER APPLET
  services.network-manager-applet.enable = true;

  services.blueman-applet.enable = true;

  # PASYSTRAY - PULSEAUDIO SYSTEM TRAY
  services.pasystray.enable = true;

  # PARCELLITE - THE LIGHTWEIGHT GTK+ CLIPBOARD MANAGER.
  #TODO: services.parcellite.enable = true;

  # PLAYERCTL - MEDIA PLAYER COMMAND-LINE CONTROLLER FOR VLC, MPV, WEB BROWSERS, SPOTIFY AND OTHERS.
  # TODO: services.playerctld.enable = true;
  # TODO: configure playerctl with shortcuts and waybar

  # TODO: services.poweralertd.enable = true;
  # TODO: services.pulseeffects.enable = true;
  # TODO: services.swayidle.enable = true;

  # TODO: fancier lock
  # https://github.com/mortie/swaylock-effects
  # https://www.reddit.com/r/swaywm/comments/mtc11k/swaylock_trying_to_have_a_somewhat_nice_locker/

  services.udiskie.enable = true;

  # TODO: services.gromit-mpx.enable
  # To use with remarkable



  # TODO: services.espanso.enable
  # TODO: services.git-sync.enable
  # TODO: services.gnome-keyring.enable
  # TODO: services.gpg-agent.enable
  # TODO: services.dropbox.enable

  xdg.enable = true;
  # TODO: xdg.desktopEntries
  xdg.mime.enable = true;
  # TODO: xdg.mimeApps.enable = true;
  xdg.userDirs.enable = true;
  xdg.userDirs.createDirectories = true;

}
