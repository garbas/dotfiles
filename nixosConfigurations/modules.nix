{
  config,
  pkgs,
  lib,
  ...
}:

# https://github.com/benley/dotfiles/blob/master/modules/dunst.nix
with lib;
let
  cfg = config.services.dunst;
  dunstrcFile = pkgs.writeText "dunstrc" cfg.config;
in

{
  options.services.dunst = {
    enable = mkEnableOption "Dunst desktop notification daemon";

    config = mkOption {
      type = types.nullOr types.string;
      default = null;
      description = "Contents of the dunstrc config file";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.dunst ];
    services.dbus.packages = [ pkgs.dunst ];

    # Dunst packages a systemd unit but we need to modify it
    # systemd.packages = [ pkgs.dunst ];

    systemd.user.services.dunst = {
      description = "Dunst notification daemon";
      documentation = [ "man:dunst(1)" ];
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "dbus";
        BusName = "org.freedesktop.Notifications";
        ExecStart = lib.concatStringsSep " " (
          [ "${pkgs.dunst}/bin/dunst" ] ++ (lib.optional (!isNull cfg.config) "-config ${dunstrcFile}")
        );
      };
    };
  };
}
