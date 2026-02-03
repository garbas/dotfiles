{ pkgs, ... }:
{
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

    # Session restoration with resurrect + continuum
    set -g @resurrect-capture-pane-contents 'on'
    set -g @continuum-restore 'on'
    set -g @continuum-save-interval '10'

  '';
}
