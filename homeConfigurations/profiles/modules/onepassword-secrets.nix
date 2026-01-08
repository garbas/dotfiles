{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.onepassword-secrets;
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
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs._1password-cli
      pkgs.jq
    ];

    programs.zsh.initExtra = ''
      # Load secrets from 1Password
      _load_op_secrets() {
        # Only run if op is available
        if ! command -v op &> /dev/null; then
          return 0
        fi

        # Check if already signed in (fast check, avoids re-auth)
        if ! op account list &> /dev/null; then
          # Sign in (interactive, only happens once per session)
          eval $(op --account ${cfg.account} signin 2>/dev/null)
        fi

        # Load all secrets in one efficient API call
        local __secrets
        if __secrets="$(op --account ${cfg.account} item get ${cfg.item} --format json 2>/dev/null)"; then
          echo "🔑 Loading secrets from 1Password"
          ${concatMapStringsSep "\n" (secret: ''
            export ${secret}=$(echo "$__secrets" | jq -r '.fields[] | select(.label == "${secret}") | .value' 2>/dev/null)
            if [ -n "$${secret}" ]; then
              echo "  󰐊 Exported ${secret}"
            fi
          '') cfg.secrets}
          unset __secrets
        fi
      }

      _load_op_secrets
      unset -f _load_op_secrets
    '';
  };
}
