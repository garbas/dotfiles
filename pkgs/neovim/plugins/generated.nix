# This file has been generated by ./pkgs/applications/editors/vim/plugins/update.py. Do not edit!
{ lib, buildVimPluginFrom2Nix, buildNeovimPluginFrom2Nix, fetchFromGitHub, fetchgit }:

final: prev:
{
  alpha-nvim = buildVimPluginFrom2Nix {
    pname = "alpha-nvim";
    version = "2022-09-09";
    src = fetchFromGitHub {
      owner = "goolord";
      repo = "alpha-nvim";
      rev = "0bb6fc0646bcd1cdb4639737a1cee8d6e08bcc31";
      sha256 = "0cx2psvvafclggwm32xrx03wjm0vk59fj8xln75k4smckcax59dl";
    };
    meta.homepage = "https://github.com/goolord/alpha-nvim/";
  };

  cmp-buffer = buildVimPluginFrom2Nix {
    pname = "cmp-buffer";
    version = "2022-08-10";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-buffer";
      rev = "3022dbc9166796b644a841a02de8dd1cc1d311fa";
      sha256 = "1cwx8ky74633y0bmqmvq1lqzmphadnhzmhzkddl3hpb7rgn18vkl";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-buffer/";
  };

  cmp-calc = buildVimPluginFrom2Nix {
    pname = "cmp-calc";
    version = "2022-04-25";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-calc";
      rev = "f7efc20768603bd9f9ae0ed073b1c129f63eb312";
      sha256 = "0q5p5s46bh0h1w9p3yzwxd04hlbxg3s4liq42r697gqvna6sq0yg";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-calc/";
  };

  cmp-cmdline = buildVimPluginFrom2Nix {
    pname = "cmp-cmdline";
    version = "2022-09-16";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-cmdline";
      rev = "c66c379915d68fb52ad5ad1195cdd4265a95ef1e";
      sha256 = "00ivhdq1skdccmkn0sd0kr8b9gnap84in34q5r2mkmnd07vhiwr2";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-cmdline/";
  };

  cmp-emoji = buildVimPluginFrom2Nix {
    pname = "cmp-emoji";
    version = "2021-09-28";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-emoji";
      rev = "19075c36d5820253d32e2478b6aaf3734aeaafa0";
      sha256 = "00jrwg491q6nx3q36krarxfpchg3fgdsz7l02ag7cm0x9hv4dknd";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-emoji/";
  };

  cmp-nvim-lsp = buildVimPluginFrom2Nix {
    pname = "cmp-nvim-lsp";
    version = "2022-05-16";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-nvim-lsp";
      rev = "affe808a5c56b71630f17aa7c38e15c59fd648a8";
      sha256 = "1v88bw8ri8w4s8yn7jw5anyiwyw8swwzrjf843zqzai18kh9mlnp";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-nvim-lsp/";
  };

  cmp-nvim-lsp-document-symbol = buildVimPluginFrom2Nix {
    pname = "cmp-nvim-lsp-document-symbol";
    version = "2022-03-22";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-nvim-lsp-document-symbol";
      rev = "c3f0086ed9882e52e0ae38dd5afa915f69054941";
      sha256 = "1jprb86z081kpxyb2dhw3n1pq15dzcc9wlwmpb6k43mqd7k8q11l";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-nvim-lsp-document-symbol/";
  };

  cmp-nvim-lua = buildVimPluginFrom2Nix {
    pname = "cmp-nvim-lua";
    version = "2021-10-11";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-nvim-lua";
      rev = "d276254e7198ab7d00f117e88e223b4bd8c02d21";
      sha256 = "11mhpb2jdc7zq7yiwzkks844b7alrdd08h96r6y7p3cxjv1iy5gz";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-nvim-lua/";
  };

  cmp-omni = buildVimPluginFrom2Nix {
    pname = "cmp-omni";
    version = "2022-01-08";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-omni";
      rev = "7a457f0c4f9e0801fee777d955eb841659aa3b84";
      sha256 = "0f9mk0h3g1gg6lq9qnasi0liv8kvgc6rzfvgc9cflq5kkw97gjpw";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-omni/";
  };

  cmp-path = buildVimPluginFrom2Nix {
    pname = "cmp-path";
    version = "2022-10-03";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-path";
      rev = "91ff86cd9c29299a64f968ebb45846c485725f23";
      sha256 = "18ixx14ibc7qrv32nj0ylxrx8w4ggg49l5vhcqd35hkp4n56j6mn";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-path/";
  };

  cmp-vsnip = buildVimPluginFrom2Nix {
    pname = "cmp-vsnip";
    version = "2021-11-10";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-vsnip";
      rev = "0abfa1860f5e095a07c477da940cfcb0d273b700";
      sha256 = "1vhw2qx8284bskivc2jyijl93g1b1z9hzzbq2l9b4aw6r23frbgc";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-vsnip/";
  };

  cmp_luasnip = buildVimPluginFrom2Nix {
    pname = "cmp_luasnip";
    version = "2022-05-01";
    src = fetchFromGitHub {
      owner = "saadparwaiz1";
      repo = "cmp_luasnip";
      rev = "a9de941bcbda508d0a45d28ae366bb3f08db2e36";
      sha256 = "0mh7gimav9p6cgv4j43l034dknz8szsnmrz49b2ra04yk9ihk1zj";
    };
    meta.homepage = "https://github.com/saadparwaiz1/cmp_luasnip/";
  };

  completion-treesitter = buildVimPluginFrom2Nix {
    pname = "completion-treesitter";
    version = "2020-06-26";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "completion-treesitter";
      rev = "45c9b2faff4785539a0d0c655440c2465fed985a";
      sha256 = "19pgdzzk7zq85b1grfjf0nncvs5vxrd4rj1p90iw2amq4mvqrx3l";
    };
    meta.homepage = "https://github.com/nvim-treesitter/completion-treesitter/";
  };

  friendly-snippets = buildVimPluginFrom2Nix {
    pname = "friendly-snippets";
    version = "2022-10-12";
    src = fetchFromGitHub {
      owner = "rafamadriz";
      repo = "friendly-snippets";
      rev = "fd16b4d9dc58119eeee57e9915864c4480d591fd";
      sha256 = "18fzpij4c11jvxhsjp65cmmc7nna4p3whjsx8a0a263kahh8npfp";
    };
    meta.homepage = "https://github.com/rafamadriz/friendly-snippets/";
  };

  lualine-nvim = buildVimPluginFrom2Nix {
    pname = "lualine.nvim";
    version = "2022-10-06";
    src = fetchFromGitHub {
      owner = "nvim-lualine";
      repo = "lualine.nvim";
      rev = "edca2b03c724f22bdc310eee1587b1523f31ec7c";
      sha256 = "06gy6jy3gfhhjcy61fx9myhs4bmknhlfsmnsi1mmcydhm4gcbm2b";
    };
    meta.homepage = "https://github.com/nvim-lualine/lualine.nvim/";
  };

  luasnip = buildVimPluginFrom2Nix {
    pname = "luasnip";
    version = "2022-10-11";
    src = fetchFromGitHub {
      owner = "l3mon4d3";
      repo = "luasnip";
      rev = "80df2824d89f3c9c45d3b06494c7e89ca4e0c70e";
      sha256 = "1vfqzylwfykh8h02bdp8d5avyqyy9pqlhg01ry781r47dcryhh6s";
      fetchSubmodules = true;
    };
    meta.homepage = "https://github.com/l3mon4d3/luasnip/";
  };

  nightfox-nvim = buildVimPluginFrom2Nix {
    pname = "nightfox.nvim";
    version = "2022-09-27";
    src = fetchFromGitHub {
      owner = "edeneast";
      repo = "nightfox.nvim";
      rev = "59c3dbcec362eff7794f1cb576d56fd8a3f2c8bb";
      sha256 = "1dkwgqx576xc8fryhi61q7mka93vv28hfsw340k594jkqc3da9i2";
    };
    meta.homepage = "https://github.com/edeneast/nightfox.nvim/";
  };

  nvim-cmp = buildNeovimPluginFrom2Nix {
    pname = "nvim-cmp";
    version = "2022-10-11";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "nvim-cmp";
      rev = "714ccb7483d0ab90de1b93914f3afad1de8da24a";
      sha256 = "17x8fkg0299ikr3xlvgaaii1s316j4q34kdj5f9kwrfr26817d0n";
    };
    meta.homepage = "https://github.com/hrsh7th/nvim-cmp/";
  };

  nvim-lspconfig = buildVimPluginFrom2Nix {
    pname = "nvim-lspconfig";
    version = "2022-10-12";
    src = fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lspconfig";
      rev = "28ec7c4f4ad4701a88024fb8105ac7baff7d4f2a";
      sha256 = "0qnqpr9fz3dc15i4v7dqf9h31n8jhc41sgfgp1fvkwnvkr5rgh74";
    };
    meta.homepage = "https://github.com/neovim/nvim-lspconfig/";
  };

  nvim-treesitter = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter";
    version = "2022-10-12";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter";
      rev = "82767f3f33c903e92f059dc9a2b27ec38dcc28d7";
      sha256 = "0y2fhafp2r7bflc4q9i0v2ssix6c0yjc9rimbb6n51z9n83xqlgg";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter/";
  };

  nvim-web-devicons = buildVimPluginFrom2Nix {
    pname = "nvim-web-devicons";
    version = "2022-10-03";
    src = fetchFromGitHub {
      owner = "nvim-tree";
      repo = "nvim-web-devicons";
      rev = "a8cf88cbdb5c58e2b658e179c4b2aa997479b3da";
      sha256 = "1946azhr3rq702mvidzby9jvq7h2zs45d6k9j7clxw2g9xbx0k6a";
    };
    meta.homepage = "https://github.com/nvim-tree/nvim-web-devicons/";
  };

  plenary-nvim = buildNeovimPluginFrom2Nix {
    pname = "plenary.nvim";
    version = "2022-10-01";
    src = fetchFromGitHub {
      owner = "nvim-lua";
      repo = "plenary.nvim";
      rev = "4b7e52044bbb84242158d977a50c4cbcd85070c7";
      sha256 = "11815h0h2mf5ym282ghk7xav90635r88qbgaflpgbyk2banl31wl";
    };
    meta.homepage = "https://github.com/nvim-lua/plenary.nvim/";
  };

  popup-nvim = buildVimPluginFrom2Nix {
    pname = "popup.nvim";
    version = "2021-11-18";
    src = fetchFromGitHub {
      owner = "nvim-lua";
      repo = "popup.nvim";
      rev = "b7404d35d5d3548a82149238289fa71f7f6de4ac";
      sha256 = "093r3cy02gfp7sphrag59n3fjhns7xdsam1ngiwhwlig3bzv7mbl";
    };
    meta.homepage = "https://github.com/nvim-lua/popup.nvim/";
  };

  telescope-file-browser-nvim = buildVimPluginFrom2Nix {
    pname = "telescope-file-browser.nvim";
    version = "2022-10-11";
    src = fetchFromGitHub {
      owner = "nvim-telescope";
      repo = "telescope-file-browser.nvim";
      rev = "6b4e22777bfa6a31787a4ac8e086b062ef241ede";
      sha256 = "04mrq2dzvksryhfh93xzafcq5ipmywirynczblki91420m2128wn";
    };
    meta.homepage = "https://github.com/nvim-telescope/telescope-file-browser.nvim/";
  };

  telescope-fzf-native-nvim = buildVimPluginFrom2Nix {
    pname = "telescope-fzf-native.nvim";
    version = "2022-09-06";
    src = fetchFromGitHub {
      owner = "nvim-telescope";
      repo = "telescope-fzf-native.nvim";
      rev = "65c0ee3d4bb9cb696e262bca1ea5e9af3938fc90";
      sha256 = "0nyvhlalrgg6n793lp3yrxgszv5j0ln9sjbh45pxxg0wn15jxm45";
    };
    meta.homepage = "https://github.com/nvim-telescope/telescope-fzf-native.nvim/";
  };

  telescope-github-nvim = buildVimPluginFrom2Nix {
    pname = "telescope-github.nvim";
    version = "2022-04-22";
    src = fetchFromGitHub {
      owner = "nvim-telescope";
      repo = "telescope-github.nvim";
      rev = "ee95c509901c3357679e9f2f9eaac3561c811736";
      sha256 = "1943bhi2y3kyxhdrbqysxpwmd9f2rj9pbl4r449kyj1rbh6mzqk2";
    };
    meta.homepage = "https://github.com/nvim-telescope/telescope-github.nvim/";
  };

  telescope-project-nvim = buildVimPluginFrom2Nix {
    pname = "telescope-project.nvim";
    version = "2022-10-10";
    src = fetchFromGitHub {
      owner = "nvim-telescope";
      repo = "telescope-project.nvim";
      rev = "ff4d3cea905383a67d1a47b9dd210c4907d858c2";
      sha256 = "16byj7gcyxpn837x096a074vpj67drbd5ndcfpkvp1xyam9604b4";
    };
    meta.homepage = "https://github.com/nvim-telescope/telescope-project.nvim/";
  };

  telescope-nvim = buildVimPluginFrom2Nix {
    pname = "telescope.nvim";
    version = "2022-10-09";
    src = fetchFromGitHub {
      owner = "nvim-telescope";
      repo = "telescope.nvim";
      rev = "f174a0367b4fc7cb17710d867e25ea792311c418";
      sha256 = "1hra6vrr25xan0xwjc76m14ml6hwrm7nx2wapl44zx3m29hwfasx";
    };
    meta.homepage = "https://github.com/nvim-telescope/telescope.nvim/";
  };

  trouble-nvim = buildVimPluginFrom2Nix {
    pname = "trouble.nvim";
    version = "2022-09-05";
    src = fetchFromGitHub {
      owner = "folke";
      repo = "trouble.nvim";
      rev = "929315ea5f146f1ce0e784c76c943ece6f36d786";
      sha256 = "07nyhg5mmy1fhf6v4480wb8gq3dh7g9fz9l5ksv4v94sdp5pgzvz";
    };
    meta.homepage = "https://github.com/folke/trouble.nvim/";
  };

  vim-lastplace = buildVimPluginFrom2Nix {
    pname = "vim-lastplace";
    version = "2022-02-22";
    src = fetchFromGitHub {
      owner = "farmergreg";
      repo = "vim-lastplace";
      rev = "cef9d62165cd26c3c2b881528a5290a84347059e";
      sha256 = "0wkjyqx427vvjhj0v3vfrg4hfb5ax5qq5ilfqas9h94w1cngiz5c";
    };
    meta.homepage = "https://github.com/farmergreg/vim-lastplace/";
  };

  vim-nickel = buildVimPluginFrom2Nix {
    pname = "vim-nickel";
    version = "2022-03-16";
    src = fetchFromGitHub {
      owner = "nickel-lang";
      repo = "vim-nickel";
      rev = "2f0f5f8ce2a8e719a5e39d7210ca914ae403374c";
      sha256 = "1li3wc5164mcqrvj42dc8zh3j8wml10gpgffapnjilwa5c85kv3q";
    };
    meta.homepage = "https://github.com/nickel-lang/vim-nickel/";
  };

  vim-snippets = buildVimPluginFrom2Nix {
    pname = "vim-snippets";
    version = "2022-10-10";
    src = fetchFromGitHub {
      owner = "honza";
      repo = "vim-snippets";
      rev = "9a7f3968c92c6589d3a12aa5448e8374c8d68a42";
      sha256 = "15bqw0l78s8v2l44j4h64lvs7456h5l0dy46kxas095jrjg9aqnw";
    };
    meta.homepage = "https://github.com/honza/vim-snippets/";
  };

  which-key-nvim = buildVimPluginFrom2Nix {
    pname = "which-key.nvim";
    version = "2022-09-18";
    src = fetchFromGitHub {
      owner = "folke";
      repo = "which-key.nvim";
      rev = "6885b669523ff4238de99a7c653d47b081b5506d";
      sha256 = "1fwb3mmc190xam96jm743ml56idx3zvqmxf8j61yhb8879879rj6";
    };
    meta.homepage = "https://github.com/folke/which-key.nvim/";
  };


}
