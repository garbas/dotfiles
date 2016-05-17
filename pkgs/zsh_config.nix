{ fasd, xdg_utils, neovim, less, ... }:
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
  'fasd' \
  'nix' 

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


# Custom Aliases
alias j='${fasd}/bin/fasd -d'
alias jj='${fasd}/bin/fasd -si'
alias o='${fasd}/bin/fasd -a -e ${xdg_utils}/bin/xdg-open'
alias v='${fasd}/bin/fasd -f -e ${neovim}/bin/nvim'


export EDITOR='${neovim}/bin/nvim'
export VISUAL='${neovim}/bin/nvim'
export PAGER='${less}/bin/less -R'
''

