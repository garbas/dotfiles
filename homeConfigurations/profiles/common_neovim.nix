{
  pkgs,
  customVimPlugins,
  ...
}:
{

  # TODO:
  # - https://github.com/coder/claudecode.nvim (MCP integration - Claude sees buffers/selections)
  # - https://github.com/kndndrj/nvim-dbee
  # https://github.com/jackMort/tide.nvim
  # https://github.com/samjwill/nvim-unception
  # https://github.com/NeogitOrg/neogit
  # https://github.com/pwntester/octo.nvim

  # # Testing support
  # {
  #   plugin = neotest;
  #   type = "lua";
  #   config = # lua
  #     ''
  #       require("neotest").setup({
  #         adapters = {
  #           require("neotest-python"),
  #           require("neotest-go"),
  #           require("neotest-rust"),
  #         },
  #       })
  #     '';
  # }
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

  # Add required external tools to neovim's PATH
  # These are dependencies for various plugins:
  #   - ripgrep (rg): telescope, snacks picker/grep
  #   - fd: snacks picker/explorer, telescope file finding
  #   - lazygit: snacks.lazygit integration
  #   - ncurses: provides infocmp for terminal capabilities
  #   - imagemagick: render-markdown image conversion (magick, convert)
  #   - ghostscript: render-markdown PDF support (gs)
  #   - tectonic: render-markdown LaTeX rendering (modern, faster than pdflatex)
  #   - mermaid-cli: render-markdown mermaid diagram support (mmdc)
  programs.neovim.extraPackages = with pkgs; [
    ripgrep
    fd
    lazygit
    ncurses
    imagemagick
    ghostscript
    tectonic
    mermaid-cli
  ];
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
        msgsep = "‾",
        vert = "│",
        eob = " ",
        diff = "/",
        fold = " ",
        foldopen = "", --"",
        foldsep = " ",
        foldclose = "", --"",
      }                           -- make vertical split sign better
      o.inccommand     = "split"  -- incrementally show result of command
      o.list           = true;
      o.listchars      = {
        -- eol = "↲",
        -- tab = "» ",
        tab = "",
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
            require('better_escape').setup()
          '';
      }

      # Better navigation with leap motions
      # https://codeberg.org/andyg/leap.nvim (moved from GitHub)
      # Keybindings (Sneak-style, recommended):
      #   s{char}{char}  - Leap forward to location
      #   S{char}{char}  - Leap backward to location
      #   gs{char}{char} - Leap from windows (cross-window)
      #   x/X            - Exclusive selection (operator-pending)
      {
        plugin = leap-nvim;
        type = "lua";
        config = # lua
          ''
            local leap = require('leap')

            -- Sneak-style keybindings (recommended by upstream)
            vim.keymap.set({'n', 'x', 'o'}, 's',  '<Plug>(leap-forward)')
            vim.keymap.set({'n', 'x', 'o'}, 'S',  '<Plug>(leap-backward)')
            vim.keymap.set('n',             'gs', '<Plug>(leap-from-window)')

            -- Exclusive selection (operator-pending and visual)
            vim.keymap.set({'x', 'o'}, 'x', '<Plug>(leap-forward-till)')
            vim.keymap.set({'x', 'o'}, 'X', '<Plug>(leap-backward-till)')

            -- Preview filtering: reduce visual noise
            leap.opts.preview = function (ch0, ch1, ch2)
              return not (
                ch1:match('%s')
                or (ch0:match('%a') and ch1:match('%a') and ch2:match('%a'))
              )
            end

            -- Equivalence classes: group similar characters
            leap.opts.equivalence_classes = {
              ' \t\r\n', '([{', ')]}', '\'"`'
            }
          '';
      }

      # Surround text objects with brackets, quotes, etc.
      # https://github.com/kylechui/nvim-surround
      # Keybindings:
      #   ys{motion}{char} - Add surrounding (e.g., ysiw" surrounds word with quotes)
      #   ds{char}         - Delete surrounding (e.g., ds" removes quotes)
      #   cs{old}{new}     - Change surrounding (e.g., cs"' changes " to ')
      #   yss{char}        - Surround entire line
      # Examples:
      #   ysiw)   - Surround word with parentheses: word -> (word)
      #   ysiw(   - Surround with spacing: word -> ( word )
      #   ds"     - Delete quotes: "text" -> text
      #   cs"'    - Change quotes: "text" -> 'text'
      #   dsf     - Delete function call: func(text) -> text
      #   yssb    - Surround line with brackets
      {
        plugin = nvim-surround;
        type = "lua";
        config = # lua
          ''
            require('nvim-surround').setup({
              -- Use default keybindings (ys, ds, cs)
            })
          '';
      }

      # Auto-close brackets, quotes, and other pairs
      # https://github.com/windwp/nvim-autopairs
      # Features:
      #   - Automatically closes brackets, quotes, etc.
      #   - Treesitter integration for smart pairing
      #   - Works in insert mode
      # Behavior:
      #   Type '(' -> automatically adds ')'
      #   Type '{' + Enter -> adds closing brace with proper indentation
      #   Type '"' -> automatically adds closing quote
      {
        plugin = nvim-autopairs;
        type = "lua";
        config = # lua
          ''
            require('nvim-autopairs').setup({
              check_ts = true,  -- Enable treesitter integration
              ts_config = {
                lua = {'string'},         -- Don't add pairs in lua string treesitter nodes
                javascript = {'template_string'},  -- Don't add pairs in JS template strings
                java = false,             -- Don't check treesitter on java
              },
              -- Disable for certain filetypes
              disable_filetype = { "TelescopePrompt", "vim" },
            })

            -- Integration with blink.cmp (completion framework)
            -- Auto-insert closing pair on completion confirm
            local cmp_autopairs = require('nvim-autopairs.completion.cmp')
            local cmp = require('blink.cmp')
            -- Note: This uses the nvim-cmp compatible event
            -- blink.cmp may require different integration approach
            pcall(function()
              cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
            end)
          '';
      }

      # Highlight and search for TODO/FIXME/NOTE comments
      # https://github.com/folke/todo-comments.nvim
      # Keywords recognized:
      #   TODO:  - Things to do
      #   FIXME: - Things to fix
      #   HACK:  - Temporary workarounds
      #   WARN:  - Warnings
      #   PERF:  - Performance issues
      #   NOTE:  - Important notes
      #   TEST:  - Testing related
      # Keybindings:
      #   ]t - Jump to next TODO comment
      #   [t - Jump to previous TODO comment
      #   <leader>ft - Search all TODO comments with Telescope
      {
        plugin = todo-comments-nvim;
        type = "lua";
        config = # lua
          ''
            require('todo-comments').setup({
              signs = true,  -- Show signs in sign column
              keywords = {
                FIX = {
                  icon = " ",
                  color = "error",
                  alt = { "FIXME", "BUG", "FIXIT", "ISSUE" },
                },
                TODO = {
                  icon = " ",
                  color = "info",
                },
                HACK = {
                  icon = " ",
                  color = "warning",
                },
                WARN = {
                  icon = " ",
                  color = "warning",
                  alt = { "WARNING", "XXX" },
                },
                PERF = {
                  icon = " ",
                  color = "default",
                  alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" },
                },
                NOTE = {
                  icon = " ",
                  color = "hint",
                  alt = { "INFO" },
                },
                TEST = {
                  icon = "⏲ ",
                  color = "test",
                  alt = { "TESTING", "PASSED", "FAILED" },
                },
              },
            })

            -- Keybindings for navigation
            vim.keymap.set("n", "]t", function()
              require("todo-comments").jump_next()
            end, { desc = "Next todo comment" })

            vim.keymap.set("n", "[t", function()
              require("todo-comments").jump_prev()
            end, { desc = "Previous todo comment" })

            -- Telescope integration
            require("which-key").add({
              { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Find TODOs" },
            })
          '';
      }

      # Collection of 40+ small QoL plugins
      # https://github.com/folke/snacks.nvim
      #
      # FEATURES ENABLED:
      #   bigfile - Disable heavy features for large files (better performance)
      #   indent - Visual indent guides with scope detection (replaces indent-blankline)
      #   quickfile - Faster file opening by deferring expensive operations
      #   scroll - Smooth scrolling animations
      #   statuscolumn - Enhanced gutter/sign column (replaces statuscol-nvim)
      #   words - LSP reference highlighting under cursor (like vim-illuminate)
      #
      # FEATURES NOT ENABLED (with reasons):
      #   notifier - Using nvim-notify instead (required by noice.nvim)
      #   dashboard - Using alpha-nvim instead (custom Flox logo with gradients)
      #   lazygit - Available but configured separately when needed
      #   picker - Using telescope-nvim instead (more plugins, better ecosystem)
      #   bufdelete - Native buffer deletion sufficient for now
      #
      # Keybindings:
      #   <leader>tt - Toggle terminal (snacks.terminal)
      #   <leader>tT - Toggle all terminals
      #   <leader>zz - Zen mode (snacks.zen)
      {
        plugin = snacks-nvim;
        type = "lua";
        config = # lua
          ''
            -- Define Flox gradient colors (yellow to pink)
            local colors = {
              { name = "FloxGrad0", fg = "#ffd43c" },
              { name = "FloxGrad1", fg = "#feca4c" },
              { name = "FloxGrad2", fg = "#fec05c" },
              { name = "FloxGrad3", fg = "#fdb66d" },
              { name = "FloxGrad4", fg = "#fcac7d" },
              { name = "FloxGrad5", fg = "#fca28d" },
              { name = "FloxGrad6", fg = "#fb989d" },
              { name = "FloxGrad7", fg = "#fa8eae" },
              { name = "FloxGrad8", fg = "#fa84be" },
              { name = "FloxGrad9", fg = "#f97ace" },
            }

            for _, color in ipairs(colors) do
              vim.api.nvim_set_hl(0, color.name, { fg = color.fg })
            end

            require('snacks').setup({
              bigfile = { enabled = true },
              dashboard = {
                enabled = true,
                sections = {
                  {
                    text = {
                      { "         ███████████████████████\n", hl = "FloxGrad9" },
                      { "      ██████████████████████████\n", hl = "FloxGrad8" },
                      { "   █████████████████████████████\n", hl = "FloxGrad7" },
                      { "████████████████████████████████\n", hl = "FloxGrad7" },
                      { "█████████████████████████████   \n", hl = "FloxGrad6" },
                      { "███████████████████████         \n", hl = "FloxGrad6" },
                      { "█████████████████               \n", hl = "FloxGrad5" },
                      { "███████████                     \n", hl = "FloxGrad5" },
                      { "           █████████████████████\n", hl = "FloxGrad4" },
                      { "           █████████████████████\n", hl = "FloxGrad4" },
                      { "           █████████████████████\n", hl = "FloxGrad3" },
                      { "           █████████████████████\n", hl = "FloxGrad3" },
                      { "███████████                     \n", hl = "FloxGrad2" },
                      { "███████████                     \n", hl = "FloxGrad2" },
                      { "███████████                     \n", hl = "FloxGrad1" },
                      { "███████████                     \n", hl = "FloxGrad0" },
                    },
                    align = "center",
                    padding = 1,
                  },
                  { section = "keys", gap = 1, padding = 1 },
                  { section = "recent_files", cwd = true, icon = " ", title = "Recent Files", padding = 1 },
                },
              },
              indent = { enabled = true },
              notifier = { enabled = false },  -- Use nvim-notify (noice dependency)
              quickfile = { enabled = true },
              scroll = { enabled = true },
              statuscolumn = { enabled = true },
              terminal = { enabled = true },  -- Replaces toggleterm-nvim
              words = { enabled = true },
              zen = { enabled = true },  -- Replaces zen-mode.nvim
            })

            -- Hide fold column on dashboard
            vim.api.nvim_create_autocmd("FileType", {
              pattern = "snacks_dashboard",
              callback = function()
                vim.opt_local.foldcolumn = "0"
              end,
            })

            -- Keybindings for snacks features
            require("which-key").add({
              { "<leader>z",  group = "Zen Mode" },
              { "<leader>zz", function() Snacks.zen.zen() end, desc = "Toggle Zen Mode" },
              { "<leader>t",  group = "Terminal" },
              { "<leader>tt", function() Snacks.terminal.toggle() end, desc = "Toggle Terminal" },
              { "<leader>tT", function() Snacks.terminal.toggle() end, desc = "Toggle All Terminals" },
            })
          '';
      }

      # Code outline window for navigation
      # https://github.com/stevearc/aerial.nvim
      # Features:
      #   - Hierarchical view of code symbols (functions, classes, methods)
      #   - Works with Treesitter, LSP, and markdown
      #   - Navigate between symbols with { and }
      #   - Toggle outline with <leader>o
      # Keybindings in outline window:
      #   <CR> - Jump to symbol
      #   o/za - Toggle tree node
      #   zR - Open all nodes
      #   zM - Close all nodes
      #   q - Close window
      {
        plugin = aerial-nvim;
        type = "lua";
        config = # lua
          ''
            require('aerial').setup({
              backends = { "treesitter", "lsp", "markdown" },
              layout = {
                max_width = { 40, 0.2 },
                default_direction = "prefer_right",
                placement = "window",
              },
              -- Auto-attach keybindings on supported buffers
              on_attach = function(bufnr)
                vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr, desc = "Previous symbol" })
                vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr, desc = "Next symbol" })
              end,
            })

            -- Toggle aerial with leader key
            require("which-key").add({
              { "<leader>o", "<cmd>AerialToggle!<CR>", desc = "Toggle Code Outline" },
            })
          '';
      }

      # Automatic detection of indentation settings
      # https://github.com/tpope/vim-sleuth
      # Features:
      #   - Auto-detects tabs vs spaces from existing file content
      #   - Detects indent size (2, 4, 8 spaces)
      #   - Sets shiftwidth, expandtab, tabstop automatically
      #   - Works silently in the background
      # No configuration needed - works automatically on file open
      vim-sleuth

      # Task runner and job management
      # https://github.com/stevearc/overseer.nvim
      # Overseer provides:
      #   - Task execution for make, npm, cargo, VS Code tasks
      #   - Real-time task output monitoring
      #   - Integration with diagnostics and quickfix
      #   - Persistent task history
      # Custom telescope integration (no built-in support):
      #   - Browse running/completed tasks with fuzzy search
      #   - View task status in picker
      #   - Quick access to task details
      {
        plugin = overseer-nvim;
        type = "lua";
        config = # lua
          ''
            require('overseer').setup({
              -- Task list window configuration
              task_list = {
                default_detail = 1,        -- Show basic task details
                direction = "bottom",      -- Open at bottom of screen
                min_height = 10,           -- Minimum 10 lines
                max_height = 0.3,          -- Maximum 30% of screen height
              },
              -- Built-in task detection for:
              --   - Makefile targets
              --   - package.json scripts
              --   - Cargo.toml tasks
              --   - VS Code tasks.json
              templates = { "builtin" },
              -- Disable DAP integration (we don't use nvim-dap)
              dap = false,
            })

            -- Custom telescope picker for overseer tasks
            -- Overseer doesn't have built-in telescope support, so we create our own
            -- This provides fuzzy searching through all tasks (running, completed, failed)
            local function telescope_overseer()
              local pickers = require("telescope.pickers")
              local finders = require("telescope.finders")
              local conf = require("telescope.config").values
              local actions = require("telescope.actions")
              local action_state = require("telescope.actions.state")

              pickers.new({}, {
                prompt_title = "Overseer Tasks",
                -- Use dynamic finder to always get fresh task list
                finder = finders.new_dynamic({
                  fn = function()
                    local overseer = require("overseer")
                    -- Get all tasks (no filter)
                    local task_list = overseer.list_tasks({})
                    local results = {}

                    -- Transform task objects into picker entries
                    for _, task in ipairs(task_list) do
                      table.insert(results, {
                        name = task.name,
                        status = task.status,  -- e.g., "RUNNING", "SUCCESS", "FAILURE"
                        task = task,           -- Store full task object for actions
                      })
                    end

                    return results
                  end,
                  -- Format each task for display in telescope
                  entry_maker = function(entry)
                    return {
                      value = entry.task,
                      -- Display format: "task_name [STATUS]"
                      display = entry.name .. " [" .. entry.status .. "]",
                      ordinal = entry.name,  -- Used for fuzzy matching
                    }
                  end,
                }),
                sorter = conf.generic_sorter({}),
                -- Define what happens when user selects a task
                attach_mappings = function(prompt_bufnr, map)
                  actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    if selection then
                      -- Open the selected task (shows output, logs, etc.)
                      require("overseer").run_action(selection.value, "open")
                    end
                  end)
                  return true
                end,
              }):find()
            end

            -- Keybindings for overseer
            require("which-key").add({
              { "<leader>oo", "<cmd>OverseerToggle<CR>", desc = "Toggle Task List" },
              { "<leader>or", "<cmd>OverseerRun<CR>", desc = "Run Task" },
              { "<leader>oa", "<cmd>OverseerTaskAction<CR>", desc = "Task Actions" },
              -- Custom telescope integration for browsing tasks
              { "<leader>ot", telescope_overseer, desc = "Browse Tasks (Telescope)" },
            })
          '';
      }

      # Enhanced markdown rendering in Neovim
      # https://github.com/MeanderingProgrammer/render-markdown.nvim
      # Provides:
      #   - Beautiful heading icons and highlighting
      #   - Code block language icons and backgrounds
      #   - Table rendering with borders
      #   - Checkbox rendering with custom icons
      #   - LaTeX formula rendering
      #   - Callout/blockquote icons
      # Dependencies:
      #   - Treesitter: markdown, markdown_inline (already installed)
      #   - Optional: html, latex, yaml parsers
      #   - Nerd font for icons (we have this)
      {
        plugin = render-markdown-nvim;
        type = "lua";
        config = # lua
          ''
            require('render-markdown').setup({
              -- Enable rendering by default
              enabled = true,
              -- Maximum file size to render (in MB) to avoid performance issues
              max_file_size = 1.5,
              -- Render in normal mode (not just when cursor is elsewhere)
              render_modes = { 'n', 'c' },
              -- Heading configuration
              heading = {
                -- Enable heading rendering
                enabled = true,
                -- Icons for each heading level (h1-h6)
                icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
                -- Heading colors match level
                backgrounds = { 'DiffAdd', 'DiffChange', 'DiffDelete' },
              },
              -- Code block configuration
              code = {
                -- Enable code block rendering
                enabled = true,
                -- Show language icon and name
                sign = true,
                -- Style: 'full' (background), 'normal' (no background), 'language' (icon only)
                style = 'full',
                -- Left padding for code blocks
                left_pad = 2,
                right_pad = 2,
              },
              -- Bullet list configuration
              bullet = {
                enabled = true,
                -- Custom icons for different list levels
                icons = { '●', '○', '◆', '◇' },
              },
              -- Checkbox configuration
              checkbox = {
                enabled = true,
                -- Icons for unchecked, checked, and custom states
                unchecked = { icon = '󰄱 ' },
                checked = { icon = '󰱒 ' },
              },
              -- Link configuration (v8.0+ API)
              link = {
                -- Image link icon
                image = '󰥶 ',
                -- Email autolink icon
                email = '󰀓 ',
                -- Hyperlink icon (for inline and URI autolinks)
                hyperlink = '󰌹 ',
                -- Highlight group for link icons
                highlight = 'RenderMarkdownLink',
              },
            })

            -- Toggle markdown rendering on/off
            require("which-key").add({
              { "<leader>tm", "<cmd>RenderMarkdown toggle<CR>", desc = "Toggle Markdown Rendering" },
            })
          '';
      }

      # 🍨 Soothing pastel theme fsor (Neo)vim
      # https://github.com/catppuccin/nvim
      {
        plugin = catppuccin-nvim;
        type = "lua";
        config = # lua
          ''
            require('catppuccin').setup({
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
      # Minimal icon provider plugin
      # https://github.com/echasnovski/mini.icons
      # Features: File type icons with Nerd Fonts, lighter alternative to nvim-web-devicons
      # Used by: Various plugins as icon source
      mini-icons

      # File type icons using Nerd Fonts
      # https://github.com/nvim-tree/nvim-web-devicons
      # Features: Comprehensive icon set for filetypes with colors
      # Dependency for: telescope, lualine, oil, and other UI plugins
      nvim-web-devicons

      # Indent guides provided by snacks.nvim (snacks.indent)
      # Removed indent-blankline-nvim to avoid duplication

      # Zen mode provided by snacks.nvim (snacks.zen)
      # Removed zen-mode.nvim - using snacks.zen instead

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

      # UI component library - popup/split/input components
      # https://github.com/MunifTanjim/nui.nvim
      # Features: Provides UI primitives (borders, layouts, input fields, menus)
      # Used by: noice.nvim and other modern UI plugins
      pkgs.vimPlugins.nui-nvim

      # Better UI for messages, cmdline and popups
      # https://github.com/folke/noice.nvim
      # Improvements:
      #   - Replaces default command line with better UI
      #   - Better LSP signature help and hover docs
      #   - Message history and search
      #   - Customizable notification display
      {
        plugin = noice-nvim;
        type = "lua";
        config = # lua
          ''
            require("noice").setup({
              lsp = {
                -- Override markdown rendering for LSP hover/signature
                override = {
                  ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                  ["vim.lsp.util.stylize_markdown"] = true,
                  ["cmp.entry.get_documentation"] = true,
                },
              },
              presets = {
                bottom_search = true,         -- Use classic bottom search
                command_palette = true,        -- Position cmdline and popupmenu together
                long_message_to_split = true,  -- Long messages -> split
                inc_rename = false,            -- Don't use inc-rename
                lsp_doc_border = false,        -- Don't add border to LSP docs
              },
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
            require('oil').setup({
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
      # Dashboard provided by snacks.nvim (snacks.dashboard)
      # Removed alpha-nvim - using snacks.dashboard instead
      # (Removed 114 lines of custom alpha config with Flox logo)

      # Syntax highlighting (via treesitter)
      # https://github.com/nvim-treesitter/nvim-treesitter
      {
        plugin = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
        type = "lua";
        config = # lua
          ''
            require('nvim-treesitter.configs').setup {
              highlight = {
                enable = true,
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
              -- Textobjects configuration (requires nvim-treesitter-textobjects)
              textobjects = {
                select = {
                  enable = true,
                  lookahead = true,  -- Automatically jump forward to textobj
                  keymaps = {
                    -- Functions
                    ["af"] = "@function.outer",
                    ["if"] = "@function.inner",
                    -- Classes
                    ["ac"] = "@class.outer",
                    ["ic"] = "@class.inner",
                    -- Parameters/arguments
                    ["aa"] = "@parameter.outer",
                    ["ia"] = "@parameter.inner",
                    -- Conditionals
                    ["ai"] = "@conditional.outer",
                    ["ii"] = "@conditional.inner",
                    -- Loops
                    ["al"] = "@loop.outer",
                    ["il"] = "@loop.inner",
                  },
                },
                move = {
                  enable = true,
                  set_jumps = true,  -- Add jumps to jumplist
                  goto_next_start = {
                    ["]m"] = "@function.outer",
                    ["]]"] = "@class.outer",
                  },
                  goto_next_end = {
                    ["]M"] = "@function.outer",
                    ["]["] = "@class.outer",
                  },
                  goto_previous_start = {
                    ["[m"] = "@function.outer",
                    ["[["] = "@class.outer",
                  },
                  goto_previous_end = {
                    ["[M"] = "@function.outer",
                    ["[]"] = "@class.outer",
                  },
                },
                swap = {
                  enable = true,
                  swap_next = {
                    ["<leader>a"] = "@parameter.inner",
                  },
                  swap_previous = {
                    ["<leader>A"] = "@parameter.inner",
                  },
                },
              },
            }

            -- Make treesitter textobject movements repeatable with ; and ,
            local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")
            vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
            vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)
          '';
      }

      # Syntax aware textobjects, select, move, swap
      # https://github.com/nvim-treesitter/nvim-treesitter-textobjects
      # Keybindings (configured in nvim-treesitter.configs above):
      # Selection:
      #   af/if - outer/inner function
      #   ac/ic - outer/inner class
      #   aa/ia - outer/inner argument/parameter
      #   ai/ii - outer/inner conditional
      #   al/il - outer/inner loop
      # Movement:
      #   ]m/[m - next/previous function start
      #   ]M/[M - next/previous function end
      #   ]]/[[ - next/previous class start
      #   ][/[] - next/previous class end
      #   ; - repeat last movement forward
      #   , - repeat last movement backward
      # Swap:
      #   <leader>a - swap parameter with next
      #   <leader>A - swap parameter with previous
      nvim-treesitter-textobjects

      # Navigation using Telescope
      # https://github.com/nvim-telescope/telescope.nvim/

      # C port of fzf sorter for telescope - significantly faster fuzzy finding
      # https://github.com/nvim-telescope/telescope-fzf-native.nvim
      # Features: FZF algorithm for better performance, case-sensitive/insensitive modes
      # Note: Automatically enabled in telescope config below
      telescope-fzf-native-nvim

      # File browser extension for telescope
      # https://github.com/nvim-telescope/telescope-file-browser.nvim
      # Keybinding: <leader>fF - Open file browser
      # Features: Browse/create/delete/rename files with fuzzy finding
      telescope-file-browser-nvim

      # GitHub integration for telescope (issues, PRs, gists)
      # https://github.com/nvim-telescope/telescope-github.nvim
      # Note: Keybindings currently disabled, planned to replace with octo.nvim
      telescope-github-nvim

      # Use telescope for all LSP handler windows (definitions, references, etc.)
      # https://github.com/gbrlsnchs/telescope-lsp-handlers.nvim
      # Features: Prettier LSP views with fuzzy search instead of quickfix/location list
      telescope-lsp-handlers-nvim
      {
        plugin = telescope-nvim;
        type = "lua";
        config = # lua
          ''
            local actions = require("telescope.actions")
            local actions_layout = require("telescope.actions.layout")
            require('telescope').setup {
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

              -- TODO: replace with octo
              --{ "<leader>gH", group = "GitHub" },
              --{ "<leader>gHg", "<cmd>Telescope gh gist<cr>", desc = "Gists" },
              --{ "<leader>gHi", "<cmd>Telescope gh issues<cr>", desc = "Issues" },
              --{ "<leader>gHp", "<cmd>Telescope gh pull_request<cr>", desc = "Pull Requests" },
              --{ "<leader>gHr", "<cmd>Telescope gh run<cr>", desc = "Workflow runs" },

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

      # -- AI -----------------------------------------------------------------

      # https://github.com/zbirenbaum/copilot.lua
      {
        plugin = copilot-lua;
        type = "lua";
        config = # lua
          ''
            require('copilot').setup({
              suggestion = { enabled = false },
              panel = { enabled = false },
              copilot_node_command = "${pkgs.nodejs}/bin/node", -- Node.js version must be > 18.x
            })
          '';
      }

      # Lua functions library - "All the lua functions I don't want to write twice"
      # https://github.com/nvim-lua/plenary.nvim
      # Features: Async functions, job control, path utilities, functional programming helpers
      # Used by: telescope, gitsigns, claude-code, and many other plugins
      plenary-nvim

      # Claude Code CLI integration - opens Claude Code in floating terminal
      # https://github.com/greggh/claude-code.nvim
      # Keybindings: <leader>ac (open Claude), <leader>at (toggle)
      # Features: 90% screen floating window, persistent terminal, quick AI access
      {
        plugin = claude-code-nvim;
        type = "lua";
        config = # lua
          ''
            require('claude-code').setup({
              -- Use floating window for Claude Code terminal
              window = {
                type = "float",
                width = 0.9,
                height = 0.9,
              },
            })

            require("which-key").add({
              { "<leader>a", group = "AI" },
              { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Claude Code" },
              { "<leader>at", "<cmd>ClaudeCodeToggle<cr>", desc = "Toggle Claude Code" },
            })
          '';
      }

      # -- SQL ----------------------------------------------------------------

      # Database interface - interact with databases from Neovim
      # https://github.com/tpope/vim-dadbod
      # Features: Supports PostgreSQL, MySQL, SQLite, MongoDB, Redis, and more
      # Usage: Used with vim-dadbod-ui for visual database explorer
      vim-dadbod

      # Database autocompletion for vim-dadbod
      # https://github.com/kristijanhusak/vim-dadbod-completion
      # Features: Table names, column names, SQL keywords
      # Integration: Connected to blink.cmp as 'dadbod' source (see blink.cmp config below)
      vim-dadbod-completion
      {
        plugin = vim-dadbod-ui;
        type = "lua";
        config = # lua
          ''
            -- Your DBUI configuration
            vim.g.db_ui_use_nerd_fonts = 1
            vim.g.db_ui_auto_execute_table_helpers = 1
          '';
      }

      # -- COMPLETION / SNIPPETS ----------------------------------------------

      # Collection of preconfigured snippets for 20+ languages
      # https://github.com/rafamadriz/friendly-snippets
      # Features: JS/TS, Python, Go, Rust, HTML, CSS, Markdown, and more
      # Integration: Used by blink.cmp snippet source
      friendly-snippets

      # Compatibility layer to use nvim-cmp sources with blink.cmp
      # https://github.com/saghen/blink.compat
      # Purpose: Bridges API differences between nvim-cmp and blink.cmp
      # Why needed: Allows using vim-dadbod-completion (nvim-cmp source) with blink.cmp
      {
        plugin = blink-compat;
        type = "lua";
        config = # lua
          ''
            require('blink-compat').setup()
          '';
      }

      # Copilot completion source for blink.cmp
      # https://github.com/giuxtaposition/blink-cmp-copilot
      # Features: GitHub Copilot AI suggestions in completion menu
      # Integration: Configured with high priority (score_offset 200) and custom icon
      blink-cmp-copilot
      # Performant, batteries-included completion plugin for Neovim
      # https://github.com/Saghen/blink.cmp
      {
        plugin = blink-cmp;
        type = "lua";
        config = # lua
          ''
            require('blink-cmp').setup({

              -- 'default' for mappings similar to built-in completion
              -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
              -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
              -- See the full "keymap" documentation for information on defining your own keymap.
              keymap = {
                preset = 'enter',
              },

              signature = {
                enabled = true,
              --   window = {
              --     border = 'single',
              --   }
              },

              -- Disable cmdline completions, I would need to adjust sources
              -- for cmdline since I'm missing history of commands
              cmdline = {
                enabled = false,
              },

              -- Default list of enabled providers defined so that you can extend it
              -- elsewhere in your config, without redefining it, due to `opts_extend`
              sources = {
                default = {
                  'lazydev',
                  'copilot',
                  -- 'avante_commands',
                  -- 'avante_mentions',
                  -- 'avante_files',
                  'lsp',
                  'snippets',
                  'path',
                  'buffer',
                },
                per_filetype = {
                  sql = { 'copilot', 'dadbod', 'buffer' },
                },
                providers = {
                  lazydev = {
                    name = "LazyDev",
                    module = "lazydev.integrations.blink",
                    score_offset = 100,
                  },
                  dadbod = {
                    name = "Dadbod",
                    module = "vim_dadbod_completion.blink",
                  },
                  -- avante_commands = {
                  --   name = "avante_commands",
                  --   module = "blink.compat.source",
                  --   score_offset = 90, -- show at a higher priority than lsp
                  --   opts = {},
                  -- },
                  -- avante_files = {
                  --   name = 'avante_commands',
                  --   module = 'blink.compat.source',
                  --   score_offset = 100, -- show at a higher priority than lsp
                  --   opts = {},
                  -- },
                  -- avante_mentions = {
                  --   name = 'avante_mentions',
                  --   module = 'blink-compat.source',
                  --   score_offset = 1000, -- show at a higher priority than lsp
                  --   opts = {},
                  -- },
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
                  -- border = 'single',
                  auto_show = true,
                  auto_show_delay_ms = 500,
                },
                ghost_text = { enabled = false },
                list = {
                  selection = {
                    preselect = true,
                    auto_insert = true,
                    -- function(ctx)
                    --   return ctx.mode == 'cmdline' and 'manual' or 'preselect'
                    -- end,
                    -- or a function
                    --preselect = function(ctx)
                    --  return ctx.mode ~= 'cmdline' and not require('blink.cmp').snippet_active({ direction = 1 })
                    --end,
                    -- auto_insert = function(ctx) return ctx.mode ~= 'cmdline' end,
                  },
                },
                menu = {
                  border = 'single',
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
            require('conform').setup({
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
            require('lazydev').setup({
              library = {
                -- See the configuration section for more details
                -- Load luvit types when the `vim.uv` word is found
                { path = "''${3 rd}/luv/library", words = { "vim%.uv" } },
              },
            })
          '';
      }

      # LSP progress notifications in corner
      # https://github.com/j-hui/fidget.nvim
      # Features:
      #   - Shows LSP progress in bottom-right corner
      #   - Animated spinner while LSP is working
      #   - Completion checkmark when done
      #   - Auto-hides after 3 seconds
      # No keybindings needed - works automatically with LSP
      {
        plugin = fidget-nvim;
        type = "lua";
        config = # lua
          ''
            require('fidget').setup({
              notification = {
                window = {
                  winblend = 0,      -- Transparency (0 = opaque)
                  border = "none",   -- No border
                },
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
            -- Tell the server the capability of foldingRange,
            -- Neovim hasn't added foldingRange to default capabilities, users must add it manually
            -- See https://github.com/kevinhwang91/nvim-ufo?tab=readme-ov-file#minimal-configuration
            capabilities.textDocument.foldingRange = {
                dynamicRegistration = false,
                lineFoldingOnly = true
            }

            -- Get enhanced capabilities from blink.cmp
            capabilities = require('blink.cmp').get_lsp_capabilities(capabilities)

            -- Setup LSP servers using vim.lsp.config (new API in Neovim 0.11+)
            local function setup_lsp(server_name, executable, cmd, custom_opts)
              if vim.fn.executable(executable) == 1 then
                -- Basic configuration with capabilities
                local config = vim.tbl_deep_extend('force', {
                  cmd = cmd,
                  root_markers = { '.git' },
                  capabilities = capabilities,
                }, custom_opts or {})

                -- Use vim.lsp.config to setup the server (new API)
                vim.lsp.config(server_name, config)
              end
            end

            -- Setup LSP servers
            local servers = {
              -- Web
              { name="ts_ls", executable="typescript-language-server", cmd={"typescript-language-server", "--stdio"}, opts={} },
              { name="html", executable="vscode-html-language-server", cmd={"vscode-html-language-server", "--stdio"}, opts={} },
              { name="htmx", executable="htmx-lsp", cmd={"htmx-lsp"}, opts={} },
              { name="cssls", executable="vscode-css-language-server", cmd={"vscode-css-language-server", "--stdio"}, opts={} },

              -- Config
              { name="nixd", executable="nixd", cmd={"nixd"}, opts={} },
              { name="jsonls", executable="vscode-json-language-server", cmd={"vscode-json-language-server", "--stdio"}, opts={} },
              { name="yamlls", executable="yaml-language-server", cmd={"yaml-language-server", "--stdio"}, opts={} },

              -- Languages
              { name="bashls", executable="bash-language-server", cmd={"bash-language-server", "start"}, opts={} },    -- Bash
              { name="gopls", executable="gopls", cmd={"gopls"}, opts={} },                    -- Go
              { name="ruff_lsp", executable="ruff", cmd={"ruff", "server"}, opts={} },                  -- Python
              { name="rust_analyzer", executable="rust-analyzer", cmd={"rust-analyzer"}, opts={} },    -- Rust
              { name="zls", executable="zls", cmd={"zls"}, opts={} },                        -- Zig

              -- Tools
              { name="dockerls", executable="docker-langserver", cmd={"docker-langserver", "--stdio"}, opts={} },              -- Docker
            }

            for _, server in ipairs(servers) do
              setup_lsp(server.name, server.executable, server.cmd, server.opts)
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

      # The fastest Neovim colorizer
      # https://github.com/catgoose/nvim-colorizer.lua
      {
        plugin = nvim-colorizer-lua;
        type = "lua";
        config = # lua
          ''
            require('colorizer').setup({
              filetypes = {
                "*", -- Highlight all files, but customize some others.
                css = { rgb_fn = true }, -- Enable parsing rgb(...) functions in css.
                html = { names = false }, -- Disable parsing "names" like Blue or Gray
              },
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
            require('gitsigns').setup({
              numhl      = true,
              -- TODO: problems with colors
              --word_diff  = true,
              --diff_opts = {
              --  internal = true,
              --},
              current_line_blame = true,
            })

            require("which-key").add({
              { "<leader>g", group = "Git" },
              { "<leader>gb", "<cmd>Gitsigns blame<cr>", desc = "Blame" },
              { "<leader>gn", "<cmd>Gitsigns next_hunk<cr>", desc = "Next hunk" },
              { "<leader>gp", "<cmd>Gitsigns prev_hunk<cr>", desc = "Previous hunk" },
              { "<leader>gh", "<cmd>Gitsigns preview_hunk<cr>", desc = "Previous hunk" },
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
              lualine_b = {'diff', 'diagnostics'},
              lualine_c = {'filename'},
              lualine_x = {'encoding', 'fileformat', 'filetype'},
              lualine_y = {'progress'},
              lualine_z = {'location'}
            }
            require('lualine').setup({
              sections = {},
              inactive_sections = {},
              winbar = winbar,
              inactive_winbar = winbar,
              options = {
                theme = "catppuccin",
                disabled_filetypes = {
                  'alpha',
                },
              },
              extensions = { 'oil' },
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

      # Status column provided by snacks.nvim (snacks.statuscolumn)
      # Removed statuscol-nvim to avoid duplication

      # Not UFO in the sky, but an ultra fold in Neovim.
      # https://github.com/kevinhwang91/nvim-ufo
      {
        plugin = nvim-ufo;
        type = "lua";
        config = # lua
          ''
            vim.o.foldenable     = true     -- enable fold
            vim.o.foldcolumn     = '1'      -- show fold column
            vim.o.foldlevel      = 99       -- minimum level of a fold that will be closed by default
            vim.o.foldlevelstart = 99       -- top level folds are open, but anything nested beyond that is closed

            -- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1,
            -- remap yourself
            vim.keymap.set('n', 'zR', require('ufo').openAllFolds, { desc = "Open all folds" })
            vim.keymap.set('n', 'zM', require('ufo').closeAllFolds, { desc = "Close all folds" })
            vim.keymap.set('n', 'zk', function()
                local winid = require('ufo').peekFoldedLinesUnderCursor()
                if not winid then
                  vim.lsp.buf.hover()
                end
              end, { desc = "Peek fold" })

            require('ufo').setup()
          '';
      }
    ];

}
