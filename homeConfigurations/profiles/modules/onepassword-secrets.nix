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

    cacheDir = mkOption {
      type = types.str;
      default = "";
      description = "Directory for caching secrets. Defaults to XDG_RUNTIME_DIR or /tmp";
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

    programs.zsh.initContent = ''
      # Load secrets from 1Password with caching (JSON format)
      _load_op_secrets() {
        # Only run if op is available
        if ! command -v op &> /dev/null; then
          return 0
        fi

        # Determine cache directory and file
        local CACHE_DIR="${cfg.cacheDir}"
        if [ -z "$CACHE_DIR" ]; then
          CACHE_DIR="''${XDG_RUNTIME_DIR:-/tmp}"
        fi
        local CACHE_FILE="$CACHE_DIR/op-secrets-cache-$USER.json"

        # Function to check if all secrets are in cache
        _check_cache() {
          ${optionalString cfg.debug ''echo "DEBUG: Checking cache file: $CACHE_FILE"''}

          if [ ! -f "$CACHE_FILE" ]; then
            ${optionalString cfg.debug ''echo "DEBUG: Cache file does not exist"''}
            return 1
          fi

          ${optionalString cfg.debug ''echo "DEBUG: Cache file exists, checking secrets..."''}

          # Check each required secret exists and is non-empty in cache
          ${concatMapStringsSep "\n" (secret: ''
            local ${secret}_VAL
            ${secret}_VAL=$(jq -r '.${secret} // empty' "$CACHE_FILE" 2>/dev/null)
            ${optionalString cfg.debug ''echo "DEBUG: ${secret} = '${"$" + "${secret}_VAL"}'"''}
            if [ -z "''$${secret}_VAL" ]; then
              ${optionalString cfg.debug ''echo "DEBUG: ${secret} is empty or missing, cache invalid"''}
              return 1
            fi
          '') cfg.secrets}
          ${optionalString cfg.debug ''echo "DEBUG: All secrets found in cache"''}
          return 0
        }

        # Function to load secrets from cache
        _load_from_cache() {
          echo "🔑 Loading secrets from $CACHE_FILE"
          ${concatMapStringsSep "\n" (secret: ''
            export ${secret}=$(jq -r '.${secret} // empty' "$CACHE_FILE")
            if [ -n "''$${secret}" ]; then
              echo "  󰐊 Loaded ${secret}"
            fi
          '') cfg.secrets}
        }

        # Function to fetch from 1Password and update cache
        _fetch_and_cache() {
          echo "🔑 Authenticating with 1Password..."

          # Check if already signed in (fast check, avoids re-auth)
          if ! op account list &> /dev/null; then
            # Sign in (interactive, only happens once per session)
            eval $(op --account ${cfg.account} signin 2>/dev/null)
          fi

          # Load all secrets in one efficient API call
          local OP_SECRETS
          if OP_SECRETS="$(op --account ${cfg.account} item get ${cfg.item} --format json 2>/dev/null)"; then
            echo "🔑 Caching secrets to $CACHE_FILE"

            # Create cache file with restrictive permissions
            rm -f "$CACHE_FILE"
            touch "$CACHE_FILE"
            chmod 600 "$CACHE_FILE"

            # Build JSON object with secrets
            echo "$OP_SECRETS" | jq '
              .fields | map(select(.label as $l | ${builtins.toJSON cfg.secrets} | index($l))) |
              map({(.label): .value}) | add // {}
            ' > "$CACHE_FILE"

            # Export and display
            ${concatMapStringsSep "\n" (secret: ''
              export ${secret}=$(jq -r '.${secret} // empty' "$CACHE_FILE")
              if [ -n "''$${secret}" ]; then
                echo "  󰐊 Cached ${secret}"
              fi
            '') cfg.secrets}
          else
            echo "  Failed to fetch secrets from 1Password"
            return 1
          fi
        }

        # Main logic: check cache first, fetch if needed
        if _check_cache; then
          _load_from_cache
        else
          _fetch_and_cache
        fi

        # Cleanup helper functions
        unset -f _check_cache
        unset -f _load_from_cache
        unset -f _fetch_and_cache
      }

      _load_op_secrets
      unset -f _load_op_secrets
    '';
  };
}
