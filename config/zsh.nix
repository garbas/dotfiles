{ writeText, fzf, xdg_utils, neovim, less, zsh-prezto }:

let
  self = writeText "zsh-config"
    ''
      # Color output (auto set to 'no' on dumb terminals).
      zstyle ':prezto:*:*' color 'yes'

      # Set the Prezto modules to load (browse modules).
      # The order matters.
      zstyle ':prezto:load' pmodule \
        'environment' \
        'terminal' \
        'editor' \
        'history' \
        'history-substring-search'\
        'directory' \
        'spectrum' \
        'utility' \
        'completion' \
        'prompt' \
        'fasd'

      # Set the key mapping style to 'emacs' or 'vi'.
      zstyle ':prezto:module:editor' key-bindings 'vi'

      # Ignore submodules when they are 'dirty', 'untracked', 'all', or 'none'.
      zstyle ':prezto:module:git:status:ignore' submodules 'all'

      # Set the query found color.
      zstyle ':prezto:module:history-substring-search:color' found '''

      # Set the query not found color.
      zstyle ':prezto:module:history-substring-search:color' not-found '''

      # Set the search globbing flags.
      zstyle ':prezto:module:history-substring-search' globbing-flags '''

      # Set the prompt theme to load.
      # Setting it to 'random' loads a random theme.
      # Auto set to 'off' on dumb terminals.
      zstyle ':prezto:module:prompt' theme 'sorin'

      # Set the SSH identities to load into the agent.
      zstyle ':prezto:module:ssh:load' identities 'id_rsa' 'id_rsa2' 'id_github'

      # Set syntax highlighters.
      # By default, only the main highlighter is enabled.
      zstyle ':prezto:module:syntax-highlighting' highlighters \
        'main' \
        'brackets' \
        'pattern' \
        'cursor' \
        'root'

      # Set syntax highlighting styles.
      zstyle ':prezto:module:syntax-highlighting' styles \
        'builtin' 'bg=blue' \
        'command' 'bg=blue' \
        'function' 'bg=blue'

      # Auto set the tab and window titles.
      zstyle ':prezto:module:terminal' auto-title 'yes'

      # Set the window title format.
      zstyle ':prezto:module:terminal:window-title' format '%n@%m: %s'


      # -------------------------------------------------


      # fd - cd to selected directory
      j() {
        local dir
        dir=$(find ''${1:-*} -path '*/\.*' -prune \
                        -o -type d -print 2> /dev/null | ${fzf}/bin/fzf +m) &&
        cd "$dir"
      }

      # fda - including hidden directories
      ja() {
        local dir
        dir=$(find ''${1:-.} -type d 2> /dev/null | ${fzf}/bin/fzf +m) && cd "$dir"
      }

      # fdr - cd to selected parent directory
      jj() {
        local declare dirs=()
        get_parent_dirs() {
          if [[ -d "''${1}" ]]; then dirs+=("$1"); else return; fi
          if [[ "''${1}" == '/' ]]; then
            for _dir in "''${dirs[@]}"; do echo $_dir; done
          else
            get_parent_dirs $(dirname "$1")
          fi
        }
        local DIR=$(get_parent_dirs $(realpath "''${1:-$(pwd)}") | ${fzf}/bin/fzf-tmux --tac)
        cd "$DIR"
      }

      export EDITOR='${neovim}/bin/nvim'
      export VISUAL='${neovim}/bin/nvim'
      export PAGER='${less}/bin/less -R'
    '';
in {
  light = self;
  dark = self;
  environment_etc =
    [ { source = "${zsh-prezto}/runcoms/zlogin";
        target = "zlogin";
      }
      { source = "${zsh-prezto}/runcoms/zlogout";
        target = "zlogout";
      }
      { source = self;
        target = "zpreztorc";
      }
      { source = "${zsh-prezto}/runcoms/zprofile";
        target = "zprofile.local";
      }
      { source = "${zsh-prezto}/runcoms/zshenv";
        target = "zshenv.local";
      }
      { source = "${zsh-prezto}/runcoms/zshrc";
        target = "zshrc.local";
      }
    ];
  packages = {
      inherit fzf xdg_utils neovim less;
  };
}
