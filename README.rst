All the Nix I have
==================

Purpose of this repository is to collect all of my Nix/NixOS configuration in
one place. This repository is not ment for you to depend on it, but it is
a showcase how

Take good things from it. Complain about the weird things. Or just stop and say
hi: `@garbas`_


Structure
---------

- ``nixos/`` (configuration for specific machine)
   - ``biedronka.nix`` (my gf's mom laptop)
   - ``zabka.nix`` (my gf's laptop)
   - ``nemo.nix`` (my work laptop)
   - ``oskar.nix`` (my personal laptop)
   - ``floki.nix`` (my server)
   - ``profiles/`` (profile is a collection of nixos services)
       - ``base.nix`` (setup which only configures self updating)
       - ``rok.nix`` (my own setup, shared between my laptops)
       - ``gnome3.nix`` (setup I maintain for my famility)
- ``pkgs/`` (my custom packages which extend nixpkgs_)
   - ``default.nix`` (list of all overrides)
   - ``config/`` (confiurations for programs)
- ``default.nix`` (imports ``pkgs/``)
- ``release.nix`` (hydra script)


Deploying a machine
-------------------

Login as root on the existing NixOS installation and then:::

    % cd /etc/nixos
    /etc/nixos % mv configuration.nix backup.nix
    /etc/nixos % git clone https://github.com/garbas/dotfiles
    /etc/nixos % nixos-rebuild switch


Using packages without NixOS
----------------------------

Make sure you have nix installed on your system and then:::

    % mkdir -p ~/.nixpkgs/
    % cd ~/.nixpkgs
    ~/.nixpkgs % git clone https://github.com/garbas/dotfiles
    ~/.nixpkgs % echo "{ packageOverrides = pkgs: import ./dotfiles { inherit pkgs; }; }"

Read more about `~/.nixpkgs/config.nix`_.


.. _`@garbas`: https://twitter.com/garbas
.. _`~/.nixpkgs/config.nix`: http://nixos.org/nixpkgs/manual/#chap-packageconfig
.. _`nixpkgs`: https://github.com/NixOS/nixpkgs

==================

Purpose of this repository is to collect all of my Nix/NixOS configuration in
one place. This repository is not ment for you to depend on it, but it is
a showcase how

Take good things from it. Complain about the weird things. Or just stop and say
hi: `@garbas`_


Structure
---------

- ``nixos/`` (configuration for specific machine)
   - ``biedronka.nix`` (my gf's mom laptop)
   - ``zabka.nix`` (my gf's laptop)
   - ``nemo.nix`` (my work laptop)
   - ``oskar.nix`` (my personal laptop)
   - ``floki.nix`` (my server)
   - ``profiles/`` (profile is a collection of nixos services)
       - ``base.nix`` (setup which only configures self updating)
       - ``rok.nix`` (my own setup, shared between my laptops)
       - ``gnome3.nix`` (setup I maintain for my famility)
- ``pkgs/`` (my custom packages which extend nixpkgs_)
   - ``default.nix`` (list of all overrides)
   - ``config/`` (confiurations for programs)
- ``default.nix`` (imports ``pkgs/``)
- ``release.nix`` (hydra script)


Deploying a machine
-------------------

Login as root on the existing NixOS installation and then:::

    % cd /etc/nixos
    /etc/nixos % mv configuration.nix backup.nix
    /etc/nixos % git clone https://github.com/garbas/dotfiles
    /etc/nixos % nixos-rebuild switch


Using packages without NixOS
----------------------------

Make sure you have nix installed on your system and then:::

    % mkdir -p ~/.nixpkgs/
    % cd ~/.nixpkgs
    ~/.nixpkgs % git clone https://github.com/garbas/dotfiles
    ~/.nixpkgs % echo "{ packageOverrides = pkgs: import ./dotfiles { inherit pkgs; }; }"

Read more about `~/.nixpkgs/config.nix`_.


.. _`@garbas`: https://twitter.com/garbas
.. _`~/.nixpkgs/config.nix`: http://nixos.org/nixpkgs/manual/#chap-packageconfig
.. _`nixpkgs`: https://github.com/NixOS/nixpkgs

