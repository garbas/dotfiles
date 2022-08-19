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

# TODO:
# https://github.com/jose-elias-alvarez/null-ls.nvim
# https://github.com/kabinspace/AstroVim/wiki/Default-Plugins
# https://github.com/kabinspace/AstroVim
# https://github.com/LunarVim
# https://github.com/CosmicNvim/CosmicNvim
# https://github.com/NvChad/NvChad
# https://github.com/hrsh7th/nvim-cmp
# lsp-config
# https://github.com/L3MON4D3/LuaSnip
# searchbox-nvim
# https://github.com/TimUntersberger/neogit
# https://github.com/sindrets/diffview.nvim
# https://github.com/justinmk/vim-sneak
# https://github.com/moll/vim-bbye
# https://github.com/akinsho/bufferline.nvim
# https://github.com/nvim-lualine/lualine.nvim
# https://github.com/lukas-reineke/indent-blankline.nvim
# https://github.com/folke/trouble.nvim
# https://github.com/folke/tokyonight.nvim
# https://github.com/folke/zen-mode.nvim
# https://github.com/folke/twilight.nvim
# https://github.com/folke/todo-comments.nvim
# https://github.com/folke/lsp-colors.nvim

let
  vimPlugins = recurseIntoAttrs (callPackage ./plugins {
    inherit nightfox-src;
    llvmPackages = llvmPackages_6;
    luaPackages = lua51Packages;
  });

  asLua = t: ''
    lua << EOF
    ${t}
    EOF
  '';

  pluginsWithConfig = [

    # SENSIBLE DEFAULTS
    { plugins = with vimPlugins; [
        # Intelligently reopen files at your last edit position.
        # https://github.com/farmergreg/vim-lastplace
        "vim-lastplace"
      ];
      config = ''
        " Use <Space> as the leader key
        let mapleader=" "

        " Allows you to change buffers even if the current on has unsaved changes
        set hidden

        " Intuit the indentation of new lines when creating them
        set smartindent

        " Return to last edit position when opening files
        " maybe replace with https://github.com/farmergreg/vim-lastplace
        au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

        " Who wants .swap files??
        set noswapfile

        " Turn persistent undo on
        " means that you can undo even when you close a buffer/VIM
        set undodir=~/.vim_runtime/temp_dirs/undodir
        set undofile

        " TODO: add text
        set completeopt=menu,menuone,noselect

        " Use absolute line numbers
        set number norelativenumber

        " Use the system clipboard
        set clipboard=unnamed

        " Use a color column on the 80-character mark
        set colorcolumn=80

        " Press <tab>, get two spaces
        set expandtab shiftwidth=2

        " Show `▸▸` for tabs: 	, `·` for tailing whitespace: 
        set list listchars=tab:▸▸,trail:·

        " Enable mouse support
        set mouse=a

        " Time in milliseconds to wait for a key code sequence to complete.
        set timeoutlen=300

        " vim-lastplace config
        let g:lastplace_ignore = "gitcommit,gitrebase,svn,hgcommit"
        let g:lastplace_ignore_buftype = "quickfix,nofile,help"
      '';
    }

    # THEME / COLORS / ICONS
    { plugins = with vimPlugins; [
        nightfox-nvim
        nvim-web-devicons
      ];
      config = ''
        colorscheme "nordfox"
        "colorscheme "dayfox"
      '';
    }

    # STARTUP SCREEN
    { plugins = with vimPlugins; [
        # A lua powered greeter like vim-startify / dashboard-nvim
        # https://github.com/goolord/alpha-nvim
        alpha-nvim
      ];
      config = asLua ''
        # TODO: reorder 
        require("alpha").setup(require"alpha.themes.startify".config)
      '';
    }

    # MAPPINGS / KEYBINDINGS
    { plugins = with vimPlugins; [
        # Displays a popup with possible keybindings of the command you
        # started typing.
        # https://github.com/folke/which-key.nvim
        which-key-nvim
      ];
      config = asLua ''
        require("which-key").setup({
          plugins = {
            marks = true, -- shows a list of your marks on ' and `
            registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
            spelling = {
              enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
              suggestions = 20, -- how many suggestions should be shown in the list?
            },
            -- the presets plugin, adds help for a bunch of default keybindings in Neovim
            -- No actual key bindings are created
            presets = {
              operators = true, -- adds help for operators like d, y, ... and registers them for motion / text object completion
              motions = true, -- adds help for motions
              text_objects = true, -- help for text objects triggered after entering an operator
              windows = true, -- default bindings on <c-w>
              nav = true, -- misc bindings to work with windows
              z = true, -- bindings for folds, spelling and others prefixed with z
              g = true, -- bindings for prefixed with g
            },
          },
          -- add operators that will trigger motion and text object completion
          -- to enable all native operators, set the preset / operators plugin above
          operators = { gc = "Comments" },
          key_labels = {
            -- override the label used to display some keys. It doesn't effect WK in any other way.
            -- For example:
            -- ["<space>"] = "SPC",
            -- ["<cr>"] = "RET",
            -- ["<tab>"] = "TAB",
          },
          icons = {
            breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
            separator = "➜", -- symbol used between a key and it's label
            group = "+", -- symbol prepended to a group
          },
          popup_mappings = {
            scroll_down = '<c-d>', -- binding to scroll down inside the popup
            scroll_up = '<c-u>', -- binding to scroll up inside the popup
          },
          window = {
            border = "none", -- none, single, double, shadow
            position = "bottom", -- bottom, top
            margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
            padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
            winblend = 0
          },
          layout = {
            height = { min = 4, max = 25 }, -- min and max height of the columns
            width = { min = 20, max = 50 }, -- min and max width of the columns
            spacing = 3, -- spacing between columns
            align = "left", -- align columns left, center or right
          },
          ignore_missing = false, -- enable this to hide mappings for which you didn't specify a label
          hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ "}, -- hide mapping boilerplate
          show_help = true, -- show help message on the command line when the popup is visible
          triggers = "auto", -- automatically setup triggers
          -- triggers = {"<leader>"} -- or specify a list manually
          triggers_blacklist = {
            -- list of mode / prefixes that should never be hooked by WhichKey
            -- this is mostly relevant for key maps that start with a native binding
            -- most people should not need to change this
            i = { "j", "k" },
            v = { "j", "k" },
          },
        })
        local wk = require("which-key")
        wk.register({
          q = { ":wqa<cr>", "Save and exit" },
          w = { ":bd<cr>", "Close buffer" },
        } , { prefix = '<leader>' })
      '';
    }

    # SYNTAX (TREESITTER)
    { plugins = with vimPlugins; [
        vim-nickel
        (nvim-treesitter.withPlugins (p: [
          #p."tree-sitter-javascript"
          #p."tree-sitter-c"
          #p."tree-sitter-json"
          #p."tree-sitter-cpp"
          #p."tree-sitter-go"
          #p."tree-sitter-python"
          #p."tree-sitter-typescript"
          p."tree-sitter-rust"
          #p."tree-sitter-bash"
          #p."tree-sitter-scala"
          #p."tree-sitter-ocaml"
          #p."tree-sitter-julia"
          #p."tree-sitter-html"
          #p."tree-sitter-haskell"
          #p."tree-sitter-regex"
          #p."tree-sitter-css"
          #p."tree-sitter-jsdoc"
          #p."tree-sitter-tsq"
          #p."tree-sitter-beancount"
          #p."tree-sitter-comment"
          #p."tree-sitter-dart"
          p."tree-sitter-nix"
          #p."tree-sitter-lua"
          #p."tree-sitter-make"
          #p."tree-sitter-markdown"
          #p."tree-sitter-rst"
          #p."tree-sitter-vim"
          #p."tree-sitter-yaml"
          #p."tree-sitter-toml"
          #p."tree-sitter-zig"
          #p."tree-sitter-fish"
          #p."tree-sitter-norg"
          #p."tree-sitter-dockerfile"
          #p."tree-sitter-scss"
          #p."tree-sitter-tlaplus"
          #p."tree-sitter-elm"
          #p."tree-sitter-cmake"
          #p."tree-sitter-json5"
          #p."tree-sitter-org-nvim"
        ]))
      ];
      config = asLua ''
        require'nvim-treesitter.configs'.setup {
          ensure_installed = { "nix", "rust" },
          sync_install = false,
          highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
          },
          incremental_selection = {
            enable = false,
            keymaps = {
              init_selection = "gnn",
              node_incremental = "grn",
              scope_incremental = "grc",
              node_decremental = "grm",
            },
          },
          indent = {
            enable = true
          },
        }
      '';
    }

    # NAVIGATION
    { plugins = with vimPlugins; [
        telescope-nvim
        telescope-fzf-native-nvim
        telescope-file-browser-nvim
        telescope-github-nvim
        telescope-project-nvim
        # TODO: https://github.com/nvim-telescope/telescope-media-files.nvim
        # TODO: https://github.com/pwntester/octo.nvim#-pr-review
      ];
      config = asLua ''
        require('telescope').setup {
          extensions = {
            fzf = {
              fuzzy = true,                    -- false will only do exact matching
              override_generic_sorter = true,  -- override the generic sorter
              override_file_sorter = true,     -- override the file sorter
              case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                               -- the default case_mode is "smart_case"
            },
            file_browser = {
              theme = "ivy",
              mappings = {
                ["i"] = {
                  -- your custom insert mode mappings
                },
                ["n"] = {
                  -- your custom normal mode mappings
                },
              },
            },
            project = {
              base_dirs = {
                {'~/dev/', max_depth = 3},
              },
            },
          },
        }

        require("telescope").load_extension("fzf")
        require("telescope").load_extension("file_browser")
        require('telescope').load_extension('gh')
        require'telescope'.load_extension('project')

        local wk = require("which-key")
        wk.register({
          b = {
            name = "buffers",
            b = { "<cmd>Telescope buffers<cr>"      , "Buffers" },
          },
          f = {
            name = "files",
            n = { "<cmd>enew<cr>"                   , "New File" },
            r = { "<cmd>Telescope oldfiles<cr>"     , "Open Recent File" },
            f = { "<cmd>Telescope find_files<cr>"   , "Find File" },
            F = { "<cmd>Telescope file_browser<cr>" , "File browser" },
            s = { "<cmd>Telescope live_grep<cr>"    , "Live grep" },
          },
          g = {
            name = "git",
            c = { "<cmd>Telescope git_commits<cr>"  , "Commits diff" },
            C = { "<cmd>Telescope git_bcommits<cr>" , "Buffer's commits diff" },
            b = { "<cmd>Telescope git_branches<cr>" , "Branches" },
            s = { "<cmd>Telescope git_status<cr>"   , "Status" },
            S = { "<cmd>Telescope git_stash<cr>"    , "Stash" },
            g = { name = "GitHub",
              i = { "<cmd>Telescope gh issues<cr>"       , "Issues" },
              p = { "<cmd>Telescope gh pull_request<cr>" , "Pull Requests" },
              g = { "<cmd>Telescope gh gist<cr>"         , "Gists" },
              r = { "<cmd>Telescope gh run<cr>"          , "Workflow runs" },
            },
          },
          s = { "<cmd>Telescope spell_suggest<cr>", "Spell suggest" },
          H = { "<cmd>Telescope man_pages<cr>"    , "Man pages" },
          h = { "<cmd>Telescope help_tags<cr>"    , "Help tags" },
          m = { "<cmd>Telescope marks<cr>"        , "Marks" },
          p = { "<cmd>Telescope project<cr>"      , "Projects" },
        }, { prefix = "<leader>" })
      '';
    }

    # EDITING - AUTOCOMPLETION / SNIPPETS
    { plugins = with vimPlugins; [
        luasnip
        #friendly-snippets
        vim-snippets

        nvim-cmp

        cmp-buffer
        cmp-emoji
        cmp-path
        cmp-nvim-lua
        cmp-omni
        cmp_luasnip
        cmp-nvim-lsp
        cmp-nvim-lsp-document-symbol
      ];
      config = asLua ''
        local has_words_before = function()
          local line, col = unpack(vim.api.nvim_win_get_cursor(0))
          return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
        end

        local luasnip = require("luasnip")
        local cmp = require("cmp")

        require("luasnip.loaders.from_vscode").load()
        require("luasnip.loaders.from_snipmate").load()

        cmp.setup({
          snippet = {
            expand = function(args)
              require('luasnip').lsp_expand(args.body)
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
            ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept
            ["<Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
              elseif has_words_before() then
                cmp.complete()
              else
                fallback()
              end
            end, { "i", "s" }),

            ["<S-Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
              else
                fallback()
              end
            end, { "i", "s" }),
          },
          sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'nvim_lsp_document_symbol' },
            { name = 'luasnip' },
            { name = 'buffer' },
            { name = 'path' },
            { name = 'omni' },
            { name = 'emoji' },
            { name = 'nvim-lua' },
          }, {
            { name = 'buffer' },
          }),
        })


      '';
    }

    # EDITING - LSP
    { plugins = with vimPlugins; [
        nvim-lspconfig
        # TODO: https://github.com/brymer-meneses/grammar-guard.nvim_lsp
        # TODO: https://github.com/simrat39/rust-tools.nvim/
      ];
      config = asLua ''
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

        local lspconfig = require('lspconfig')

        -- Mappings.
        -- See `:help vim.diagnostic.*` for documentation on any of the below functions
        local opts = { noremap=true, silent=true }
        vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
        vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
        vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
        vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

        -- Use an on_attach function to only map the following keys
        -- after the language server attaches to the current buffer
        local on_attach = function(client, bufnr)
          -- Enable completion triggered by <c-x><c-o>
          vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

          -- Mappings.
          -- See `:help vim.lsp.*` for documentation on any of the below functions
          vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
        end
        -- Use a loop to conveniently call 'setup' on multiple servers and
        -- map buffer local keybindings when the language server attaches

        local servers = {
          "bashls",
          "beancount",
          "cssls",
          "elmls",
          "html",
          "jsonls",
          "nickel_ls",
          "pyright",
          "rls",
          "rnix",
          "terraformls",
        }

        for _, lsp in pairs(servers) do
          lspconfig[lsp].setup {
            on_attach = on_attach,
            flags = {
              -- This will be the default in neovim 0.7+
              debounce_text_changes = 150,
            }
          }
        end

        -- https://github.com/nvim-telescope/telescope.nvim#neovim-lsp-pickers
        local wk = require("which-key")
        wk.register({
          l = {
            name = "LSP",
            l = { "<cmd>lua vim.lsp.buf.hover()<cr>"           , "Hover" },
            f = { "<cmd>lua vim.lsp.buf.formatting()<cr>"      , "Format" },
            r = { "<cmd>lua vim.lsp.buf.references()<cr>"      , "references" },
            R = { "<cmd>lua vim.lsp.buf.rename()<cr>"          , "Rename" },
            s = { "<cmd>lua vim.lsp.buf.signature_help()<cr>"  , "Singnature help" },
            d = { "<cmd>lua vim.lsp.buf.definition()<cr>"      , "Definition" },
            d = { "<cmd>lua vim.lsp.buf.declaration()<cr>"     , "Declaration" },
            t = { "<cmd>lua vim.lsp.buf.type_definition()<cr>" , "Type Definition" },
            i = { "<cmd>lua vim.lsp.buf.implementation()<cr>"  , "Implementation" },
          },
        }, { prefix = "<leader>" })
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
