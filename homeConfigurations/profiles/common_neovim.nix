{ pkgs, customVimPlugins, ... }:
{

  programs.neovim.enable = true;
  programs.neovim.viAlias = true;
  programs.neovim.vimAlias = true;
  programs.neovim.vimdiffAlias = true;
  programs.neovim.withNodeJs = true;
  programs.neovim.withPython3 = true;
  programs.neovim.withRuby = true;
  programs.neovim.defaultEditor = true;

  programs.neovim.extraLuaConfig = # lua
    ''
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

  programs.neovim.plugins =
    with pkgs.vimPlugins;
    with customVimPlugins;
    [

      # 🍨 Soothing pastel theme for (Neo)vim
      # https://github.com/catppuccin/nvim
      {
        plugin = catppuccin-nvim;
        type = "lua";
        config = # lua
          ''
            require("catppuccin").setup({
              flavour = "mocha",
              background = {
                  light = "latte",
                  dark = "mocha",
              },
            })
            vim.cmd.colorscheme("catppuccin")
          '';
      }

      # A Neovim plugin for macOS, Linux & Windows that automatically changes the
      # editor appearance based on system settings.
      # https://github.com/f-person/auto-dark-mode.nvim
      {
        plugin = custom-auto-dark-mode;
        type = "lua";
        config = # lua
          ''
            require('auto-dark-mode').setup({
              update_interval = 5000,
            })
          '';
      }

      # Intelligently reopen files at your last edit position.
      # https://github.com/farmergreg/vim-lastplace
      {
        plugin = vim-lastplace;
        type = "lua";
        config = # lua
          ''
            vim.g.lastplace_ignore = "gitcommit,gitrebase,hgcommit,svn,xxd"
            vim.g.lastplace_ignore_buftype = "help,nofile,quickfix"
            vim.g.lastplace_open_folds = 0
          '';
      }

      # Displays a popup with possible keybindings of the command you
      # started typing.
      # https://github.com/folke/which-key.nvim
      {
        plugin = which-key-nvim;
        type = "lua";
        config = # lua
          ''
            local wk = require("which-key")
            wk.add({
              { "<leader>q", ":wqa<cr>", desc = "Save and exit" },
              { "<leader>w", ":bd<cr>", desc = "Close buffer" },
            })
          '';
      }

      # Icons
      mini-icons # https://github.com/echasnovski/mini.icons
      nvim-web-devicons # https://github.com/nvim-tree/nvim-web-devicons

      #  Neovim file explorer: edit your filesystem like a buffer
      # https://github.com/stevearc/oil.nvim
      {
        plugin = oil-nvim;
        type = "lua";
        config = # lua
          ''
            require("oil").setup({
              columns = {
                "icon",
                "permissions",
                "size",
                "mtime",
              },
            })
          '';
      }

      # 🍿 A collection of small QoL plugins for Neovim
      # https://github.com/folke/snacks.nvim
      {
        plugin = snacks-nvim;
        type = "lua";
        config = # lua
          ''
            require("snacks").setup({

              -- Deal with big files
              bigfile = { enabled = true },

              -- Beautiful declarative dashboards
              dashboard = {
                enabled = true,
                sections = {
                  { section = "header" },
                  { icon = " ", title = "Recent Files", section = "recent_files", padding = 1 },
                  { icon = " ", title = "Projects", section = "projects", padding = 1 },
                },
              },

              -- Focus on the active scope by dimming the rest
              dim = { enabled = true },

              -- Indent guides and scopes
              indent = { enabled = true },

              -- Better vim.ui.input
              input = { enabled = true },

              -- Open LazyGit in a float, auto-configure colorscheme and integration
              -- with Neovim
              lazygit = { enabled = true },

              -- Pretty vim.notify
              notifier = { enabled = true },

              -- When doing nvim somefile.txt, it will render the file as quickly as
              -- possible, before loading your plugins.
              quickfile = { enabled = true },

              -- LSP-integrated file renaming with support for plugins like
              -- neo-tree.nvim and mini.files
              rename = { enabled = true },

              -- Scope detection, text objects and jumping based on treesitter or
              -- indent
              scope = { enabled = true },

              -- Scratch buffers with a persistent file
              scratch = { enabled = true },

              -- Smooth scrolling
              scroll = { enabled = true },

              -- Pretty status column
              statuscolumn = { enabled = true },

              -- Create and toggle floating/split terminals
              terminal = { enabled = true },

              -- Toggle keymaps integrated with which-key icons / colors
              toggle = { enabled = true },

              -- Create and manage floating windows or splits
              win = { enabled = true },

              -- Auto-show LSP references and quickly navigate between them
              words = { enabled = true },

              -- Zen mode • distraction-free coding
              zen = { enabled = true },

            })
            require("which-key").add({
              { "<leader>z",  group = "Zen" },
              { "<leader>zz",  "<cmd>lua Snacks.zen()<cr>", desc = "Toggle Zen Mode" },
              { "<leader>zZ",  "<cmd>lua Snacks.zen.zoom()<cr>", desc = "Toggle Zoom" },

              { "<leader>y",  group = "Scratch" },
              { "<leader>y.",  "<cmd>lua Snacks.scratch()<cr>", desc = "Toggle Scratch Buffer" },
              { "<leader>ys",  "<cmd>lua Snacks.scratch.select()<cr>", desc = "Select Scratch Buffer" },

              { "<leader>n",  group = "Notifications" },
              { "<leader>nn", "<cmd>lua Snacks.notifier.hide()<cr>", desc = "Dismiss All Notifications" },
              { "<leader>nh",  "<cmd>lua Snacks.notifier.show_history()<cr>", desc = "Notification History" },

              { "<leader>b",  group = "Buffers" },
              { "<leader>bd", "<cmd>lua Snacks.bufdelete()<cr>", desc = "Delete Buffer" },

              { "<leader>f",  group = "Files" },
              { "<leader>fR", "<cmd>lua Snacks.rename.rename_file()<cr>", desc = "Rename File" },

              { "<leader>f",  group = "Git" },
              { "<leader>gB", "<cmd>lua Snacks.gitbrowse()<cr>", desc = "Git Browse", mode = { "n", "v" } },
              { "<leader>gb", "<cmd>lua Snacks.git.blame_line()<cr>", desc = "Git Blame Line" },
              { "<leader>gf", "<cmd>lua Snacks.lazygit.log_file()<cr>", desc = "Lazygit Current File History" },
              { "<leader>gg", "<cmd>lua Snacks.lazygit()<cr>", desc = "Lazygit" },
              { "<leader>gl", "<cmd>lua Snacks.lazygit.log()<cr>", desc = "Lazygit Log (cwd)" },

              { "<leader><leader>",      "<cmd>lua Snacks.terminal()<cr>", desc = "Toggle Terminal" },
              { "<c-_>",      "<cmd>lua Snacks.terminal()<cr>", desc = "which_key_ignore" },
              { "]]",         "<cmd>lua Snacks.words.jump(vim.v.count1)<cr>", desc = "Next Reference", mode = { "n", "t" } },
              { "[[",         "<cmd>lua Snacks.words.jump(-vim.v.count1)<cr>", desc = "Prev Reference", mode = { "n", "t" } },
            })
          '';
      }

      # Syntax highlighting (via treesitter)
      {
        plugin = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
        type = "lua";
        config = # lua
          ''
            require("nvim-treesitter.configs").setup {
              ensure_installed = {},
              sync_install = false,
              auto_install = false,
              highlight = {
                enable = true,
                -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                additional_vim_regex_highlighting = false,
              },
              incremental_selection = {
                enable = true,
                keymaps = {
                  init_selection = "vv",
                  node_incremental = "v",
                  scope_incremental = "b",
                  node_decremental = "V",
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
      telescope-github-nvim
      #TODO: telescope-lsp-handlers-nvim
      #TODO: telescope-manix-nvim
      {
        plugin = telescope-nvim;
        type = "lua";
        config = # lua
          ''
            local actions = require("telescope.actions")
            local actions_layout = require("telescope.actions.layout")
            require("telescope").setup {
              defaults = {
                mappings = {
                  i = {
                    -- Mapping <Esc> to quit in insert mode
                    ["<esc>"] = actions.close,
                    -- Mapping <C-u> to clear prompt
                    ["<C-u>"] = false,
                    -- Mapping to toggle the preview
                    ["<M-p>"] = actions_layout.toggle_preview,
                    -- Mapping <C-s>/<C-a> to cycle previewer for git commits to show full message
                    ["<C-s>"] = actions.cycle_previewers_next,
                    ["<C-a>"] = actions.cycle_previewers_prev,
                  },
                  n = {
                    -- Mapping to toggle the preview
                    ["<M-p>"] = actions_layout.toggle_preview
                  },
                },
                preview = {
                  -- Ignore files bigger than a threshold
                  filesize_limit = 0.3, -- in MB
                },
              },
              extensions = {
                fzf = {
                  fuzzy = true,                    -- false will only do exact matching
                  override_generic_sorter = true,  -- override the generic sorter
                  override_file_sorter = true,     -- override the file sorter
                  case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                                   -- the default case_mode is "smart_case"
                },
              },
            }

            require("which-key").add({
              { "<leader>H", "<cmd>Telescope man_pages<cr>", desc = "Man pages" },
              { "<leader>b", group = "Buffers" },
              { "<leader>bb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
              { "<leader>f", group = "Files" },
              { "<leader>fF", "<cmd>Telescope file_browser<cr>", desc = "File browser" },
              { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find File" },
              { "<leader>fn", "<cmd>enew<cr>", desc = "New File" },
              { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Open Recent File" },
              { "<leader>fs", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },

              { "<leader>g", group = "Git" },
              { "<leader>gC", "<cmd>Telescope git_bcommits<cr>", desc = "Buffer's commits diff" },
              { "<leader>gS", "<cmd>Telescope git_stash<cr>", desc = "Stash" },
              { "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Branches" },
              { "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Commits diff" },
              { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Status" },

              { "<leader>gh", group = "GitHub" },
              { "<leader>ghg", "<cmd>Telescope gh gist<cr>", desc = "Gists" },
              { "<leader>ghi", "<cmd>Telescope gh issues<cr>", desc = "Issues" },
              { "<leader>ghp", "<cmd>Telescope gh pull_request<cr>", desc = "Pull Requests" },
              { "<leader>ghr", "<cmd>Telescope gh run<cr>", desc = "Workflow runs" },

              { "<leader>h", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
              { "<leader>m", "<cmd>Telescope marks<cr>", desc = "Marks" },
              { "<leader>p", "<cmd>Telescope project<cr>", desc = "Projects" },
              { "<leader>s", "<cmd>Telescope spell_suggest<cr>", desc = "Spell suggest" },
            })
          '';
      }

      #  # TODO
      #  #    https://github.com/Robitx/gp.nvim
      #  #    https://github.com/NixOS/nixpkgs/issues/340281

      # AI
      # https://github.com/zbirenbaum/copilot.lua
      {
        plugin = copilot-lua;
        type = "lua";
        config = # lua
          ''
            require("copilot").setup({
              suggestion = { enabled = false },
              panel = { enabled = false },
              copilot_node_command = "${pkgs.nodejs}/bin/node", -- Node.js version must be > 18.x
            })
          '';
      }

      # -- COMPLETION / SNIPPETS ----------------------------------------------

      # Set of preconfigured snippets for different languages.
      # https://github.com/rafamadriz/friendly-snippets
      friendly-snippets

      # Compatibility layer for using nvim-cmp sources on blink.cmp
      # https://github.com/saghen/blink.compat
      blink-compat

      # Adds copilot suggestions as a source for Saghen/blink.cmp
      # https://github.com/giuxtaposition/blink-cmp-copilot
      blink-cmp-copilot

      # Faster LuaLS setup for Neovim
      # https://github.com/folke/lazydev.nvim
      {
        plugin = lazydev-nvim;
        type = "lua";
        config = # lua
          ''
            require("lazydev").setup({
              library = {
                -- See the configuration section for more details
                -- Load luvit types when the `vim.uv` word is found
                { path = "''${3 rd}/luv/library", words = { "vim%.uv" } },
              },
            })
          '';
      }

      # Performant, batteries-included completion plugin for Neovim
      # https://github.com/Saghen/blink.cmp
      {
        plugin = blink-cmp;
        type = "lua";
        config = # lua
          ''
            require("blink-compat").setup()
            require("blink-cmp").setup({

              -- 'default' for mappings similar to built-in completion
              -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
              -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
              -- See the full "keymap" documentation for information on defining your own keymap.
              keymap = { preset = 'enter' },

              appearance = {
                -- Sets the fallback highlight groups to nvim-cmp's highlight groups
                -- Useful for when your theme doesn't support blink.cmp
                -- Will be removed in a future release
                use_nvim_cmp_as_default = true,
                -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                -- Adjusts spacing to ensure icons are aligned
                nerd_font_variant = 'mono',
                -- Blink does not expose its default kind icons so you must copy them all (or set your custom ones) and add Copilot
                kind_icons = {
                  Copilot = "",
                  Text = '󰉿',
                  Method = '󰊕',
                  Function = '󰊕',
                  Constructor = '󰒓',

                  Field = '󰜢',
                  Variable = '󰆦',
                  Property = '󰖷',

                  Class = '󱡠',
                  Interface = '󱡠',
                  Struct = '󱡠',
                  Module = '󰅩',

                  Unit = '󰪚',
                  Value = '󰦨',
                  Enum = '󰦨',
                  EnumMember = '󰦨',

                  Keyword = '󰻾',
                  Constant = '󰏿',

                  Snippet = '󱄽',
                  Color = '󰏘',
                  File = '󰈔',
                  Reference = '󰬲',
                  Folder = '󰉋',
                  Event = '󱐋',
                  Operator = '󰪚',
                  TypeParameter = '󰬛',
                },
              },

              signature = {
                enabled = true,
              },

              -- Default list of enabled providers defined so that you can extend it
              -- elsewhere in your config, without redefining it, due to `opts_extend`
              sources = {
                default = { 'lazydev', 'copilot', 'lsp', 'path', 'snippets', 'buffer' },
                providers = {
                  lazydev = {
                    name = "LazyDev",
                    module = "lazydev.integrations.blink",
                    score_offset = 100,
                  },
                  copilot = { 
                    name = 'copilot',
                    module = "blink-cmp-copilot",
                    score_offset = 200,
                    async = true,
                    transform_items = function(_, items)
                      local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
                      local kind_idx = #CompletionItemKind + 1
                      CompletionItemKind[kind_idx] = "Copilot"
                      for _, item in ipairs(items) do
                        item.kind = kind_idx
                      end
                      return items
                    end,
                  },
                },
              },

              completion = {
                documentation = {
                  auto_show = true,
                  auto_show_delay_ms = 500,
                },
                ghost_text = { enabled = true },
                list = {
                  selection = function(ctx)
                    return ctx.mode == 'cmdline' and 'auto_insert' or 'preselect'
                  end,
                },
                menu = {
                  draw = {
                    -- Highlight the label text for the given list of sources.
                    -- This feature is experimental!
                    treesitter = { 'lsp' },
                    -- Components to render, grouped by column
                    columns = {
                      { 'kind_icon' },
                      { 'label', 'label_description', gap = 1 },
                      { 'kind' },
                      { 'source_name' },
                    },
                  },
                },
              },

              fuzzy = {
                prebuilt_binaries = {
                  download = false,
                },
              },
            })
          '';
      }

      # -- FORMAT ---------------------------------------------------------------

      # Lightweight yet powerful formatter plugin for Neovim
      # https://github.com/stevearc/conform.nvim
      {
        plugin = conform-nvim;
        type = "lua";
        config = # lua
          ''
            require("conform").setup({
              formatters_by_ft = {
                nix = { "nixfmt" },
                gci = { "gci" },
                gofmt = { "gofmt" },
                ["lua-format"] = { "lua-format" },
                ruff_format = { "ruff" },
                rustfmt = { "rustfmt" },
                shellcheck = { "shellcheck" },
                shfmt = { "shfmt" },
                zigfmt = { "zig fmt" },
              },
              -- Command to toggle format-on-save
              -- https://github.com/stevearc/conform.nvim/blob/master/doc/recipes.md#command-to-toggle-format-on-save
              format_on_save = function(bufnr)
                -- Disable with a global or buffer-local variable
                if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                  return
                end
                return { timeout_ms = 500, lsp_format = "fallback" }
              end,
            })

            vim.api.nvim_create_user_command("FormatDisable", function(args)
              if args.bang then
                -- FormatDisable! will disable formatting just for this buffer
                vim.b.disable_autoformat = true
              else
                vim.g.disable_autoformat = true
              end
            end, {
              desc = "Disable autoformat-on-save",
              bang = true,
            })
            vim.api.nvim_create_user_command("FormatEnable", function()
              vim.b.disable_autoformat = false
              vim.g.disable_autoformat = false
            end, {
              desc = "Re-enable autoformat-on-save",
            })

            require("which-key").add({
              { "<leader>F", group = "Format" },
              { "<leader>FF", "<cmd>lua require('conform').format()<cr>", desc = "Format" },
              { "<leader>Fe", ":FormatEnable<cr>", desc = "Re-enable autoformat-on-save" },
              { "<leader>Fd", "<cr>", desc = "Disable autoformat-on-save" },
            })
          '';
      }

      # -- LSP ------------------------------------------------------------------

      # TODO: https://github.com/folke/lazydev.nvim

      # Quickstart configs for Nvim LSP
      # https://github.com/neovim/nvim-lspconfig
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = # lua
          ''
            local capabilities = vim.lsp.protocol.make_client_capabilities()

            local lc = require('lspconfig')
            for _, item in ipairs({
              -- Web
              { name="ts_ls", executable="typescript-language-server", opts={} },
              { name="html", executable="vscode-html-language-server", opts={} },
              { name="htmx", executable="htmx-lsp", opts={} },
              { name="cssls", executable="vscode-css-language-server", opts={} },

              -- Config
              { name="nixd", executable="nixd", opts={} },
              { name="jsonls", executable="vscode-json-language-server", opts={} },
              { name="yamlls", executable="yaml-language-server", opts={} },

              -- Languages
              { name="bashls", executable="bash-language-server", opts={} },    -- Bash
              { name="gopls", executable="gopls", opts={} },                    -- Go
              { name="ruff_lsp", executable="ruff", opts={} },                  -- Python
              { name="rust_analyzer", executable="rust-analyzer", opts={} },    -- Rust
              { name="zls", executable="zls", opts={} },                        -- Zig

              -- Tools
              { name="dockerls", executable="dockerls", opts={} },              -- Docker

            }) do
              -- Only setup LSP if the executable is available
              if vim.fn.executable(item.executable) == 1 then
                local opts = item.opts
                opts.capabilities = require('blink.cmp').get_lsp_capabilities(capabilities)
                lc[item.name].setup(opts)
              end
            end

            -- https://github.com/nvim-telescope/telescope.nvim#neovim-lsp-pickers
            require("which-key").add({
              { "<leader>l", group = "LSP" },
              { "<leader>lD", "<cmd>lua vim.lsp.buf.declaration()<cr>", desc = "Declaration" },
              { "<leader>lI", "<cmd>Telescope lsp_implementations<cr>", desc = "Implementation" },
              { "<leader>lR", "<cmd>lua vim.lsp.buf.rename()<cr>", desc = "Rename" },
              { "<leader>lS", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "Workspace symbols" },
              { "<leader>lY", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
              { "<leader>ld", "<cmd>Telescope lsp_definitions<cr>", desc = "Definitions" },
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
