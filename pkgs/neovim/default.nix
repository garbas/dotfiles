{ myConfig
, nightfox-src
, lib
, wrapNeovim
, neovim-unwrapped
, tree-sitter
, recurseIntoAttrs
, callPackage
, llvmPackages_6
, lua51Packages
}:

#
# https://github.com/hrsh7th/nvim-cmp
# lsp-config
# https://github.com/L3MON4D3/LuaSnip
# searchbox-nvim

let
  vimPlugins = recurseIntoAttrs (callPackage ./plugins {
    inherit nightfox-src;
    llvmPackages = llvmPackages_6;
    luaPackages = lua51Packages;
  });

  pluginsWithConfig = [

    # SENSIBLE DEFAULTS
    { plugins = with vimPlugins; [
        # One step above 'nocompatible' mode
        # https://github.com/tpope/vim-sensible
        vim-sensible

        # One step above sensible.vim more defaults to agree on
        # https://github.com/jeffkreeftmeijer/neovim-sensible
        neovim-sensible
      ];
      config = ''
        autocmd VimEnter * set number norelativenumber
      '';
    }

    # THEME / COLORS / ICONS
    { plugins = with vimPlugins; [
        nightfox-nvim
        nvim-web-devicons
      ];
      config = ''
        colorscheme ${myConfig.theme}
      '';
    }

    # CORE
    { plugins = with vimPlugins; [
        # A lua powered greeter like vim-startify / dashboard-nvim
        # https://github.com/goolord/alpha-nvim
        alpha-nvim

        # Displays a popup with possible keybindings of the command you
        # started typing.
        # https://github.com/folke/which-key.nvim
        which-key-nvim


        (nvim-treesitter.withPlugins (_: tree-sitter.allGrammars))
      ];
      config = ''
        lua << EOF
        vim.g.mapleader = ' '
        vim.g.maplocalleader = ','


        local opts = require("alpha.themes.startify").opts
        require("alpha").setup(opts)


        require("which-key").setup{
          triggers = {"<leader>"}
        }
        local wk = require("which-key")
        local mappings = {
          q = ":q"
        }
        local opts = {
          prefix = '<leader>'
        }
        wk.register(mappings, opts)


        require'nvim-treesitter.configs'.setup {
          -- Install languages synchronously (only applied to `ensure_installed`)
          sync_install = false,
          highlight = {
            -- `false` will disable the whole extension
            enable = true,

            -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
            -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
            -- Using this option may slow down your editor, and you may see some duplicate highlights.
            -- Instead of true it can also be a list of languages
            additional_vim_regex_highlighting = false,
          },
          indent = {
            enable = true
          },
        }
        EOF
      '';
    }

    # NAVIGATION
    { plugins = with vimPlugins; [
        telescope-nvim
        telescope-fzf-native-nvim
        telescope-file-browser-nvim
        telescope-github-nvim

      ];
      config = ''
        lua << EOF
        require('telescope').setup{
        }
        EOF
      '';
    }

    # EDITING
    { plugins = with vimPlugins; [
        nvim-lspconfig

        cmp-buffer
        cmp-calc
        cmp-cmdline
        cmp-emoji
        cmp-nvim-lsp
        cmp-nvim-lsp-document-symbol
        cmp-nvim-lua
        cmp-omni
        cmp-path
        nvim-cmp

        luasnip
        cmp_luasnip

        neorg
      ];
      config = ''
        lua << EOF
        local cmp = require('cmp')
        cmp.setup({
          snippet = {
            expand = function(args)
              require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
            end,
          },
          mapping = {
            ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
            ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
            ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
            ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
            ['<C-e>'] = cmp.mapping({
              i = cmp.mapping.abort(),
              c = cmp.mapping.close(),
            }),
            ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          },
          sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'nvim_lsp_document_symbol' },
            { name = 'luasnip' },
            { name = 'buffer' },
            { name = 'path' },
            { name = 'omni' },
            { name = 'emoji' },
            { name = 'cmdline' },
            { name = 'calc' },
            { name = "neorg" } 
          }, {
            { name = 'buffer' },
          })
        })


        require('neorg').setup({
          load = {
            ["core.defaults"] = {}, -- Load all the default modules
            ["core.norg.concealer"] = {}, -- Allows for use of icons
            ["core.norg.dirman"] = { -- Manage your directories with Neorg
              config = {
                workspaces = {
                  my_workspace = "~/dev/neorg"
                }
              }
            },
            ["core.norg.completion"] = {
              config = {
                engine = "nvim-cmp"
              }
            }
          },
        })
        EOF
      '';
    }

    # FIRENVIM
    { plugins = with vimPlugins; [
        firenvim
      ];
      config = ''
        lua << EOF
        EOF
      '';
    }

  ];
