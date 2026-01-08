{
  pkgs,
  user,
  inputs,
  ...
}:
{
  imports = [
    (import ./common_neovim.nix)
    (import ./modules/onepassword-secrets.nix)
  ];

  home.username = user.username;
  home.stateVersion = "22.11";

  home.sessionVariables.DIRENV_LOG_FORMAT = "";
  home.sessionVariables.EDITOR = "nvim";
  home.sessionVariables.FZF_DEFAULT_COMMAND = "rg --files";
  home.sessionVariables.GIT_EDITOR = "nvim";

  home.packages = with pkgs; [
    # Nix tooling
    devbox
    devenv
    nix-output-monitor
    nix-tree
    nixd

    # AI
    claude-code

    # Misc
    asciinema
    coreutils
    entr
    fd
    file
    gnutar
    htop
    jq
    procs
    ripgrep
    tig
    tmate
    tree
    unzip
    wget
    which
    _1password-cli

    bash-language-server

  ];

  # So happy when home manager is almost having Ghostty support hours after release:
  # See https://github.com/nix-community/home-manager/pull/6235
  xdg.configFile."ghostty/config".text = ''
    font-family = Iosevka Nerd Font Mono
    font-size = 14
    macos-titlebar-style = hidden
    window-padding-x = 10
    window-padding-y = 10
    theme = dark:catppuccin-mocha.conf,light:catppuccin-latte.conf

    # Send macOS notification when bell is triggered (e.g., Claude Code needs attention)
    macos-notification-on-bell = true
  '';
  xdg.configFile."ghostty/themes/catppuccin-latte.conf".source =
    "${inputs.catppuccin-ghostty}/themes/catppuccin-latte.conf";
  xdg.configFile."ghostty/themes/catppuccin-frappe.conf".source =
    "${inputs.catppuccin-ghostty}/themes/catppuccin-frappe.conf";
  xdg.configFile."ghostty/themes/catppuccin-macchiato.conf".source =
    "${inputs.catppuccin-ghostty}/themes/catppuccin-macchiato.conf";
  xdg.configFile."ghostty/themes/catppuccin-mocha.conf".source =
    "${inputs.catppuccin-ghostty}/themes/catppuccin-mocha.conf";

  # Enable 1Password secrets loading
  services.onepassword-secrets = {
    enable = true;
    account = "my.1password.com";
    item = "Terminal";
    secrets = [
      "OPENAI_API_KEY"
      "HF_TOKEN"
      "CLAUDE_GITHUB_MCP_TOKEN"
    ];
  };

  programs.bat.enable = true;

  programs.direnv.enable = true;
  programs.direnv.enableZshIntegration = true;
  programs.direnv.nix-direnv.enable = true;

  programs.eza.enable = true;
  programs.eza.enableZshIntegration = true;
  programs.eza.git = true;
  programs.eza.icons = "auto";

  programs.fzf.enable = true;
  programs.fzf.enableZshIntegration = true;
  programs.fzf.tmux.enableShellIntegration = true;

  programs.gh.enable = true;
  programs.gh.settings.git_protocol = "ssh";
  programs.gh.settings.editor = "nvim";
  programs.gh.settings.prompt = "enabled";
  programs.gh.settings.aliases.co = "pr checkout";
  programs.gh.settings.aliases.v = "pr view";
  programs.gh.settings.extensions = with pkgs; [
    #gh-poi               # Safely cleanup local branches
    #gh-markdown-preview  # README preview
    gh-dash # Dashboard of PRs and Issues
    #gh-label             # Label management
    #gh-milestone         # Milestone management
    #gh-notify            # Display notifications
    #gh-changelog         # Create changelogs (https://keepachangelog.com)
    #gh-s                 # Search Github repositories
  ];

  xdg.configFile."git/config-me".text = ''
    [user]
      name = ${user.fullname}
      email = ${user.email}
  '';
  programs.git.includes = [
    {
      path = "~/.config/git/config-me";
      condition = "hasconfig:remote.*.url:git@github.com:garbas/**";
    }
  ];
  programs.git.settings.user.name = user.fullname;
  programs.git.settings.user.email = user.email;

  programs.git.enable = true;
  #programs.git.package = pkgs.git.override {
  #  svnSupport = false;
  #  guiSupport = false;
  #  sendEmailSupport = true;
  #  withSsh = true;
  #  withLibsecret = !pkgs.stdenv.isDarwin;
  #};
  programs.git.settings.alias.s = "status";
  programs.git.settings.alias.d = "diff";
  programs.git.settings.alias.ci = "commit -v";
  programs.git.settings.alias.cia = "commit -v -a";
  programs.git.settings.alias.co = "checkout";
  programs.git.settings.alias.l = "log --graph --oneline --decorate --all";
  programs.git.settings.alias.b = "branch";
  # list branches sorted by last modified
  programs.git.settings.alias.bb =
    "!git for-each-ref --sort='-authordate' --format='%(authordate)%09%(objectname:short)%09%(refname)' refs/heads | sed -e 's-refs/heads/--'";
  programs.git.settings.alias.entr = "!git ls-files -cdmo --exclude-standard | entr -d";
  programs.git.lfs.enable = true;
  programs.git.settings.gpg.format = "ssh";
  programs.git.settings.user.signingKey = user.sshKey;
  programs.git.settings.commit.gpgsign = true;
  programs.git.settings.tag.gpgsign = true;
  programs.git.settings.status.submodulesummary = true;
  programs.git.settings.push.default = "simple";
  programs.git.settings.push.autoSetupRemote = true;
  programs.git.settings.init.defaultBranch = "main";

  programs.delta.enable = true;
  programs.delta.enableGitIntegration = true;

  programs.htop.enable = true;

  programs.jq.enable = true;

  programs.keychain.enable = true;
  programs.keychain.enableZshIntegration = true;
  #programs.keychain.agents = [ "ssh" ];
  programs.keychain.extraFlags = [
    "--quiet"
    "--nogui"
    "--quick"
  ];
  programs.keychain.keys = [ "id_ed25519" ];

  programs.lazygit.enable = true;
  programs.lazygit.settings =
    let
      importYAML =
        file:
        builtins.fromJSON (
          builtins.readFile (
            pkgs.runCommandNoCC "import-yaml.json" ''${pkgs.yj}/bin/yj < "${file}" > "$out"''
          )
        );
      catppuccinTheme = importYAML "${inputs.catppuccin-lazygit}/themes/mocha/blue.yml";
    in
    {
      gui.theme = {
        activeBorderColor = [
          "'#89b4fa"
          "bold"
        ];
        inactiveBorderColor = [ "#a6adc8" ];
        optionsTextColor = [ "#89b4fa" ];
        selectedLineBgColor = [ "#313244" ];
        cherryPickedCommitBgColor = [ "#45475a" ];
        cherryPickedCommitFgColor = [ "#89b4fa" ];
        unstagedChangesColor = [ "#f38ba8" ];
        defaultFgColor = [ "#cdd6f4" ];
        searchingActiveBorderColor = [ "#f9e2af" ];
      };
      gui.authorColors = {
        "*" = "#b4befe";
      };
    };

  programs.less.enable = true;

  programs.man.enable = true;

  #programs.nix-index.enable = true;
  #programs.nix-index.enableZshIntegration = true;

  programs.ssh.enable = true;
  programs.ssh.enableDefaultConfig = false;
  programs.ssh.matchBlocks."*".controlMaster = "auto";
  programs.ssh.matchBlocks."*".controlPath = "~/.ssh/%r@%h:%p";
  programs.ssh.matchBlocks."*".controlPersist = "60m";
  programs.ssh.matchBlocks."*".serverAliveInterval = 120;
  programs.ssh.extraConfig = ''
    TCPKeepAlive yes
    HostKeyAlgorithms ssh-ed25519-cert-v01@openssh.com,ssh-rsa-cert-v01@openssh.com,ssh-ed25519,ssh-rsa,ecdsa-sha2-nistp256-cert-v01@openssh.com,ecdsa-sha2-nistp521-cert-v01@openssh.com,ecdsa-sha2-nistp384-cert-v01@openssh.com,ecdsa-sha2-nistp521,ecdsa-sha2-nistp384,ecdsa-sha2-nistp256
  '';

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
  ];
  programs.tmux.extraConfig = ''
    set-option -g set-clipboard on

    # disable automatic window renaming to respect manual names
    set-option -g automatic-rename off
    set-option -g allow-rename off

    # allow terminal scrolling
    set-option -g terminal-overrides 'xterm*:smcup@:rmcup@'

    # easier to remember split pane command
    bind | split-window -h
    bind - split-window -v
    unbind '"'
    unbind %

    # allow to use mouse
    set -g mouse on

    # panes
    set -g pane-border-style fg=black
    set -g pane-active-border-style fg=brightred

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

    set-option -g status-left ""
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

  '';

  # XXX: this are UI programs
  #programs.vscode.enable = true;

  #programs.zed-editor.enable = true;

  programs.zoxide.enable = true;
  programs.zoxide.enableZshIntegration = true;

  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.autocd = true;
  programs.zsh.autosuggestion.enable = true;
  programs.zsh.syntaxHighlighting.enable = true;
  programs.zsh.defaultKeymap = "viins";
  programs.zsh.history.expireDuplicatesFirst = true;
  programs.zsh.plugins = [
    {
      file = "powerlevel10k.zsh-theme";
      name = "powerlevel10k";
      src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k";
    }
    {
      file = "p10k.zsh";
      name = "powerlevel10k-config";
      src = "${./.}";
    }
  ];
}
