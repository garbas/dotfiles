# Shared function to generate shell code for 1Password secrets with caching
#
# Usage:
#   mkOpSecretsShellHook {
#     cacheId = "devshell-dotfiles";  # Unique ID for cache file
#     account = "my.1password.com";
#     item = "Terminal";
#     secrets = [ "API_KEY" "TOKEN" ];
#     debug = false;  # optional
#   }
#
# Cache file location: $XDG_RUNTIME_DIR/op-secrets-<cacheId>-$USER.json
{ lib }:
{
  mkOpSecretsShellHook =
    {
      cacheId,
      account,
      item,
      secrets,
      debug ? false,
    }:
    let
      secretsJson = builtins.toJSON secrets;
      funcName = "load_op_secrets_" + (lib.replaceStrings [ "-" ] [ "_" ] cacheId);
      debugEcho = msg: if debug then ''echo "DEBUG: ${msg}"'' else "";
    in
    ''
      # 1Password secrets loader with caching (cache: ${cacheId})
      ${funcName}() {
        # Only run if op is available
        if ! command -v op &> /dev/null; then
          echo "⚠️  1Password CLI (op) not found, skipping secrets loading"
          return 0
        fi

        # Determine cache directory and file
        local CACHE_DIR="''${XDG_RUNTIME_DIR:-/tmp}"
        local CACHE_FILE="$CACHE_DIR/op-secrets-${cacheId}-$USER.json"

        ${debugEcho "Cache file: $CACHE_FILE"}

        # Function to check if all secrets are in cache
        _check_cache() {
          if [ ! -f "$CACHE_FILE" ]; then
            ${debugEcho "Cache file does not exist"}
            return 1
          fi

          ${debugEcho "Checking secrets in cache..."}

          # Check each required secret exists and is non-empty
          ${lib.concatMapStringsSep "\n      " (secret: ''
            local ${secret}_val
            ${secret}_val=$(jq -r '.${secret} // empty' "$CACHE_FILE" 2>/dev/null)
            if [ -z "$${secret}_val" ]; then
              ${debugEcho "${secret} missing or empty"}
              return 1
            fi'') secrets}

          ${debugEcho "All secrets found in cache"}
          return 0
        }

        # Function to load secrets from cache
        _load_from_cache() {
          echo "🔑 Loading secrets from cache"
          ${lib.concatMapStringsSep "\n      " (secret: ''
            export ${secret}=$(jq -r '.${secret} // empty' "$CACHE_FILE")
            if [ -n "''$${secret}" ]; then
              echo "  ✓ Loaded ${secret}"
            fi'') secrets}
        }

        # Function to fetch from 1Password and update cache
        _fetch_and_cache() {
          echo "🔑 Authenticating with 1Password..."

          # Check if already signed in
          if ! op account list &> /dev/null; then
            eval $(op --account ${account} signin 2>/dev/null)
          fi

          # Load all secrets in one API call
          local OP_SECRETS
          if OP_SECRETS="$(op --account ${account} item get ${item} --format json 2>/dev/null)"; then
            echo "🔑 Caching secrets"

            # Create cache file with restrictive permissions
            rm -f "$CACHE_FILE"
            touch "$CACHE_FILE"
            chmod 600 "$CACHE_FILE"

            # Build JSON object with only requested secrets
            echo "$OP_SECRETS" | jq '
              .fields | map(select(.label as $l | ${secretsJson} | index($l))) |
              map({(.label): .value}) | add // {}
            ' > "$CACHE_FILE"

            # Export secrets
            ${lib.concatMapStringsSep "\n      " (secret: ''
              export ${secret}=$(jq -r '.${secret} // empty' "$CACHE_FILE")
              if [ -n "''$${secret}" ]; then
                echo "  ✓ Cached ${secret}"
              fi'') secrets}
          else
            echo "  ❌ Failed to fetch secrets from 1Password"
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
        unset -f _check_cache _load_from_cache _fetch_and_cache
      }

      ${funcName}
      unset -f ${funcName}
    '';
}
