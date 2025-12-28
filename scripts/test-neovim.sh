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

@test "nvim-treesitter-textobjects loads" {
  test_plugin_loads "nvim-treesitter.textobjects.repeatable_move"
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
  local critical_errors=$(grep -i "ERROR" "$checkhealth_file" | \
    grep -v "Copilot LSP\|kitty\|wezterm\|ghostty\|escape-time\|TERM should be\|errors found in the query\|TSUpdate\|is not ready\|auto-dark-mode" || true)

  if [ -n "$critical_errors" ]; then
    echo "# ⚠️  Found critical errors in :checkhealth" >&3
    echo "# Run 'nvim +checkhealth' to see details" >&3
    echo "$critical_errors" >&3
    rm -f "$checkhealth_file"
    return 1
  fi

  rm -f "$checkhealth_file"
}
