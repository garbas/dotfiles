{ nixpkgs }:
{ config, pkgs, lib, ... }:
{

  documentation.info.enable = true;

  environment.shellAliases.grep = "rg";
  environment.shellAliases.ls = "exa";
  environment.shellAliases.find = "fd";
  environment.shellAliases.du = "dust";
  environment.shellAliases.ps = "procs";
  environment.shellAliases.cat = "bat";
  environment.etc."gitconfig".source = ./../gitconfig;  # TODO: create configurable package
  environment.variables.EDITOR = lib.mkForce "nvim";
  environment.variables.FZF_DEFAULT_COMMAND = "rg --files";
  environment.variables.GIT_EDITOR = lib.mkForce "nvim";
  environment.pathsToLink = [ "/share/nix-direnv" ];
  environment.systemPackages = with pkgs; [
    # nix tools
    direnv
    nix-direnv
    niv
    rnix-lsp
    nix-index
    nixpkgs-fmt
    nixpkgs-review
    morph

    # devops / cloud tools
    minikube
    kubectl
    terraform
    docker-compose
    awscli2

    # version control
    gitAndTools.gitflow
    gitAndTools.hub
    gitAndTools.gh
    gitFull
    git-lfs
    git-town  # TODO: configure and integrate with git and zsh
    mercurialFull
    tig

    # improved console utilities
    bat            # cat
    ripgrep        # grep
    exa            # ls
    fd             # find
    procs          # ps
    sd             # sed
    # TODO: fails to build with latest nixpkgs
    # dust           # du

    # commonly used console utilities
    jq
    entr
    neofetch
    fzf
    zoxide

    # common console tools
    file
    tree
    unzip
    wget
    which

    # terminal
    kitty

    # other console tools
    asciinema    # terminal recorder
    htop         # a better top
    hyperfine    # benchmarking tool
    scrot        # taking screenshort
    sshuttle     # proxy via ssh
    tokei        # show statistics about your code
    youtube-dl   # downloading videos

    # password managers
    gopass
    _1password
  ];

  i18n.defaultLocale = "en_US.UTF-8";

  networking.extraHosts = ''
    116.203.16.150 floki floki.garbas.si
    127.0.0.1 ${config.networking.hostName}
    ::1 ${config.networking.hostName}
  '';

  nix.package = pkgs.nixVersions.stable;
  nix.registry.nixpkgs.flake = nixpkgs;
  nix.nixPath = [
    "nixpkgs=${nixpkgs}"
    "nixos-config=/etc/nixos/configuration.nix"
  ];
  nix.settings.sandbox = true;
  nix.settings.trusted-users = ["@wheel" "rok"];
  nix.distributedBuilds = true;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
    builders-use-substitutes = true

    # for nix-direnv
    keep-outputs = true
    keep-derivations = true
  '';

  nixpkgs.config.allowBroken = false;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreeRedistributable = true;
  nixpkgs.overlays = [
    # for nix-direnv
    (self: super: { nix-direnv = super.nix-direnv.override { enableFlakes = true; }; } )
  ];

  programs.command-not-found.enable = false;
  programs.gnupg.agent.enable = true;
  programs.gnupg.agent.enableBrowserSocket = true;
  programs.gnupg.agent.enableSSHSupport = true;
  programs.mosh.enable = true;
  programs.ssh.forwardX11 = false;
  programs.zsh.enable = true;
  programs.zsh.enableBashCompletion = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.autosuggestions.enable = true;
  programs.zsh.syntaxHighlighting.enable = true;
  programs.zsh.vteIntegration = true;
  programs.zsh.shellInit = ''
    source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh

    eval "$(direnv hook zsh)"
    eval "$(zoxide init zsh)"

    source ${pkgs.fzf}/share/fzf/completion.zsh
    source ${pkgs.fzf}/share/fzf/key-bindings.zsh


    source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh
    bindkey "^[[A" history-substring-search-up
    bindkey "^[[B" history-substring-search-down
    bindkey "$terminfo[kcuu1]" history-substring-search-up
    bindkey "$terminfo[kcud1]" history-substring-search-down
    bindkey -M emacs '^P' history-substring-search-up
    bindkey -M emacs '^N' history-substring-search-down
    bindkey -M vicmd 'k' history-substring-search-up
    bindkey -M vicmd 'j' history-substring-search-down

    source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
  '';

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  services.locate.enable = true;
  services.openssh.enable = true;

  time.timeZone = "Europe/Ljubljana";

  users.defaultUserShell = pkgs.zsh;
}

