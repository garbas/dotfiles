{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # tmux-worktree: Create git worktree and open tmux window with claude
    (writeShellScriptBin "tmux-worktree" ''
      set -euo pipefail

      NAME="$1"
      PANE_ID="$2"

      if [ -z "$NAME" ]; then
          tmux display-message "Error: No worktree name provided"
          exit 1
      fi

      if [ -z "$PANE_ID" ]; then
          tmux display-message "Error: No pane ID provided"
          exit 1
      fi

      # Query the specific pane's current path using its ID
      PANE_PATH=$(tmux display-message -t "$PANE_ID" -p '#{pane_current_path}')

      if [ -z "$PANE_PATH" ]; then
          tmux display-message "Error: Could not get pane path"
          exit 1
      fi

      # Get the MAIN repo root (not worktree root) from the current pane's directory
      # Using --git-common-dir to handle being inside a worktree
      GIT_COMMON_DIR=$(cd "$PANE_PATH" && ${git}/bin/git rev-parse --git-common-dir 2>/dev/null)

      if [ -z "$GIT_COMMON_DIR" ]; then
          tmux display-message "Error: Not in a git repository"
          exit 1
      fi

      # Get the main repo root (parent of .git directory)
      REPO_ROOT=$(dirname "$GIT_COMMON_DIR")

      WORKTREE_PATH="$REPO_ROOT/w/$NAME"

      # Check if worktree already exists
      if [ -d "$WORKTREE_PATH" ]; then
          tmux display-message "Worktree already exists, opening: $WORKTREE_PATH"
      else
          # Create the w/ directory if it doesn't exist
          mkdir -p "$REPO_ROOT/w"

          # Create worktree with new branch
          if ! ${git}/bin/git -C "$REPO_ROOT" worktree add "$WORKTREE_PATH" -b "$NAME" 2>&1; then
              tmux display-message "Error: Failed to create worktree"
              exit 1
          fi
      fi

      # Create new window in the worktree directory
      tmux new-window -c "$WORKTREE_PATH" -n "$NAME"

      # Split horizontally (left/right) and run claude on the right
      tmux split-window -h -c "$WORKTREE_PATH" "claude"

      # Focus the left pane (the shell)
      tmux select-pane -L

      tmux display-message "Worktree ready: w/$NAME"
    '')

    # tmux-worktree-attach: Select and attach to existing worktree
    (writeShellScriptBin "tmux-worktree-attach" ''
      set -euo pipefail

      PANE_ID="$1"

      if [ -z "$PANE_ID" ]; then
          tmux display-message "Error: No pane ID provided"
          exit 1
      fi

      # Query the specific pane's current path using its ID
      PANE_PATH=$(tmux display-message -t "$PANE_ID" -p '#{pane_current_path}')

      if [ -z "$PANE_PATH" ]; then
          tmux display-message "Error: Could not get pane path"
          exit 1
      fi

      # Get the MAIN repo root (not worktree root) from the current pane's directory
      # Using --git-common-dir to handle being inside a worktree
      GIT_COMMON_DIR=$(cd "$PANE_PATH" && ${git}/bin/git rev-parse --git-common-dir 2>/dev/null)

      if [ -z "$GIT_COMMON_DIR" ]; then
          tmux display-message "Error: Not in a git repository"
          exit 1
      fi

      # Get the main repo root (parent of .git directory)
      REPO_ROOT=$(dirname "$GIT_COMMON_DIR")

      WORKTREE_DIR="$REPO_ROOT/w"

      # Check if worktree directory exists
      if [ ! -d "$WORKTREE_DIR" ]; then
          tmux display-message "No worktrees found (w/ directory doesn't exist)"
          exit 1
      fi

      # List worktree directories
      WORKTREES=$(find "$WORKTREE_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort)

      if [ -z "$WORKTREES" ]; then
          tmux display-message "No worktrees found in w/ directory"
          exit 1
      fi

      # Use fzf-tmux for selection
      SELECTED=$(echo "$WORKTREES" | ${fzf}/bin/fzf-tmux -p --reverse --header="Select worktree to attach:")

      if [ -z "$SELECTED" ]; then
          # User cancelled
          exit 0
      fi

      WORKTREE_PATH="$WORKTREE_DIR/$SELECTED"

      # Create new window in the worktree directory
      tmux new-window -c "$WORKTREE_PATH" -n "$SELECTED"

      # Split horizontally (left/right) and run claude on the right
      tmux split-window -h -c "$WORKTREE_PATH" "claude"

      # Focus the left pane (the shell)
      tmux select-pane -L

      tmux display-message "Attached to worktree: w/$SELECTED"
    '')
  ];

  programs.tmux.enable = true;
  programs.tmux.clock24 = true;
  programs.tmux.keyMode = "vi";
  programs.tmux.historyLimit = 10000;
  programs.tmux.newSession = true;
  programs.tmux.prefix = "C-Space";
  programs.tmux.shortcut = "Space";
  programs.tmux.baseIndex = 1;
  programs.tmux.mouse = true;
  programs.tmux.shell = "${pkgs.zsh}/bin/zsh";
  programs.tmux.plugins = with pkgs.tmuxPlugins; [
    catppuccin
    tmux-fzf
    resurrect
    continuum
  ];
  programs.tmux.extraConfig = ''
    set-option -g set-clipboard on

    # Allow passthrough of escape sequences (OSC 8 hyperlinks, etc.)
    set-option -g allow-passthrough on

    # Enable OSC 8 hyperlinks - allows clickable links in terminal
    # With mouse mode on, use Cmd+Shift+click (macOS) or Ctrl+Shift+click (Linux)
    # Requires tmux 3.4+ and server restart (tmux kill-server) after config change
    set -as terminal-features ",*:hyperlinks"

    # Auto-rename window to current folder name
    set-option -g status-interval 1
    set-option -g automatic-rename on
    set-option -g automatic-rename-format '#{b:pane_current_path}'

    # allow terminal scrolling
    set-option -g terminal-overrides 'xterm*:smcup@:rmcup@'

    # New windows start from home directory
    bind c new-window -c "~"

    # Splits stay in current directory
    bind | split-window -h -c "#{pane_current_path}"
    bind - split-window -v -c "#{pane_current_path}"
    unbind '"'
    unbind %

    # allow to use mouse
    set -g mouse on

    # panes
    set -g pane-border-style fg=black
    set -g pane-active-border-style fg=brightred

    # Dim inactive panes (brighter background for inactive, keeps text colors intact)
    set -g window-style 'bg=#313244,fg=#cdd6f4'
    set -g window-active-style 'bg=#1e1e2e,fg=#cdd6f4'

    # moving between panes vim style
    bind h select-pane -L
    bind j select-pane -D
    bind k select-pane -U
    bind l select-pane -R

    # resize the pane
    bind-key -r H resize-pane -L 3
    bind-key -r J resize-pane -D 3
    bind-key -r K resize-pane -U 3
    bind-key -r L resize-pane -R 3

    # Activity monitoring for attention notifications
    # This will highlight windows when they have activity (output) or bell signals
    set-option -g monitor-activity on
    set-option -g monitor-bell on
    set-option -g activity-action none  # Don't switch windows automatically
    set-option -g bell-action any       # Monitor bells in any window
    set-option -g visual-activity off   # Don't show "Activity in window X" message
    set-option -g visual-bell off       # Don't show bell message

    set -g status-left-length 100
    set -g status-left "#h "
    set-option -g @catppuccin_window_text " #W"
    set-option -g @catppuccin_window_current_text " #W"
    set-option -g status-right "#{E:@catppuccin_status_date_time}"

    # Override catppuccin formats to use window name (#W) instead of pane title (#T)
    # Normal window (no activity)
    set-option -g window-status-format "#[fg=#11111b,bg=#{@thm_overlay_2}] #I #[fg=#cdd6f4,bg=#{@thm_surface_0}] #W "
    # Current window
    set-option -g window-status-current-format "#[fg=#11111b,bg=#{@thm_mauve}] #I #[fg=#cdd6f4,bg=#{@thm_surface_1}] #W "
    # Window with activity/bell - using Catppuccin yellow (#f9e2af)
    set-option -g window-status-activity-style "fg=#11111b,bg=#f9e2af,bold"
    set-option -g window-status-bell-style "fg=#11111b,bg=#f9e2af,bold"

    # Worktree workflow: prefix + W prompts for name, creates worktree, opens split with claude
    # Pass pane_id so script can query that specific pane's path
    bind W command-prompt -p "Worktree name:" "run-shell 'tmux-worktree \"%%\" \"#{pane_id}\"'"

    # Worktree attach: prefix + w opens fzf picker to select existing worktree
    # Pass pane_id so script can query that specific pane's path
    bind w run-shell "tmux-worktree-attach '#{pane_id}'"

    # Session restoration with resurrect + continuum
    set -g @resurrect-capture-pane-contents 'on'
    set -g @continuum-restore 'on'
    set -g @continuum-save-interval '10'

  '';
}
