#!/usr/bin/env bats
# Neovim Configuration Test Suite
# Uses BATS (Bash Automated Testing System) for structured testing
# Run this after any Neovim configuration changes

# Setup function runs before each test
setup() {
  # CI Debug Info (only print once)
  if [ -n "$CI" ] && [ "${BATS_TEST_NUMBER}" -eq 1 ]; then
    echo "# 📍 CI Debug Information:" >&3
    echo "#   nvim location: $(which nvim || echo 'NOT FOUND')" >&3
    echo "#   nvim version: $(nvim --version 2>&1 | head -n 1 || echo 'FAILED')" >&3
    echo "#   PATH: $PATH" >&3
    echo "" >&3
  fi
}

# Helper function to test plugin loading
# Usage: test_plugin_loads "lua-require-path"
test_plugin_loads() {
  local require_path="$1"
  local output_file=$(mktemp)

  # Try to load the plugin
  nvim --headless -c "lua require('${require_path}')" -c 'quitall' > "$output_file" 2>&1
  local exit_code=$?

  # Check for errors in output
  if [ $exit_code -ne 0 ] || grep -qi "error" "$output_file"; then
    cat "$output_file" >&2
    rm -f "$output_file"
    return 1
  fi

  # Warn about deprecations but don't fail
  if grep -qi "deprecated" "$output_file"; then
    echo "# WARNING: Deprecated API usage detected" >&3
    cat "$output_file" >&3
  fi

  rm -f "$output_file"
  return 0
}

@test "neovim starts without errors" {
  run nvim --headless -c 'quitall'
  [ "$status" -eq 0 ]
  ! echo "$output" | grep -qi "error"
}

@test "neovim version is available" {
  run nvim --version
  [ "$status" -eq 0 ]
  [[ "$output" =~ "NVIM v" ]]
}

@test "leap.nvim loads" {
  test_plugin_loads "leap"
}

@test "blink.cmp loads" {
  test_plugin_loads "blink.cmp"
}

@test "telescope.nvim loads" {
  test_plugin_loads "telescope"
}

@test "nvim-treesitter loads" {
  test_plugin_loads "nvim-treesitter"
}

# TODO: Re-enable when nixpkgs updates textobjects for treesitter main branch
# See: https://github.com/NixOS/nixpkgs/issues/415438
@test "nvim-treesitter-textobjects loads" {
  skip "textobjects temporarily disabled - incompatible with treesitter main branch"
}

@test "copilot.lua loads" {
  test_plugin_loads "copilot"
}

@test "claude-code.nvim loads" {
  test_plugin_loads "claude-code"
}

@test "nui.nvim is present (library plugin)" {
  # nui is a library plugin, not directly loadable via require()
  # It will be verified through noice.nvim which depends on it
  skip "nui.nvim is a library plugin, tested via noice.nvim"
}

@test "noice.nvim loads" {
  test_plugin_loads "noice"
}

@test "nvim-surround loads" {
  test_plugin_loads "nvim-surround"
}

@test "nvim-autopairs loads" {
  test_plugin_loads "nvim-autopairs"
}

@test "todo-comments.nvim loads" {
  test_plugin_loads "todo-comments"
}

@test "snacks.nvim loads" {
  test_plugin_loads "snacks"
}

@test "aerial.nvim loads" {
  test_plugin_loads "aerial"
}

@test "fidget.nvim loads" {
  test_plugin_loads "fidget"
}

@test "overseer.nvim loads" {
  test_plugin_loads "overseer"
}

@test "render-markdown.nvim loads" {
  test_plugin_loads "render-markdown"
}

@test "vim-lastplace loads" {
  # vim-lastplace is a pure vimscript plugin with no commands, lua modules, or reliable guard variable
  # It's an autoload plugin that only loads when opening files
  # The plugin is installed via Nix and present in the pack directory - just skip the test
  skip "vim-lastplace is an autoload plugin with no testable interface"
}

@test "better-escape.nvim loads" {
  test_plugin_loads "better_escape"
}

@test "smart-splits.nvim loads" {
  test_plugin_loads "smart-splits"
}

@test "lazydev.nvim loads" {
  test_plugin_loads "lazydev"
}

@test "nvim-colorizer.lua loads" {
  test_plugin_loads "colorizer"
}

@test "catppuccin-nvim loads" {
  test_plugin_loads "catppuccin"
}

@test "which-key.nvim loads" {
  test_plugin_loads "which-key"
}

@test "lualine.nvim loads" {
  test_plugin_loads "lualine"
}

@test "nvim-notify loads" {
  test_plugin_loads "notify"
}

@test "oil.nvim loads" {
  test_plugin_loads "oil"
}

@test "gitsigns.nvim loads" {
  test_plugin_loads "gitsigns"
}

@test "conform.nvim loads" {
  test_plugin_loads "conform"
}

@test "nvim-ufo loads" {
  test_plugin_loads "ufo"
}

@test "vim-dadbod loads" {
  # vim-dadbod is a pure vimscript plugin, check for its command
  run nvim --headless -c 'if exists(":DB") | echo "OK" | else | cquit! | endif' -c 'quitall'
  [ "$status" -eq 0 ]
}

@test "vim-dadbod-ui loads" {
  # Check for DBUI command from vim-dadbod-ui
  run nvim --headless -c 'if exists(":DBUI") | echo "OK" | else | cquit! | endif' -c 'quitall'
  [ "$status" -eq 0 ]
}

@test "vim-sleuth loads" {
  # vim-sleuth is a pure vimscript plugin with no commands, just check it doesn't error
  run nvim --headless -c 'if exists("g:loaded_sleuth") | echo "OK" | else | cquit! | endif' -c 'quitall'
  [ "$status" -eq 0 ]
}

@test "lsp configuration is valid" {
  run nvim --headless -c 'lua assert(vim.lsp, "vim.lsp not available")' -c 'quitall'
  [ "$status" -eq 0 ]
  ! echo "$output" | grep -qi "error"
}

@test "checkhealth passes without critical errors" {
  local checkhealth_file=$(mktemp)

  nvim --headless -c 'checkhealth' -c "write! ${checkhealth_file}" -c 'quitall' 2>/dev/null

  # Check for CRITICAL errors only
  # We filter out errors that cannot be fixed in CI environment:
  #   - Copilot LSP: requires user authentication
  #   - kitty/wezterm/ghostty graphics: CI has no GUI terminal
  #   - tmux settings (escape-time, TERM): environment-specific
  #   - treesitter queries: transient, fixed by :TSUpdate
  #   - "is not ready": vague, often false positive
  #   - auto-dark-mode: macOS-specific, doesn't work on Linux
  #   - plugin setup warnings: "Setup is incorrect", "highlighter: not enabled", "setup not called", "setup did not run"
  #   - infocmp command: terminal capability detection, not critical
  local critical_errors=$(grep -i "ERROR" "$checkhealth_file" | \
    grep -v "Copilot LSP\|kitty\|wezterm\|ghostty\|escape-time\|TERM should be\|errors found in the query\|TSUpdate\|is not ready\|auto-dark-mode\|Setup is incorrect\|highlighter: not enabled\|setup not called\|setup did not run\|command failed: infocmp" || true)

  if [ -n "$critical_errors" ]; then
    echo "# ⚠️  Found critical errors in :checkhealth" >&3
    echo "# Run 'nvim +checkhealth' to see details" >&3
    echo "$critical_errors" >&3
    rm -f "$checkhealth_file"
    return 1
  fi

  rm -f "$checkhealth_file"
}
