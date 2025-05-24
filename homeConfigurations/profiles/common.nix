{
  pkgs,
  user,
  inputs,
  ...
}:
{
  imports = [
    (import ./common_neovim.nix)
  ];

  home.username = user.username;
  home.stateVersion = "22.11";

  home.sessionVariables.DIRENV_LOG_FORMAT = "";
  home.sessionVariables.EDITOR = "nvim";
  home.sessionVariables.FZF_DEFAULT_COMMAND = "rg --files";
  home.sessionVariables.GIT_EDITOR = "nvim";

  home.packages = with pkgs; [
    inputs.devenv.packages.${pkgs.system}.default
    asciinema
    devbox
    asdf
    coreutils
    entr
    fd
    file
    gnutar
    htop
    jq
    nix-output-monitor
    procs
    ripgrep
    tig
    tmate
    tree
    unzip
    wget
    which
    _1password-cli
  ];

  # So happy when home manager is almost having Ghostty support hours after release:
  # See https://github.com/nix-community/home-manager/pull/6235
  xdg.configFile."ghostty/config".text = ''
    font-family = Iosevka Nerd Font Mono
    font-size = 14
    macos-titlebar-style = hidden
    window-padding-x = 10
    window-padding-y = 10
    theme = dark:catppuccin-mocha,light:catppuccin-latte
  '';
  xdg.configFile."ghostty/themes/catppuccin-latte.conf".source =
    "${inputs.catppuccin-ghostty}/themes/catppuccin-latte.conf";
  xdg.configFile."ghostty/themes/catppuccin-frappe.conf".source =
    "${inputs.catppuccin-ghostty}/themes/catppuccin-frappe.conf";
  xdg.configFile."ghostty/themes/catppuccin-macchiato.conf".source =
    "${inputs.catppuccin-ghostty}/themes/catppuccin-macchiato.conf";
  xdg.configFile."ghostty/themes/catppuccin-mocha.conf".source =
    "${inputs.catppuccin-ghostty}/themes/catppuccin-mocha.conf";

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
  programs.git.userName = user.fullname;
  programs.git.userEmail = user.email;

  programs.git.enable = true;
  #programs.git.package = pkgs.git.override {
  #  svnSupport = false;
  #  guiSupport = false;
  #  sendEmailSupport = true;
  #  withSsh = true;
  #  withLibsecret = !pkgs.stdenv.isDarwin;
  #};
  programs.git.aliases.s = "status";
  programs.git.aliases.d = "diff";
  programs.git.aliases.ci = "commit -v";
  programs.git.aliases.cia = "commit -v -a";
  programs.git.aliases.co = "checkout";
  programs.git.aliases.l = "log --graph --oneline --decorate --all";
  programs.git.aliases.b = "branch";
  # list branches sorted by last modified
  programs.git.aliases.bb = "!git for-each-ref --sort='-authordate' --format='%(authordate)%09%(objectname:short)%09%(refname)' refs/heads | sed -e 's-refs/heads/--'";
  programs.git.aliases.entr = "!git ls-files -cdmo --exclude-standard | entr -d";
  programs.git.lfs.enable = true;
  programs.git.delta.enable = true;
  programs.git.extraConfig = {
    gpg.format = "ssh";
    user.signingKey = user.sshKey;
    commit.gpgsign = true;
    tag.gpgsign = true;
    status.submodulesummary = true;
    push.default = "simple";
    push.autoSetupRemote = true;
    init.defaultBranch = "main";
  };

  programs.htop.enable = true;

  programs.jq.enable = true;

  programs.keychain.enable = true;
  programs.keychain.enableZshIntegration = true;
  programs.keychain.agents = [ "ssh" ];
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
  programs.ssh.controlMaster = "auto";
  programs.ssh.controlPath = "~/.ssh/%r@%h:%p";
  programs.ssh.controlPersist = "60m";
  programs.ssh.serverAliveInterval = 120;
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

  '';

  programs.vscode.enable = true;

  programs.zed-editor.enable = true;

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
