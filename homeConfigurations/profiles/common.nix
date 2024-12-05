{ pkgs, lib, config, user, hostname, inputs, ... }:
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
    inputs.flox.packages.${pkgs.system}.default
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
    kitty.terminfo
  ];

  nixpkgs.config.allowBroken = false;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreeRedistributable = true;

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
    gh-dash              # Dashboard of PRs and Issues
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
      condition = "hasconfig:remote.*.url:git@github.com\:garbas/**";
    }
  ];
  programs.git.userName = user.fullname;
  programs.git.userEmail = user.email;

  programs.git.enable = true;
  programs.git.package = pkgs.gitAndTools.gitFull;
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
  programs.keychain.agents = ["ssh"];
  programs.keychain.extraFlags = [
    "--quiet"
    "--nogui"
    "--quick"
  ];
  programs.keychain.keys = ["id_ed25519"];

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
    nord
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
  programs.zsh.initExtraBeforeCompInit = ''
    # for Docker Labs Debug Tools
    fpath=(~/.local/share/zsh/functions $fpath)
  '';
  programs.zsh.initExtra = ''
    # for Docker Labs Debug Tools
    export PATH="$PATH:/Users/${user.username}/.local/bin"
  '';
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
