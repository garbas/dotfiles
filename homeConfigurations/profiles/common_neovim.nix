{ pkgs, customVimPlugins, ... }:
{

  # TODO:
  # - https://github.com/kwkarlwang/bufresize.nvim
  # - https://github.com/mrjones2014/legendary.nvim
  # - https://github.com/mrjones2014/op.nvim
  # - https://github.com/sindrets/diffview.nvim
  # - https://github.com/catppuccin/nvim?tab=readme-ov-file#integrations (See other plugins)

  # - Toggleterm config example: https://github.com/cpow/neovim-for-newbs/issues/1
  # - https://github.com/cpow/neovim-for-newbs/tree/main/lua/plugins
  # - https://github.com/xzbdmw/colorful-menu.nvim
  # - https://github.com/danymat/neogen
  # - LSP
  #   - https://nvimluau.dev/folke-trouble-nvim
  #   - https://lsp-zero.netlify.app, https://github.com/VonHeikemen/lsp-zero.nvim
  #   - https://github.com/nvimtools/none-ls.nvim
  # - https://github.com/stevearc/dressing.nvim
  # - https://github.com/nvim-neorg/neorg

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

      # Map keys without delay when typing
      # https://github.com/max397574/better-escape.nvim
      {
        plugin = better-escape-nvim;
        type = "lua";
        config = # lua
          ''
            require("better_escape").setup()
          '';
      }

      # 🍨 Soothing pastel theme fsor (Neo)vim
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
              custom_highlights = function(colors)
                return {
                  WinSeparator = { fg = colors.surface1 },
                }
              end,
              default_integrations = false,
              integrations = {
                alpha = true,
                blink_cmp = true; 
                gitsigns = true,
                markdown = true,
              },
              native_lsp = {
                enabled = true,
                virtual_text = {
                    errors = { "italic" },
                    hints = { "italic" },
                    warnings = { "italic" },
                    information = { "italic" },
                    ok = { "italic" },
                },
                underlines = {
                    errors = { "underline" },
                    hints = { "underline" },
                    warnings = { "underline" },
                    information = { "underline" },
                    ok = { "underline" },
                },
                inlay_hints = {
                    background = true,
                },
              },
              notify = true,
              treesitter = true,
              telescope = {
                enabled = true,
              },
              which_key = true,
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

      # Indent guides for Neovim
      # https://github.com/lukas-reineke/indent-blankline.nvim
      {
        plugin = indent-blankline-nvim;
        type = "lua";
        config = # lua
          ''
            require("ibl").setup()
          '';

      }

      # 🧘 Distraction-free coding for Neovim
      # https://github.com/folke/zen-mode.nvim
      {
        plugin = zen-mode-nvim;
        type = "lua";
        config = # lua
          ''
            require("zen-mode").setup()
            require("which-key").add({
              { "<leader>z",  group = "Zen Mode" },
              { "<leader>zz", "<cmd>:ZenMode<cr>", desc = "Zen Mode" },
            })
          '';
      }

      # A fancy, configurable, notification manager for NeoVim
      # https://github.com/rcarriga/nvim-notify
      {
        plugin = nvim-notify;
        type = "lua";
        config = # lua
          ''
            vim.notify = require("notify")
            require("which-key").add({
              { "<leader>N",  group = "Notifications" },
              { "<leader>Nn", "<cmd>:Telescope notify<cr>", desc = "Notification" },
              { "<leader>Nc", "<cmd>lua require(\"notify\").clear_history()<cr>", desc = "Dismiss All Notifications" },
              { "<leader>Nh", "<cmd>lua require(\"notify\").history()<cr>", desc = "Notification History" },
            })
          '';
      }

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

      # A lua powered greeter (like vim-startify / dashboard-nvim)
      # https://github.com/goolord/alpha-nvim
      nvim-web-devicons
      {
        plugin = alpha-nvim;
        type = "lua";
        config = # lua
          ''
            local dashboard = require("alpha.themes.dashboard")
            local theta = require("alpha.themes.theta")
            -- See https://github.com/goolord/alpha-nvim/discussions/16#discussioncomment-10062303
            theta.header.val = {
              [[          ███████████████████████ ]],
              [[       ██████████████████████████ ]],
              [[    █████████████████████████████ ]],
              [[ ████████████████████████████████ ]],
              [[ █████████████████████████████    ]],
              [[ ███████████████████████          ]],
              [[ █████████████████                ]],
              [[ ███████████                      ]],
              [[            ██████████████████████ ]],
              [[            ██████████████████████ ]],
              [[            ██████████████████████ ]],
              [[            ██████████████████████ ]],
              [[ ███████████                       ]],
              [[ ███████████                       ]],
              [[ ███████████                       ]],
              [[ ███████████                       ]],
              [[                                   ]],
            }
            theta.buttons.val = {
              dashboard.button( "e", "  > New file" , ":ene <BAR> startinsert <CR>"),
              dashboard.button( "f", "  > Find file", ":cd $HOME/dev | Telescope find_files<CR>"),
              dashboard.button( "r", "  > Recent"   , ":Telescope oldfiles<CR>"),
              dashboard.button( "q", "  > Quit NVIM", ":qa<CR>"),
            }
            theta.file_icons.provider = "devicons"
            require("alpha").setup(theta.config)
          '';
      }

      # Smooth scrolling neovim plugin written in lua
      # https://github.com/karb94/neoscroll.nvim
      {
        plugin = neoscroll-nvim;
        type = "lua";
        config = # lua
          ''
            require('neoscroll').setup()
          '';
      }

      # Syntax highlighting (via treesitter)
      # https://github.com/nvim-treesitter/nvim-treesitter
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
      telescope-github-nvim
      telescope-lsp-handlers-nvim
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
                lsp_handlers = {},
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
              keymap = {
                preset = 'enter',
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
                ghost_text = { enabled = false },
                list = {
                  selection = function(ctx)
                    return ctx.mode == 'cmdline' and 'manual' or 'auto_insert'
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

      # -- Misc ---------------------------------------------------------------

      # A neovim lua plugin to help easily manage multiple terminal windows
      # https://github.com/akinsho/toggleterm.nvim
      {
        plugin = toggleterm-nvim;
        type = "lua";
        config = # lua
          ''
            require("toggleterm").setup({
            })
            require("which-key").add({
              { "<leader>tt",      "<cmd>:ToggleTerm<cr>", desc = "Toggle Terminal" },
              { "<leader>tT",      "<cmd>:ToggleTermToggleAll<cr>", desc = "Toggle All Terminal" },
            })
          '';
      }

      # The fastest Neovim colorizer
      # https://github.com/catgoose/nvim-colorizer.lua
      {
        plugin = nvim-colorizer-lua;
        type = "lua";
        config = # lua
          ''
            require("colorizer").setup({
            })
          '';
      }

      # 👀 Move faster with unique f/F indicators.
      # https://github.com/jinh0/eyeliner.nvim
      {
        plugin = eyeliner-nvim;
        type = "lua";
        config = # lua
          ''
            require("eyeliner").setup({
              -- show highlights only after keypress
              highlight_on_key = true,

              -- dim all other characters if set to true (recommended!)
              dim = true,

              -- set the maximum number of characters eyeliner.nvim will check from
              -- your current cursor position; this is useful if you are dealing with
              -- large files: see https://github.com/jinh0/eyeliner.nvim/issues/41
              max_length = 9999,

              -- filetypes for which eyeliner should be disabled;
              -- e.g., to disable on help files:
              -- disabled_filetypes = {"help"}
              disabled_filetypes = {},

              -- buftypes for which eyeliner should be disabled
              -- e.g., disabled_buftypes = {"nofile"}
              disabled_buftypes = {},

              -- add eyeliner to f/F/t/T keymaps;
              -- see section on advanced configuration for more information
              default_keymaps = true,
            })
          '';
      }
      # Super fast git decorations implemented purely in Lua.
      # https://github.com/lewis6991/gitsigns.nvim
      {
        plugin = gitsigns-nvim;
        type = "lua";
        config = # lua
          ''
            require("gitsigns").setup({
            })
          '';
      }

      # A blazing fast and easy to configure neovim statusline plugin written
      # in pure lua.
      # https://github.com/nvim-lualine/lualine.nvim
      {
        plugin = lualine-nvim;
        type = "lua";
        config = # lua
          ''
            local winbar = {
              lualine_a = {'mode'},
              lualine_b = {'branch', 'diff', 'diagnostics'},
              lualine_c = {'filename'},
              lualine_x = {'encoding', 'fileformat', 'filetype'},
              lualine_y = {'progress'},
              lualine_z = {'location'}
            }
            require("lualine").setup({
              sections = {},
              inactive_sections = {},
              winbar = winbar,
              inactive_winbar = winbar,
              options = {
                theme = "catppuccin",
              },
              extensions = { 'oil', 'toggleterm' },
            })
          '';
      }

      # 🧠 Smart, seamless, directional navigation and resizing of Neovim +
      # terminal multiplexer splits. Supports tmux, Wezterm, and Kitty. Think
      # about splits in terms of "up/down/left/right".
      # https://github.com/mrjones2014/smart-splits.nvim
      {
        plugin = smart-splits-nvim;
        type = "lua";
        config = # lua
          ''
            require('smart-splits').setup({
              -- Ignored buffer types (only while resizing)
              ignored_buftypes = {
                'nofile',
                'quickfix',
                'prompt',
              },
              -- Ignored filetypes (only while resizing)
              ignored_filetypes = { 'NvimTree' },
              -- the default number of lines/columns to resize by at a time
              default_amount = 3,
              -- Desired behavior when your cursor is at an edge and you
              -- are moving towards that same edge:
              -- 'wrap' => Wrap to opposite side
              -- 'split' => Create a new split in the desired direction
              -- 'stop' => Do nothing
              -- function => You handle the behavior yourself
              -- NOTE: If using a function, the function will be called with
              -- a context object with the following fields:
              -- {
              --    mux = {
              --      type:'tmux'|'wezterm'|'kitty'
              --      current_pane_id():number,
              --      is_in_session(): boolean
              --      current_pane_is_zoomed():boolean,
              --      -- following methods return a boolean to indicate success or failure
              --      current_pane_at_edge(direction:'left'|'right'|'up'|'down'):boolean
              --      next_pane(direction:'left'|'right'|'up'|'down'):boolean
              --      resize_pane(direction:'left'|'right'|'up'|'down'):boolean
              --      split_pane(direction:'left'|'right'|'up'|'down',size:number|nil):boolean
              --    },
              --    direction = 'left'|'right'|'up'|'down',
              --    split(), -- utility function to split current Neovim pane in the current direction
              --    wrap(), -- utility function to wrap to opposite Neovim pane
              -- }
              -- NOTE: `at_edge = 'wrap'` is not supported on Kitty terminal
              -- multiplexer, as there is no way to determine layout via the CLI
              at_edge = 'wrap',
              -- Desired behavior when the current window is floating:
              -- 'previous' => Focus previous Vim window and perform action
              -- 'mux' => Always forward action to multiplexer
              float_win_behavior = 'previous',
              -- when moving cursor between splits left or right,
              -- place the cursor on the same row of the *screen*
              -- regardless of line numbers. False by default.
              -- Can be overridden via function parameter, see Usage.
              move_cursor_same_row = false,
              -- whether the cursor should follow the buffer when swapping
              -- buffers by default; it can also be controlled by passing
              -- `{ move_cursor = true }` or `{ move_cursor = false }`
              -- when calling the Lua function.
              cursor_follows_swapped_bufs = false,
              -- resize mode options
              resize_mode = {
                -- key to exit persistent resize mode
                quit_key = '<ESC>',
                -- keys to use for moving in resize mode
                -- in order of left, down, up' right
                resize_keys = { 'h', 'j', 'k', 'l' },
                -- set to true to silence the notifications
                -- when entering/exiting persistent resize mode
                silent = false,
                -- must be functions, they will be executed when
                -- entering or exiting the resize mode
                hooks = {
                  on_enter = nil,
                  on_leave = nil,
                },
              },
              -- ignore these autocmd events (via :h eventignore) while processing
              -- smart-splits.nvim computations, which involve visiting different
              -- buffers and windows. These events will be ignored during processing,
              -- and un-ignored on completed. This only applies to resize events,
              -- not cursor movement events.
              ignored_events = {
                'BufEnter',
                'WinEnter',
              },
              -- enable or disable a multiplexer integration;
              -- automatically determined, unless explicitly disabled or set,
              -- by checking the $TERM_PROGRAM environment variable,
              -- and the $KITTY_LISTEN_ON environment variable for Kitty
              multiplexer_integration = nil,
              -- disable multiplexer navigation if current multiplexer pane is zoomed
              -- this functionality is only supported on tmux and Wezterm due to kitty
              -- not having a way to check if a pane is zoomed
              disable_multiplexer_nav_when_zoomed = true,
              -- Supply a Kitty remote control password if needed,
              -- or you can also set vim.g.smart_splits_kitty_password
              -- see https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.remote_control_password
              kitty_password = nil,
              -- default logging level, one of: 'trace'|'debug'|'info'|'warn'|'error'|'fatal'
              log_level = 'info',
            })

            require("which-key").add({
              { "<leader>w",  group = "Windows" },
              -- resizing splits
              { "<leader>wrh", "<cmd>lua require('smart-splits').resize_left(10)<cr>", desc = "Resize left" },
              { "<leader>wrj", "<cmd>lua require('smart-splits').resize_down(10)<cr>", desc = "Resize down" },
              { "<leader>wrk", "<cmd>lua require('smart-splits').resize_up(10)<cr>", desc = "Resize up" },
              { "<leader>wrl", "<cmd>lua require('smart-splits').resize_right(10)<cr>", desc = "Resize right" },
              -- moving between splits
              { "<leader>wh", "<cmd>lua require('smart-splits').move_cursor_left()<cr>", desc = "Move left" },
              { "<leader>wj", "<cmd>lua require('smart-splits').move_cursor_down()<cr>", desc = "Mode down" },
              { "<leader>wk", "<cmd>lua require('smart-splits').move_cursor_up()<cr>", desc = "Move up" },
              { "<leader>wl", "<cmd>lua require('smart-splits').move_cursor_right()<cr>", desc = "Move right" },
              { "<leader>w<tab>", "<cmd>lua require('smart-splits').move_cursor_previous()<cr>", desc = "Move previous" },
              -- swapping buffers between windows
              { "<leader>wH", "<cmd>lua require('smart-splits').swap_buf_left()<cr>", desc = "Swap left" },
              { "<leader>wJ", "<cmd>lua require('smart-splits').swap_buf_down()<cr>", desc = "Swap down" },
              { "<leader>wK", "<cmd>lua require('smart-splits').swap_buf_up()<cr>", desc = "Swap up" },
              { "<leader>wL", "<cmd>lua require('smart-splits').swap_buf_right()<cr>", desc = "Swap right" },
            })
          '';
      }
    ];

}
