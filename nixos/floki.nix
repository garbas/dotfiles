{ secrets }:

let

  isGmail = secrets.gmail_user != null ||
            secrets.gmail_pass != null;

  isSSL = secrets.nginx_garbas_ssl_certificate != null ||
          secrets.nginx_garbas_ssl_certificate_key != null ||
          secrets.nginx_garbas_ssl_dhparam != null;

  isDD = secrets.datadog_api_key != null ||
         secrets.datadog_postgresql_password != null;

  isLogentries = secrets.logentries_token != null;

  _pkgs = import <nixpkgs> {};

  hydraSrc = _pkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "hydra";
    #rev = "633381a5010e8b859b0d0eb20e21a61aa50f8aba";
    #sha256 = "12pbzp79hmzchmkq7mzh20iw2slbrizdbxr6w7akybgc791f8b74";
    rev = "993647d1e3b43f1f9b7dc2ebce889b475d156bb9";
    sha256 = "115z4prns7mxf8yxygvficq6c00gzi1qizj121qqpl1af521f8r9";
  };

  hydraRelease = import "${hydraSrc}/release.nix" {
    inherit hydraSrc;
    officialRelease = true;
  };

  hydraModule = import "${hydraSrc}/hydra-module.nix";

  # https://logentries.com/doc/nixos/
  logentries-crt = _pkgs.fetchurl {
    url = https://bits.lecdn.net/certs/1/logentries.all.crt;
    sha256 = "1ppsr783pd05ymcrwdqyxaw977hahzzzdy5na0ma9fslz5h9sxmj";
  };

in

{ config, pkgs, lib, ... }:
let

  createSite = domain: config:
    ''
      server {
        listen                  80;
        server_name             ${domain};
    '' + (lib.optionalString isSSL ''
        return                  301 https://${domain}$request_uri;
      }

      server {
        listen                  443 ssl;
        server_name             ${domain};

        # certs sent to the client in SERVER HELLO are concatenated in ssl_certificate
        ssl                         on;
        ssl_certificate             ${secrets.nginx_garbas_ssl_certificate};
        ssl_certificate_key         ${secrets.nginx_garbas_ssl_certificate_key};
        ssl_session_timeout         1d;
        ssl_session_cache           shared:SSL:50m;

        # Diffie-Hellman parameter for DHE ciphersuites, recommended 2048 bits
        ssl_dhparam                 ${secrets.nginx_garbas_ssl_dhparam};

        # modern configuration.
        ssl_protocols               TLSv1.1 TLSv1.2;
        ssl_ciphers                 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!3DES:!MD5:!PSK';
        ssl_prefer_server_ciphers   on;

        # HSTS (ngx_http_headers_module is required) (15768000 seconds = 6 months)
        add_header                  Strict-Transport-Security max-age=15768000;

        # OCSP Stapling ---
        # fetch OCSP records from URL in ssl_certificate and cache them
        ssl_stapling                on;
        ssl_stapling_verify         on;

        ## verify chain of trust of OCSP response using Root CA and Intermediate certs

        resolver                    127.0.0.1 [::1];

    '') + config + ''

      }
    '';

  createStaticSite = domain: createSite domain ''
    location / {
      alias                     /var/www/static/${domain}/;
      autoindex                 off;
    }

    location /__status__ {
        stub_status;
    }
  '';

  hydra = builtins.getAttr config.nixpkgs.system hydraRelease.build;

