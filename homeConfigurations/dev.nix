{ sshKey
, username
, email
, fullname
}:
{ pkgs, lib, config, ... }:
{

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "22.11";

  home.sessionVariables.EDITOR = "nvim";
  home.sessionVariables.GIT_EDITOR = "nvim";
  home.sessionVariables.FZF_DEFAULT_COMMAND = "rg --files";

  home.shellAliases.grep = "rg";
  home.shellAliases.find = "fd";
  home.shellAliases.ps = "procs";
  home.shellAliases.cat = "bat";

  home.packages = with pkgs; [
    procs
    ripgrep

    tmate
    neovim
    tig

    kitty.terminfo
    gitAndTools.git
  ];

  programs.bat.enable = true;

  programs.direnv.enable = true;
  programs.direnv.enableZshIntegration = true;
  programs.direnv.nix-direnv.enable = true;

  programs.exa.enable = true;
  programs.exa.enableAliases = true;

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

  programs.git.enable = true;
  programs.git.aliases.s = "status";
  programs.git.aliases.d = "diff";
  programs.git.aliases.ci = "commit -v";
  programs.git.aliases.cia = "commit -v -a";
  programs.git.aliases.co = "checkout";
  programs.git.aliases.l = "log --graph --oneline --decorate --all";
  programs.git.aliases.b = "branch";
  programs.git.delta.enable = true;
  programs.git.userEmail = email;
  programs.git.userName = fullname;
  programs.git.extraConfig = {
    gpg.format = "ssh";
    user.signingKey = sshKey;
    commit.gpgsign = true;
    tag.gpgsign = true;
    status.submodulesummary = true;
    push.default = "simple";
    push.autoSetupRemote = true;
  };

  programs.htop.enable = true;

  programs.hyfetch.enable = true;
  programs.hyfetch.settings = {
    preset = "boyflux2";
    mode = "rgb";
    light_dark = "dark";
    lightness = null;
    color_align.mode = "custom";
    color_align.custom_colors."1" = 5;
    color_align.custom_colors."2" = 6;
    color_align.fore_back = [];
  };

  programs.jq.enable = true;

  programs.keychain.enable = true;
  programs.keychain.enableZshIntegration = true;
  programs.keychain.agents = ["ssh"];
  programs.keychain.extraFlags = ["--nogui"];
  programs.keychain.keys = ["id_ed25519"];

  programs.less.enable = true;

  programs.man.enable = true;

  programs.nix-index.enable = true;
  programs.nix-index.enableZshIntegration = true;

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
  programs.tmux.prefix = "C-Space";
  programs.tmux.shortcut = "Space";
  programs.tmux.baseIndex = 1;
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

  programs.zoxide.enable = true;
  programs.zoxide.enableZshIntegration = true;

  programs.zsh.enable = true;
  programs.zsh.enableAutosuggestions = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.enableSyntaxHighlighting = true;
  programs.zsh.autocd = true;
  programs.zsh.defaultKeymap = "viins";
  programs.zsh.history.expireDuplicatesFirst = true;
  programs.zsh.initExtraBeforeCompInit = ''
    # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
    # Initialization code that may require console input (password prompts, [y/n]
    # confirmations, etc.) must go above this block; everything else may go below.
    if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
      source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
    fi
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
  programs.zsh.loginExtra = ''
    hyfetch
  '';
}
