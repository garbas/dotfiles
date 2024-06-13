{ sshKey
, username
, email
, fullname
}:
{ pkgs, lib, config, ... }: let
  asLua = t: ''
    lua << EOF
    ${t}
    EOF
  '';
in {

  home.username = username;
  home.stateVersion = "22.11";

  home.sessionVariables.EDITOR = "nvim";
  home.sessionVariables.GIT_EDITOR = "nvim";
  home.sessionVariables.FZF_DEFAULT_COMMAND = "rg --files";

  home.shellAliases.grep = "rg";
  home.shellAliases.find = "fd";
  home.shellAliases.ps = "procs";
  home.shellAliases.cat = "bat";

  home.packages = with pkgs; [
    entr
    fd
    coreutils
    gnutar
    file
    htop
    jq
    kitty.terminfo
    ripgrep
    procs
    tig
    tmate
    tree
    unzip
    wget
    which
  ];

  nixpkgs.config.allowBroken = false;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreeRedistributable = true;

  programs.bat.enable = true;

  programs.direnv.enable = true;
  programs.direnv.enableZshIntegration = true;
  programs.direnv.nix-direnv.enable = true;

  programs.eza.enable = true;
  programs.eza.enableAliases = true;

  programs.fzf.enable = true;
  programs.fzf.enableZshIntegration = true;
  programs.fzf.tmux.enableShellIntegration = true;

  programs.gh.enable = true;
  programs.gh.settings.git_protocol = "ssh";
  programs.gh.settings.editor = "nvim";
  programs.gh.settings.prompt = "enabled";
  programs.gh.settings.aliases.co = "pr checkout";
  programs.gh.settings.aliases.v = "pr view";
  programs.gh.settings.extensions = with pkgs; [
    #gh-poi               # Safely cleanup local branches
    #gh-markdown-preview  # README preview
    gh-dash              # Dashboard of PRs and Issues
    #gh-label             # Label management
    #gh-milestone         # Milestone management
    #gh-notify            # Display notifications
    #gh-changelog         # Create changelogs (https://keepachangelog.com)
    #gh-s                 # Search Github repositories
  ];


  xdg.configFile."git/config-me".text = ''
    [user]
      name = ${fullname}
      email = ${email}
  '';
  xdg.configFile."git/config-flox".text = ''
    [user]
      name = ${fullname}
      email = rok@floxdev.com
  '';
  programs.git.includes = [
    {
      path = "~/.config/git/config-me";
      condition = "hasconfig:remote.*.url:git@github.com\:garbas/**";
    }
    {
      path = "~/.config/git/config-flox";
      condition = "hasconfig:remote.*.url:git@github.com\:flox/**";
    }
    {
      path = "~/.config/git/config-flox";
      condition = "hasconfig:remote.*.url:git@github.com\:flox-examples/**";
    }

  ];

  programs.git.enable = true;
  programs.git.package = pkgs.gitAndTools.gitFull;
  programs.git.aliases.s = "status";
  programs.git.aliases.d = "diff";
  programs.git.aliases.ci = "commit -v";
  programs.git.aliases.cia = "commit -v -a";
  programs.git.aliases.co = "checkout";
  programs.git.aliases.l = "log --graph --oneline --decorate --all";
  programs.git.aliases.b = "branch";
  # list branches sorted by last modified
  programs.git.aliases.bb = "!git for-each-ref --sort='-authordate' --format='%(authordate)%09%(objectname:short)%09%(refname)' refs/heads | sed -e 's-refs/heads/--'";
  programs.git.aliases.entr = "!git ls-files -cdmo --exclude-standard | entr -d";
  programs.git.lfs.enable = true;
  programs.git.delta.enable = true;
  programs.git.extraConfig = {
    gpg.format = "ssh";
    user.signingKey = sshKey;
    commit.gpgsign = true;
    tag.gpgsign = true;
    status.submodulesummary = true;
    push.default = "simple";
    push.autoSetupRemote = true;
    init.defaultBranch = "main";
  };

  programs.htop.enable = true;

  programs.jq.enable = true;

  programs.keychain.enable = true;
  programs.keychain.enableZshIntegration = true;
  programs.keychain.agents = ["ssh"];
  programs.keychain.extraFlags = [
    "--quiet"
    "--nogui"
    "--quick"
  ];
  programs.keychain.keys = ["id_ed25519"];

  programs.less.enable = true;

  programs.man.enable = true;

  #programs.nix-index.enable = true;
  #programs.nix-index.enableZshIntegration = true;

  programs.neovim.enable = true;
  programs.neovim.viAlias = true;
  programs.neovim.vimAlias = true;
  programs.neovim.vimdiffAlias = true;
  programs.neovim.withNodeJs = true;
  programs.neovim.withPython3 = true;
  programs.neovim.withRuby = true;
  programs.neovim.extraConfig = ''
    " Use <Space> as the leader key
    let mapleader=" "

    " Allows you to change buffers even if the current on has unsaved changes
    set hidden

    " Intuit the indentation of new lines when creating them
    set smartindent

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
  '';
  programs.neovim.plugins = with pkgs.vimPlugins; [
    # Intelligently reopen files at your last edit position.
    # https://github.com/farmergreg/vim-lastplace
    { plugin = vim-lastplace;
      config = ''
        let g:lastplace_ignore = "gitcommit,gitrebase,svn,hgcommit"
        let g:lastplace_ignore_buftype = "quickfix,nofile,help"
      '';
    }
    # Nord-ish color theme
    { plugin = nordic-nvim;
      config = asLua ''
        require('nordic').colorscheme({
          -- Underline style used for spelling
          -- Options: 'none', 'underline', 'undercurl'
          underline_option = 'none',

          -- Italics for certain keywords such as constructors, functions,
          -- labels and namespaces
          italic = true,

          -- Italic styled comments
          italic_comments = true,

          -- Minimal mode: different choice of colors for Tabs and StatusLine
          minimal_mode = false,

          -- Darker backgrounds for certain sidebars, popups, etc.
          -- Options: true, false, or a table of explicit names
          -- Supported: terminal, qf, vista_kind, packer, nvim-tree, telescope, whichkey
          alternate_backgrounds = true,

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
      config = asLua ''
        require("alpha").setup(require"alpha.themes.startify".config)
      '';
    }
    # Displays a popup with possible keybindings of the command you
    # started typing.
    # https://github.com/folke/which-key.nvim
    { plugin = which-key-nvim;
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
      config = asLua ''
        require'nvim-treesitter.configs'.setup {
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
          },
        }

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
    # AI
    { plugin = copilot-lua;
      config = asLua ''
        require("copilot").setup({
          suggestion = { enabled = false },
          panel = { enabled = false },
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
      config = asLua ''
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
      config = asLua ''
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
          "astro",
          "bashls",
          "beancount",
          "ccls",
          "cssls",
          "elmls",
          "html",
          "jsonls",
          "nickel_ls",
          "pyright",
          "rls",
          "rust_analyzer",
          "rnix",
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
        wk.register({
          l = {
            name = "LSP",
            l = { "<cmd>lua vim.lsp.buf.hover()<cr>"                  , "Hover" },
            f = { "<cmd>lua vim.lsp.buf.formatting()<cr>"             , "Format" },
            --r = { "<cmd>lua vim.lsp.buf.references()<cr>"             , "References" },
            r = { "<cmd>Telescope lsp_references<cr>"                 , "References" },
            R = { "<cmd>lua vim.lsp.buf.rename()<cr>"                 , "Rename" },
            --s = { "<cmd>lua vim.lsp.buf.signature_help()<cr>"         , "Singnature help" },
            s = { "<cmd>Telescope lsp_document_symbols<cr>"           , "Document symbols" },
            S = { "<cmd>Telescope lsp_workspace_symbols<cr>"          , "Workspace symbols" },
            y = { "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>"  , "Workspace symbols" },
            --d = { "<cmd>lua vim.lsp.buf.definition()<cr>"             , "Definition" },
            d = { "<cmd>Telescope lsp_definitions<cr>"                , "Definitions" },
            D = { "<cmd>lua vim.lsp.buf.declaration()<cr>"            , "Declaration" },
            --t = { "<cmd>lua vim.lsp.buf.type_definition()<cr>"        , "Type definition" },
            t = { "<cmd>Telescope lsp_type_definitions<cr>"           , "Type definition" },
            --I = { "<cmd>lua vim.lsp.buf.implementation()<cr>"         , "Implementation" },
            I = { "<cmd>Telescope lsp_implementations<cr>"            , "Implementation" },
            i = { "<cmd>Telescope lsp_incoming_calls<cr>"             , "Incoming calls" },
            o = { "<cmd>Telescope lsp_outgoing_calls<cr>"             , "Outgoing calls" },
            Y = { "<cmd>Telescope diagnostics<cr>"                    , "Diagnostics" },

          },
        }, { prefix = "<leader>" })
      '';
    }
  ];

  programs.ssh.enable = true;
  programs.ssh.controlMaster = "auto";
  programs.ssh.controlPath = "~/.ssh/%r@%h:%p";
  programs.ssh.controlPersist = "60m";
  programs.ssh.serverAliveInterval = 120;
  programs.ssh.extraConfig = ''
    TCPKeepAlive yes
    HostKeyAlgorithms ssh-ed25519-cert-v01@openssh.com,ssh-rsa-cert-v01@openssh.com,ssh-ed25519,ssh-rsa,ecdsa-sha2-nistp256-cert-v01@openssh.com,ecdsa-sha2-nistp521-cert-v01@openssh.com,ecdsa-sha2-nistp384-cert-v01@openssh.com,ecdsa-sha2-nistp521,ecdsa-sha2-nistp384,ecdsa-sha2-nistp256
  '';

  programs.tmux.enable = true;
  programs.tmux.clock24 = true;
  programs.tmux.keyMode = "vi";
  programs.tmux.historyLimit = 10000;
  programs.tmux.prefix = "C-Space";
  programs.tmux.shortcut = "Space";
  programs.tmux.baseIndex = 1;
  programs.tmux.plugins = with pkgs.tmuxPlugins; [
    nord
    tmux-fzf
  ];
  programs.tmux.extraConfig = ''
    set-option -g set-clipboard on

    # allow terminal scrolling
    set-option -g terminal-overrides 'xterm*:smcup@:rmcup@'

    # easier to remember split pane command
    bind | split-window -h
    bind - split-window -v
    unbind '"'
    unbind %

    # allow to use mouse
    set -g mouse on

    # panes
    set -g pane-border-style fg=black
    set -g pane-active-border-style fg=brightred

    # moving between panes vim style
    bind h select-pane -L
    bind j select-pane -D
    bind k select-pane -U
    bind l select-pane -R

    # resize the pane
    bind-key -r H resize-pane -L 3
    bind-key -r J resize-pane -D 3
    bind-key -r K resize-pane -U 3
    bind-key -r L resize-pane -R 3

  '';

  programs.zoxide.enable = true;
  programs.zoxide.enableZshIntegration = true;

  programs.zsh.enable = true;
  programs.zsh.enableAutosuggestions = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.syntaxHighlighting.enable = true;
  programs.zsh.autocd = true;
  programs.zsh.defaultKeymap = "viins";
  programs.zsh.history.expireDuplicatesFirst = true;
  programs.zsh.initExtraBeforeCompInit = ''
    # for Docker Labs Debug Tools
    fpath=(~/.local/share/zsh/functions $fpath)
  '';
  programs.zsh.initExtra = ''
    # for Docker Labs Debug Tools
    export PATH="$PATH:/Users/${username}/.local/bin"
  '';
  programs.zsh.plugins = [
    {
      file = "powerlevel10k.zsh-theme";
      name = "powerlevel10k";
      src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k";
    }
    {
      file = "p10k.zsh";
      name = "powerlevel10k-config";
      src = "${./.}";
    }
  ];
}
