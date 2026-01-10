{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.onepassword-secrets;
  opSecretsLib = import ../../../lib/op-secrets.nix { inherit lib; };
  inherit (opSecretsLib) mkOpSecretsShellHook;
in
{
  options.services.onepassword-secrets = {
    enable = mkEnableOption "1Password secrets loader";

    account = mkOption {
      type = types.str;
      default = "my.1password.com";
      description = "1Password account to use";
    };

    item = mkOption {
      type = types.str;
      default = "Terminal";
      description = "1Password item containing secrets";
    };

    secrets = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "List of secret field labels to export";
    };

    cacheId = mkOption {
      type = types.str;
      default = "zsh-terminal";
      description = "Unique identifier for cache file. Cache stored at $XDG_RUNTIME_DIR/op-secrets-<cacheId>-$USER.json";
    };

    debug = mkOption {
      type = types.bool;
      default = false;
      description = "Enable debug output for troubleshooting";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs._1password-cli
      pkgs.jq
    ];

    programs.zsh.initContent = mkOpSecretsShellHook {
      inherit (cfg)
        cacheId
        account
        item
        secrets
        debug
        ;
    };
  };
}