in {

  assertions = pkgs.lib.singleton {
    assertion = pkgs.system == "x86_64-linux";
    message = "unsupported system ${pkgs.system}";
  };

  imports = [ hydraModule ];

  nix.distributedBuilds = true;
  nix.nrBuildUsers = 30;
  nix.extraOptions = ''
    build-use-chroot = relaxed
    auto-optimise-store = true
  '';
  nix.binaryCaches = [
    #"https://cache.nixos.org/"
    "https://hydra.nixos.org"
  ];
  nix.binaryCachePublicKeys = [
    "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
  ];
  nix.gc.automatic = true;
  nix.gc.dates = "05:15";
  nix.gc.options = ''--max-freed "$((12 * 1024**3 - 1024 * $(df -P -k /nix/store | tail -n 1 | ${pkgs.gawk}/bin/awk '{ print $4 }')))"'';

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.packageOverrides = pkgs: import ./../pkgs { inherit pkgs; };

  #
  # Initialization commands
  #
  # on nixops server:
  # - ssh-keygen -C "hydra@hydra.example.org" -N "" -f id_buildfarm
  #
  # on master server:
  #   - hydra-create-user garbas --full-name 'Rok Garbas' --email-address 'rok@garbas.si' --password 'XXX' --role admin
  #   - install -d -m 551 /etc/nix/hydra.garbas.si-1
  #   - nix-store --generate-binary-cache-key hydra.garbas.si-1 /etc/nix/hydra.garbas.si-1/secret /etc/nix/hydra.garbas.si-1/public
  #   - chown -R hydra:hydra /etc/nix/hydra.garbas.si-1
  #   - chmod 440 /etc/nix/hydra.garbas.si-1/secret
  #   - chmod 444 /etc/nix/hydra.garbas.si-1/public
  services.hydra.enable = true;
  services.hydra.dbi = "dbi:Pg:dbname=hydra;user=hydra;";
  services.hydra.package = hydra;
  services.hydra.hydraURL = "http://hydra.garbas.si/";
  services.hydra.listenHost = "0.0.0.0";
  services.hydra.port = 3000;
  services.hydra.extraConfig = "binary_cache_secret_key_file = /etc/nix/hydra.garbas.si-1/secret";
  services.hydra.minimumDiskFree = 2;  # in GB
  services.hydra.minimumDiskFreeEvaluator = 1;
  services.hydra.notificationSender = "hydra@garbas.si";
  services.hydra.logo = null;
  services.hydra.debugServer = false;

  services.xserver.enable = false;

  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";

  services.fail2ban.enable = true;

  services.dnsmasq.enable = true;
  services.dnsmasq.servers = [ "8.8.8.8" "8.8.4.4" ];

  networking.hostName = "floki";
  networking.hostId = "cff52adb";

  networking.firewall.allowedTCPPorts = [ 22 80 443 ];
  networking.firewall.allowedUDPPortRanges = [ { from = 60000; to = 61000; } ];

  networking.defaultMailServer.directDelivery = isGmail;
  networking.defaultMailServer.hostName = "smtp.gmail.com:587";
  networking.defaultMailServer.root = "floki@garbas.si";
  networking.defaultMailServer.domain = "garbas.si";
  networking.defaultMailServer.useTLS = true;
  networking.defaultMailServer.useSTARTTLS = true;
  networking.defaultMailServer.authUser = secrets.gmail_user;
  networking.defaultMailServer.authPass = secrets.gmail_pass;
  #networking.defaultMailServer.fromLineOverride = true;

  i18n.consoleFont = "lat9w-16";
  i18n.consoleKeyMap = "us";
  i18n.defaultLocale = "en_US.UTF-8";

  time.timeZone = "Europe/Berlin";

  environment.etc = if secrets.hydra_id_buildfarm == null then [] else (
    pkgs.lib.singleton {
      target = "nix/id_buildfarm";
      text = builtins.readFile secrets.hydra_id_buildfarm;
      uid = config.ids.uids.hydra;
      gid = config.ids.gids.hydra;
      mode = "0440";
    });

  environment.systemPackages = with pkgs; [
    tmux
    htop
    mosh
    vim
    git
    gnumake
    rxvt_unicode.terminfo
  ];

  users.mutableUsers = false;
  users.users.git = {
    uid = 999;
    home = "/var/git";
    shell = "/run/current-system/sw/bin/bash";
    openssh.authorizedKeys.keys = [
      "ssh-dss AAAAB3NzaC1kc3MAAACBAMSjkowfIlAJn80+5ccsUpG0Dsunbg9nVzGJF4ZU2QlcqC8Hbw7WzhvUgqE5HY4eFxdrbX5nISZTokOT2lyoRH2bIbcCILFwFOoUvdCbbG/M/X+9lOm1cRe9DG20HbhxxquAC9PAKGvUBWRmRhRUv/jyEHITX/0Sq6IyK/VaP/xjAAAAFQD1osCdij1P/Hw8nBBaUYGPDJOeJwAAAIBdKBHJUWBwJyDr1Q/lrRrVjddNP2m9gMt3cJr+7KfpENcjODBsHIpFJNkwIhYfxZSJntij7NxYL2QlI6I9j1dLG4yXH/2kgK+1R4htUTAWDspDGNj7+SruNtVmCvtIDQH3Az+95qCOxYZyOocuWE/6MoqhzRgQQUer44M+KFX6xwAAAIAVwMXUyT0s5tp5wyR+87L6lp9kDR8Fey++K9H91k4p2i/EMI4k4zyvIWHKUqKpDmjvcxQmizpfKeceZv6lPYcXo7CO4dDFoR6U1gIcGYCM1Rgfxacsp10NbwA2DBO1VplNB7ffGx0nGRKRtUP4ZFkbzJiORYxr3RY4Q42HVAV9Eg== rok@oskar"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDVxOBeJUJmWYrniuFyDaJIxjxwwV1ikQUbp7cvOO4F63RQt0AH2Yu9/dxIefuH4yXJb8dh1rqM7MtI5U0s5atfZymqqZJIcTdDs9rc2nOqW+uqsE3ROA9y5moVEdc+jJCjQRr4/wFCQd9xlzH2vwushYnI1w9cn9kWXelI/B8hbRZ22mNiXRIOoG9W+4iX7IFLqmyukxetL/cXV5FPxvfxXxDvGfj7mQ8y3bteotOObNZo5RBSd2EE0BIceC2bMruxZX1oOBdIgiixHfjzgaeEEzlbqnjpAIG2BgCad9WVJaBnGIYJnHtYavIZvHMKTsgExwgjwHbh79YAz735qDbn5CGYj1XZQB5OerRgNsokojan2XQYbo7YP88F4MGrDJEVZrBqHRFMwee0nfIXM9tml28DDAPnntkntNdMUrIiyhkGWOzn4PUCuvLPmWLq7Dba/bpXKcLKy9bXA8QPw6OYeIpOT6a6Ax6eP2aULOYN1Wti1Xa6MX5Eml4Te32UUBviGSf/ugVumcogZulURaxsMUeK7LzXcX1GVFs+1MoOvGAgUbu45qLRJGv7qHU3LbNBDP2eqCfaBLwKiqExwMhSzAuEEH+IzSUgOk88N2RTV/0BXGBqCUc/D2iF24btEL43PqBCoCkiCrIxJg9G/CHFdRau+RUMzvWCk2X9pG9IWQ== rok@nemo"
    ];
  };
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-dss AAAAB3NzaC1kc3MAAACBAMSjkowfIlAJn80+5ccsUpG0Dsunbg9nVzGJF4ZU2QlcqC8Hbw7WzhvUgqE5HY4eFxdrbX5nISZTokOT2lyoRH2bIbcCILFwFOoUvdCbbG/M/X+9lOm1cRe9DG20HbhxxquAC9PAKGvUBWRmRhRUv/jyEHITX/0Sq6IyK/VaP/xjAAAAFQD1osCdij1P/Hw8nBBaUYGPDJOeJwAAAIBdKBHJUWBwJyDr1Q/lrRrVjddNP2m9gMt3cJr+7KfpENcjODBsHIpFJNkwIhYfxZSJntij7NxYL2QlI6I9j1dLG4yXH/2kgK+1R4htUTAWDspDGNj7+SruNtVmCvtIDQH3Az+95qCOxYZyOocuWE/6MoqhzRgQQUer44M+KFX6xwAAAIAVwMXUyT0s5tp5wyR+87L6lp9kDR8Fey++K9H91k4p2i/EMI4k4zyvIWHKUqKpDmjvcxQmizpfKeceZv6lPYcXo7CO4dDFoR6U1gIcGYCM1Rgfxacsp10NbwA2DBO1VplNB7ffGx0nGRKRtUP4ZFkbzJiORYxr3RY4Q42HVAV9Eg== rok@oskar"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDVxOBeJUJmWYrniuFyDaJIxjxwwV1ikQUbp7cvOO4F63RQt0AH2Yu9/dxIefuH4yXJb8dh1rqM7MtI5U0s5atfZymqqZJIcTdDs9rc2nOqW+uqsE3ROA9y5moVEdc+jJCjQRr4/wFCQd9xlzH2vwushYnI1w9cn9kWXelI/B8hbRZ22mNiXRIOoG9W+4iX7IFLqmyukxetL/cXV5FPxvfxXxDvGfj7mQ8y3bteotOObNZo5RBSd2EE0BIceC2bMruxZX1oOBdIgiixHfjzgaeEEzlbqnjpAIG2BgCad9WVJaBnGIYJnHtYavIZvHMKTsgExwgjwHbh79YAz735qDbn5CGYj1XZQB5OerRgNsokojan2XQYbo7YP88F4MGrDJEVZrBqHRFMwee0nfIXM9tml28DDAPnntkntNdMUrIiyhkGWOzn4PUCuvLPmWLq7Dba/bpXKcLKy9bXA8QPw6OYeIpOT6a6Ax6eP2aULOYN1Wti1Xa6MX5Eml4Te32UUBviGSf/ugVumcogZulURaxsMUeK7LzXcX1GVFs+1MoOvGAgUbu45qLRJGv7qHU3LbNBDP2eqCfaBLwKiqExwMhSzAuEEH+IzSUgOk88N2RTV/0BXGBqCUc/D2iF24btEL43PqBCoCkiCrIxJg9G/CHFdRau+RUMzvWCk2X9pG9IWQ== rok@nemo"
  ];
  users.users.hydra.uid = config.ids.uids.hydra;
  users.groups.hydra.gid = config.ids.gids.hydra;

  # From: http://www.mythmon.com/posts/2015-02-15-systemd-weechat.html
  systemd.services."weechat" = with pkgs; {
    enable = true;
    description = "Weechat IRC Client (in tmux)";
    environment = { TERM = "${rxvt_unicode.terminfo}"; };
    path = [ tmux weechat rxvt_unicode.terminfo which ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      ExecStart = "${tmux}/bin/tmux -S /run/tmux-weechat new-session -d -s weechat -n 'weechat' '${weechat}/bin/weechat-curses -d /root/dotfiles/pkgs/weechat'";
      ExecStop = "${tmux}/bin/tmux -S /run/tmux-weechat kill-session -t weechat";
    };
  };

  # https://www.digitalocean.com/community/tutorials/how-to-optimize-nginx-configuration
  services.nginx.enable = true;
  services.nginx.config = ''
    worker_processes 2;
    events {
      worker_connections  2048;
    }
  '';
  services.nginx.httpConfig = ''

    client_body_buffer_size       10K;
    client_header_buffer_size     1k;
    client_max_body_size          8m;
    large_client_header_buffers   2 1k;

    client_body_timeout     12;
    client_header_timeout   12;
    keepalive_timeout       15;
    send_timeout            10;

    gzip                    on;
    gzip_comp_level         2;
    gzip_min_length         1000;
    gzip_proxied            expired no-cache no-store private auth;
    gzip_types              text/plain application/x-javascript text/xml text/css application/xml;
    gzip_disable            "msie6";

    access_log              syslog:server=unix:/dev/log;
    error_log               syslog:server=unix:/dev/log;

    ${createStaticSite "garbas.si"}

    server {
      listen                  80;
      server_name             hydra.garbas.si;
      location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Forwarded-Host $http_host;
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header X-Forwarded-Port 443;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Request-Base "http://hydra.garbas.si";
        proxy_pass http://${config.services.hydra.listenHost}:${builtins.toString config.services.hydra.port}/;
      }
    }
  '';

  services.dd-agent.enable = isDD;
  services.dd-agent.api_key = lib.optionalString isDD secrets.datadog_api_key;
  services.dd-agent.hostname = "floki.garbas.si";
  services.dd-agent.postgresqlConfig = lib.optionalString isDD ''
    init_config:

    instances:
      - host: localhost
        port: 5432
        username: datadog
        password: ${secrets.datadog_postgresql_password}
  '';
  services.dd-agent.nginxConfig = ''
    init_config:

    instances:
      - nginx_status_url: https://garbas.si/__status__/
        tags:
          - instance:www
  '';

  services.rsyslogd.enable = isLogentries;
  services.rsyslogd.extraConfig = lib.optionalString isLogentries ''
    $ModLoad imjournal

    $DefaultNetstreamDriverCAFile ${logentries-crt}

    $ActionSendStreamDriver gtls
    $ActionSendStreamDriverMode 1
    $ActionSendStreamDriverAuthMode x509/name
    $ActionSendStreamDriverPermittedPeer *.logentries.com

    $template LogentriesFormat,"${secrets.logentries_token} %HOSTNAME% %syslogtag%%msg%\n"
    *.* @@data.logentries.com:443;LogentriesFormat
  '';

   services.postgresql.package = pkgs.postgresql94;

}
