{
  network.description = "Floki";
  floki =
    { config, pkgs, lib, ... }:
    {

      nixpkgs.config = {
        allowUnfree = true;
        packageOverrides = pkgs: import ./../pkgs { inherit pkgs; };
      };

      i18n.consoleFont = "lat9w-16";
      i18n.consoleKeyMap = "us";
      i18n.defaultLocale = "en_US.UTF-8";

      services.xserver.enable = false;

      services.openssh.enable = true;
      services.openssh.permitRootLogin = "yes";

      networking.hostName = "floki";
      networking.hostId = "cff52adb";

      networking.firewall.allowedTCPPorts = [ 22 80 ];
      networking.firewall.allowedUDPPortRanges = [ { from = 60000; to = 61000; } ];

      environment.systemPackages = with pkgs; [
        tmux
        htop
        mosh
        vim
        git
        rxvt_unicode.terminfo
      ];

      users.extraUsers.root = {
       openssh.authorizedKeys.keys = [
        "ssh-dss AAAAB3NzaC1kc3MAAACBAMSjkowfIlAJn80+5ccsUpG0Dsunbg9nVzGJF4ZU2QlcqC8Hbw7WzhvUgqE5HY4eFxdrbX5nISZTokOT2lyoRH2bIbcCILFwFOoUvdCbbG/M/X+9lOm1cRe9DG20HbhxxquAC9PAKGvUBWRmRhRUv/jyEHITX/0Sq6IyK/VaP/xjAAAAFQD1osCdij1P/Hw8nBBaUYGPDJOeJwAAAIBdKBHJUWBwJyDr1Q/lrRrVjddNP2m9gMt3cJr+7KfpENcjODBsHIpFJNkwIhYfxZSJntij7NxYL2QlI6I9j1dLG4yXH/2kgK+1R4htUTAWDspDGNj7+SruNtVmCvtIDQH3Az+95qCOxYZyOocuWE/6MoqhzRgQQUer44M+KFX6xwAAAIAVwMXUyT0s5tp5wyR+87L6lp9kDR8Fey++K9H91k4p2i/EMI4k4zyvIWHKUqKpDmjvcxQmizpfKeceZv6lPYcXo7CO4dDFoR6U1gIcGYCM1Rgfxacsp10NbwA2DBO1VplNB7ffGx0nGRKRtUP4ZFkbzJiORYxr3RY4Q42HVAV9Eg== rok@oskar"
        ];
      };

      # From: http://www.mythmon.com/posts/2015-02-15-systemd-weechat.html
      systemd.services."weechat" = with pkgs; {
        enable = true;
        description = "Weechat IRC Client (in tmux)";
        environment = { TERM = "${rxvt_unicode.terminfo}"; };
        path = [ tmux weechat rxvt_unicode.terminfo ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = "yes";
          ExecStart = "${tmux}/bin/tmux -S /run/tmux-weechat new-session -d -s weechat -n 'weechat' '${weechat}/bin/weechat-curses -d /root/dotfiles/pkgs/weechat'";
          ExecStop = "${tmux}/bin/tmux -S /run/tmux-weechat kill-session -t weechat";
        };
      };
    };
}
