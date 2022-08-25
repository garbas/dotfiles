{ pkgs, lib, config, ... }:
{

  home.username = "rok";
  home.homeDirectory = "/home/rok";
  home.stateVersion = "22.11";

  home.sessionVariables.EDITOR = "nvim";
  home.sessionVariables.GIT_EDITOR = "nvim";
  home.sessionVariables.FZF_DEFAULT_COMMAND = "rg --files";

  home.shellAliases.grep = "rg";
  home.shellAliases.find = "fd";
  home.shellAliases.ps = "procs";
  home.shellAliases.cat = "bat";

  home.packages = with pkgs; [
    # shellAliases
    bat
    procs
    ripgrep

    tmate
    neovim
    tig

    kitty.terminfo
  ];

  programs.bat.enable = true;

  programs.direnv.enable = true;
  programs.direnv.enableZshIntegration = true;
  programs.direnv.nix-direnv.enable = true;

  programs.exa.enable = true;
  programs.exa.enableAliases = true;

  programs.fzf.enable = true;
  programs.fzf.enableZshIntegration = true;

  programs.gh.enable = true;

  programs.git.enable = true;
  programs.git.aliases.s = "status";
  programs.git.aliases.d = "diff";
  programs.git.aliases.ci = "commit -v";
  programs.git.aliases.cia = "commit -v -a";
  programs.git.aliases.co = "checkout";
  programs.git.aliases.l = "log --graph --oneline --decorate --all";
  programs.git.aliases.b = "branch";
  programs.git.delta.enable = true;
  programs.git.userEmail = "rok@garbas.si";
  programs.git.userName = "Rok Garbas";
  programs.git.extraConfig = {
    gpg.format = "ssh";
    user.signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGCCNUtXFFDYJelHhh9h2zSkTeYvvpgqWGpIdBogyCQU rok.garbas@iohk.io";
    commit.gpgsign = true;
    tag.gpgsign = true;
    status.submodulesummary = true;
    push.default = "simple";
  };

  programs.htop.enable = true;

  programs.hyfetch.enable = true;

  programs.jq.enable = true;

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

}
