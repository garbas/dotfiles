{ pkgs, lib, config, user, hostname, inputs, ... }:
{

  programs.neovim.enable = true;
  programs.neovim.viAlias = true;
  programs.neovim.vimAlias = true;
  programs.neovim.vimdiffAlias = true;
  programs.neovim.withNodeJs = true;
  programs.neovim.withPython3 = true;
  programs.neovim.withRuby = true;
  programs.neovim.defaultEditor = true;
  programs.neovim.extraLuaConfig = ''
    local g = vim.g
    local o = vim.opt

    -- Use <Space> as the leader key
    g.mapleader = " "
    g.maplocalleader = "\\"

    -- o.number         = true  -- enable line number
    -- o.relativenumber = true  -- enable relative line number
    o.undofile       = true     -- persistent undo
    o.backup         = false    -- disable backup
    o.number         = true     -- enable line number
    o.relativenumber = false    -- enable relative line number
    o.cursorline     = true     -- enable cursor line
    o.cursorlineopt  = "both"
    o.expandtab      = true     -- use spaces instead of tabs
    o.autowrite      = true     -- auto write buffer when it's not focused
    o.hidden         = true     -- keep hidden buffers
    o.hlsearch       = true     -- highlight matching search
    o.ignorecase     = true     -- case insensitive on search..
    o.smartcase      = true     -- ..unless there's a capital
    o.equalalways    = true     -- make window size always equal
    o.list           = true     -- display listchars
    o.showmode       = false    -- don't show mode
    o.autoindent     = true     -- enable autoindent
    o.smartindent    = true     -- smarter indentation
    o.smarttab       = true     -- make tab behaviour smarter
    o.splitbelow     = true     -- split below instead of above
    o.splitright     = true     -- split right instead of left
    o.splitkeep      = "screen" -- stabilize split
    o.startofline    = false    -- don't go to the start of the line when moving to another file
    o.swapfile       = false    -- disable swapfile
    o.termguicolors  = true     -- true colours for better experience
    o.wrap           = false    -- don't wrap lines
    o.writebackup    = false    -- disable backup
    o.swapfile       = false    -- disable swap
    o.backupcopy     = "yes"    -- fix weirdness for stuff that replaces the entire file when hot reloading
    o.completeopt    = {
      "menu",
      "menuone",
      "noselect",
      "noinsert",
    }                           -- better completion
    o.encoding       = "UTF-8"  -- set encoding
    o.fillchars      = {
      vert = "│",
      eob = " ",
      diff = " ",
      fold = " ",
      foldopen = "",
      foldsep = " ",
      foldclose = "",
    }                           -- make vertical split sign better
    o.foldmethod     = "expr"
    o.foldopen       = {
      "percent",
      "search",
    }                           -- don't open fold if I don't tell it to do so
    o.inccommand     = "split"  -- incrementally show result of command
    o.list           = true;
    o.listchars      = {
      -- eol = "↲",
      -- tab = "» ",
      tab = "▸▸",
      trail = "·",
    }                           -- set listchars
    o.mouse          = "nvi"    -- enable mouse support in normal, insert, and visual mode
    o.shortmess      = "csa"    -- disable some stuff on shortmess
    o.signcolumn     = "yes:1"  -- enable sign column all the time 4 column
    o.shell          = "${pkgs.zsh}/bin/zsh" 
                                -- use bash instead of zsh
    o.colorcolumn    = { "80" } -- 80 chars color column
    o.laststatus     = 3        -- always enable statusline
    o.pumheight      = 10       -- limit completion items
    o.re             = 0        -- set regexp engine to auto
    o.scrolloff      = 2        -- make scrolling better
    o.sidescroll     = 2        -- make scrolling better
    o.shiftwidth     = 2        -- set indentation width
    o.sidescrolloff  = 15       -- make scrolling better
    o.tabstop        = 2        -- tabsize
    o.timeoutlen     = 400      -- faster timeout wait time
    o.updatetime     = 1000     -- set faster update time
    o.joinspaces     = false
    o.diffopt:append { "algorithm:histogram", "indent-heuristic" }

    -- Turn persistent undo on, means that you can undo even when you close a buffer/VIM
    o.undofile       = true
    o.undodir        = vim.fn.expand("$HOME/.cache/vim_runtime/temp_dirs/undodir")

    -- Use the system clipboard
    o.clipboard      = "unnamed"


  '';

  programs.neovim.plugins = with pkgs.vimPlugins; [

    # Intelligently reopen files at your last edit position.
    # https://github.com/farmergreg/vim-lastplace
    vim-lastplace

    # Nord-ish color theme
    { plugin = nordic-nvim;
      type = "lua";
      config = ''
        -- XXX: next release will only need
        -- require("nordic").load()
        require("nordic").colorscheme({
            -- Underline style used for spelling
            -- Options: 'none', 'underline', 'undercurl'
            underline_option = "none",

            -- Italics for certain keywords such as constructors, functions,
            -- labels and namespaces
            italic = true,

            -- Italic styled comments
            italic_comments = false,

            -- Minimal mode: different choice of colors for Tabs and StatusLine
            minimal_mode = false,

            -- Darker backgrounds for certain sidebars, popups, etc.
            -- Options: true, false, or a table of explicit names
            -- Supported: terminal, qf, vista_kind, packer, nvim-tree, telescope, whichkey
            alternate_backgrounds = false,

            -- Callback function to define custom color groups
            -- See 'lua/nordic/colors/example.lua' for example defitions
            --custom_colors = function(c, s, cs)
            --  return {}
            --end
        })
      '';
    }

    # A lua powered greeter (like vim-startify / dashboard-nvim)
    # https://github.com/goolord/alpha-nvim
    nvim-web-devicons
    { plugin = alpha-nvim;
      type = "lua";
      config = ''
        local startify = require("alpha.themes.startify")
        startify.file_icons.provider = "devicons"
        require("alpha").setup(
          startify.config
        )
      '';
    }

    # Displays a popup with possible keybindings of the command you
    # started typing.
    # https://github.com/folke/which-key.nvim
    { plugin = which-key-nvim;
      type = "lua";
      config = ''
        local wk = require("which-key")
        wk.add({
          { "<leader>q", ":wqa<cr>", desc = "Save and exit" },
          { "<leader>w", ":bd<cr>", desc = "Close buffer" },
        })
      '';
    }

    # Syntax highlighting (via treesitter)
    { plugin = nvim-treesitter.withPlugins (p: [
        p."tree-sitter-rust"
        p."tree-sitter-nix"
        p."tree-sitter-json"
        p."tree-sitter-javascript"
        p."tree-sitter-typescript"
        p."tree-sitter-bash"
        p."tree-sitter-html"
        p."tree-sitter-css"
        p."tree-sitter-astro"
      ]);
      type = "lua";
      config = ''
        require("nvim-treesitter.configs").setup {
          ensure_installed = {},
          sync_install = false,
          auto_install = false,
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

    # Navigation using Telescope
    # https://github.com/nvim-telescope/telescope.nvim/
    telescope-fzf-native-nvim
    telescope-file-browser-nvim
    #TODO: telescope-dap-nvim
    #TODO: telescope-github-nvim
    #TODO: telescope-lsp-handlers-nvim
    #TODO: telescope-manix-nvim
    #TODO: telescope-zoxide-nvim
    { plugin = telescope-nvim;
      type = "lua";
      config = ''
        require("telescope").setup {
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
          },
        }

        local wk = require("which-key")
        wk.add({
          { "<leader>H", "<cmd>Telescope man_pages<cr>", desc = "Man pages" },
          { "<leader>b", group = "buffers" },
          { "<leader>bb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
          { "<leader>f", group = "files" },
          { "<leader>fF", "<cmd>Telescope file_browser<cr>", desc = "File browser" },
          { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find File" },
          { "<leader>fn", "<cmd>enew<cr>", desc = "New File" },
          { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Open Recent File" },
          { "<leader>fs", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
          { "<leader>g", group = "git" },
          { "<leader>gC", "<cmd>Telescope git_bcommits<cr>", desc = "Buffer's commits diff" },
          { "<leader>gS", "<cmd>Telescope git_stash<cr>", desc = "Stash" },
          { "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Branches" },
          { "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Commits diff" },
          { "<leader>gg", group = "GitHub" },
          { "<leader>ggg", "<cmd>Telescope gh gist<cr>", desc = "Gists" },
          { "<leader>ggi", "<cmd>Telescope gh issues<cr>", desc = "Issues" },
          { "<leader>ggp", "<cmd>Telescope gh pull_request<cr>", desc = "Pull Requests" },
          { "<leader>ggr", "<cmd>Telescope gh run<cr>", desc = "Workflow runs" },
          { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Status" },
          { "<leader>h", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
          { "<leader>m", "<cmd>Telescope marks<cr>", desc = "Marks" },
          { "<leader>p", "<cmd>Telescope project<cr>", desc = "Projects" },
          { "<leader>s", "<cmd>Telescope spell_suggest<cr>", desc = "Spell suggest" },
        })
      '';
    }

    # AI
    # https://github.com/zbirenbaum/copilot.lua
    { plugin = copilot-lua;
      type = "lua";
      config = ''
        require("copilot").setup({
          suggestion = { enabled = false },
          panel = { enabled = false },
          copilot_node_command = "${pkgs.nodejs_22}/bin/node", -- Node.js version must be > 18.x
        })
      '';
    }

    # EDITING - AUTOCOMPLETION / SNIPPETS
    luasnip
    vim-snippets
    cmp-buffer
    cmp-emoji
    cmp-path
    cmp-nvim-lua
    cmp-omni
    cmp_luasnip
    cmp-nvim-lsp
    cmp-nvim-lsp-document-symbol
    copilot-cmp
    { plugin = nvim-cmp;
      type = "lua";
      config = ''
        require("copilot_cmp").setup()

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
            { name = 'copilot' },
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

    # LSP
    { plugin = nvim-lspconfig;
      type = "lua";
      config = ''
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

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
          "ccls",
          "cssls",
          "html",
          "jsonls",
          "nickel_ls",
          "pyright",
          "rust_analyzer",
          "terraformls",
          "tailwindcss",
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
        wk.add({
          { "<leader>l", group = "LSP" },
          { "<leader>lD", "<cmd>lua vim.lsp.buf.declaration()<cr>", desc = "Declaration" },
          { "<leader>lI", "<cmd>Telescope lsp_implementations<cr>", desc = "Implementation" },
          { "<leader>lR", "<cmd>lua vim.lsp.buf.rename()<cr>", desc = "Rename" },
          { "<leader>lS", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "Workspace symbols" },
          { "<leader>lY", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
          { "<leader>ld", "<cmd>Telescope lsp_definitions<cr>", desc = "Definitions" },
          { "<leader>lf", "<cmd>lua vim.lsp.buf.formatting()<cr>", desc = "Format" },
          { "<leader>li", "<cmd>Telescope lsp_incoming_calls<cr>", desc = "Incoming calls" },
          { "<leader>ll", "<cmd>lua vim.lsp.buf.hover()<cr>", desc = "Hover" },
          { "<leader>lo", "<cmd>Telescope lsp_outgoing_calls<cr>", desc = "Outgoing calls" },
          { "<leader>lr", "<cmd>Telescope lsp_references<cr>", desc = "References" },
          { "<leader>ls", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document symbols" },
          { "<leader>lt", "<cmd>Telescope lsp_type_definitions<cr>", desc = "Type definition" },
          { "<leader>ly", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", desc = "Workspace symbols" },
        })
      '';
    }
  ];

}