in (wrapNeovim neovim-unwrapped {}).override {
  viAlias = true;
  vimAlias = true;
  configure = {
    packages.myVimPackages.start = lib.flatten (builtins.map (x: x.plugins) pluginsWithConfig);
    customRC = (builtins.concatStringsSep "\n\n" (builtins.map (x: x.config) pluginsWithConfig));
  };
}
        #let g:which_key_map =  {}
        #let g:which_key_map.w = {
        #  \ 'name' : '+windows' ,
        #  \ 'w' : ['<C-W>w'     , 'other-window']          ,
        #  \ 'd' : ['<C-W>c'     , 'delete-window']         ,
        #  \ '-' : ['<C-W>s'     , 'split-window-below']    ,
        #  \ '|' : ['<C-W>v'     , 'split-window-right']    ,
        #  \ '2' : ['<C-W>v'     , 'layout-double-columns'] ,
        #  \ 'h' : ['<C-W>h'     , 'window-left']           ,
        #  \ 'j' : ['<C-W>j'     , 'window-below']          ,
        #  \ 'l' : ['<C-W>l'     , 'window-right']          ,
        #  \ 'k' : ['<C-W>k'     , 'window-up']             ,
        #  \ 'H' : ['<C-W>5<'    , 'expand-window-left']    ,
        #  \ 'J' : [':resize +5' , 'expand-window-below']   ,
        #  \ 'L' : ['<C-W>5>'    , 'expand-window-right']   ,
        #  \ 'K' : [':resize -5' , 'expand-window-up']      ,
        #  \ '=' : ['<C-W>='     , 'balance-window']        ,
        #  \ 's' : ['<C-W>s'     , 'split-window-below']    ,
        #  \ 'v' : ['<C-W>v'     , 'split-window-below']    ,
        #  \ '?' : ['Windows'    , 'fzf-window']            ,
        #  \ }
        #let g:which_key_map.b = {
        #  \ 'name' : '+buffer'  ,
        #  \ '1' : ['b1'         , 'buffer 1']              ,
        #  \ '2' : ['b2'         , 'buffer 2']              ,
        #  \ 'd' : ['bd'         , 'delete-buffer']         ,
        #  \ 'f' : ['bfirst'     , 'first-buffer']          ,
        #  \ 'h' : ['Startify'   , 'home-buffer']           ,
        #  \ 'l' : ['blast'      , 'last-buffer']           ,
        #  \ 'n' : ['bnext'      , 'next-buffer']           ,
        #  \ 'p' : ['bprevious'  , 'previous-buffer']       ,
        #  \ '?' : ['Buffers'    , 'fzf-buffer']            ,
        #  \ }

      # https://github.com/nvim-telescope/telescope.nvim#neovim-lsp-pickers
      #let g:which_key_map.l = {
      #\ 'name' : '+lsp',
      #\ 'f' : ['spacevim#lang#util#Format()'          , 'formatting']       ,
      #\ 'r' : ['spacevim#lang#util#FindReferences()'  , 'references']       ,
      #\ 'R' : ['spacevim#lang#util#Rename()'          , 'rename']           ,
      #\ 's' : ['spacevim#lang#util#DocumentSymbol()'  , 'document-symbol']  ,
      #\ 'S' : ['spacevim#lang#util#WorkspaceSymbol()' , 'workspace-symbol'] ,
      #\ 'g' : {
      #  \ 'name': '+goto',
      #  \ 'd' : ['spacevim#lang#util#Definition()'     , 'definition']      ,
      #  \ 't' : ['spacevim#lang#util#TypeDefinition()' , 'type-definition'] ,
      #  \ 'i' : ['spacevim#lang#util#Implementation()' , 'implementation']  ,
      #  \ },
      #\ }

      # https://github.com/nvim-telescope/telescope.nvim#git-pickers
      #let g:which_key_map.l = {
      #\ 'name' : '+git',
      #\ 'c' : ['Telescope git_commits'  , 'Commits diff']          ,
      #\ 'C' : ['Telescope git_bcommits' , 'Buffer's commits diff'] ,
      #\ 'b' : ['Telescope git_branches' , 'Branches']              ,
      #\ 's' : ['Telescope git_status'   , 'Status']                ,
      #\ 'S' : ['Telescope git_stash'    , 'Stash']                 ,
      #\ }
        #let g:which_key_map.s = ['Telescope spell_suggest', 'Spell suggest']
        #let g:which_key_map.f = {
        #  \ 'name' : '+files',
        #  \ 'f' : ['<cmd>Telescope find_files<cr>'   , 'Find files']   ,
        #  \ 'F' : ['<cmd>Telescope file_browser<cr>' , 'File browser'] ,
        #  \ 'g' : ['<cmd>Telescope live_grep<cr>'    , 'Live grep']    ,
        #  \ 'b' : ['<cmd>Telescope buffers<cr>'      , 'Buffers']      ,
        #  \ 'h' : ['<cmd>Telescope help_tags<cr>'    , 'Help tags']    ,
        #  \ 'H' : ['<cmd>Telescope man_pages<cr>'    , 'Man pages']    ,
        #  \ 'm' : ['<cmd>Telescope marks<cr>'        , 'Marks']        ,
        #  \ }
