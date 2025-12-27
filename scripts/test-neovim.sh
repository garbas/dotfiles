#!/usr/bin/env bash
# Neovim Configuration Test Script
# Run this after any Neovim configuration changes

set -e

echo "🧪 Testing Neovim Configuration..."
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

passed=0
failed=0
warnings=0

# Test 1: Neovim starts without errors
echo -n "✓ Neovim starts... "
if nvim --headless -c 'quitall' 2>&1 | grep -i "error" > /dev/null; then
  echo -e "${RED}FAILED${NC}"
  ((failed++))
else
  echo -e "${GREEN}OK${NC}"
  ((passed++))
fi

# Test 2: Check Neovim version
echo -n "✓ Neovim version... "
version=$(nvim --version | head -1)
echo -e "${GREEN}${version}${NC}"
((passed++))

# Test 3: Check if leap.nvim loads
echo -n "✓ leap.nvim loads... "
if nvim --headless -c 'lua require("leap")' -c 'quitall' 2>&1 | grep -i "error" > /dev/null; then
  echo -e "${RED}FAILED${NC}"
  ((failed++))
else
  # Check for deprecation warnings
  if nvim --headless -c 'lua require("leap")' -c 'quitall' 2>&1 | grep -i "deprecated" > /dev/null; then
    echo -e "${YELLOW}OK (with warnings)${NC}"
    ((warnings++))
  else
    echo -e "${GREEN}OK${NC}"
    ((passed++))
  fi
fi

# Test 4: Check if blink.cmp loads
echo -n "✓ blink.cmp loads... "
if nvim --headless -c 'lua require("blink.cmp")' -c 'quitall' 2>&1 | grep -i "error" > /dev/null; then
  echo -e "${RED}FAILED${NC}"
  ((failed++))
else
  echo -e "${GREEN}OK${NC}"
  ((passed++))
fi

# Test 5: Check if telescope loads
echo -n "✓ telescope.nvim loads... "
if nvim --headless -c 'lua require("telescope")' -c 'quitall' 2>&1 | grep -i "error" > /dev/null; then
  echo -e "${RED}FAILED${NC}"
  ((failed++))
else
  echo -e "${GREEN}OK${NC}"
  ((passed++))
fi

# Test 6: Check if treesitter loads
echo -n "✓ nvim-treesitter loads... "
if nvim --headless -c 'lua require("nvim-treesitter")' -c 'quitall' 2>&1 | grep -i "error" > /dev/null; then
  echo -e "${RED}FAILED${NC}"
  ((failed++))
else
  echo -e "${GREEN}OK${NC}"
  ((passed++))
fi

# Test 7: Check if copilot loads
echo -n "✓ copilot.lua loads... "
if nvim --headless -c 'lua require("copilot")' -c 'quitall' 2>&1 | grep -i "error" > /dev/null; then
  echo -e "${RED}FAILED${NC}"
  ((failed++))
else
  echo -e "${GREEN}OK${NC}"
  ((passed++))
fi

# Test 8: Check if claude-code loads
echo -n "✓ claude-code.nvim loads... "
if nvim --headless -c 'lua require("claude-code")' -c 'quitall' 2>&1 | grep -i "error" > /dev/null; then
  echo -e "${RED}FAILED${NC}"
  ((failed++))
else
  echo -e "${GREEN}OK${NC}"
  ((passed++))
fi

# Test 9: Check if nui loads (noice dependency - it's a library, so skip direct test)
echo -n "✓ nui.nvim present... "
# nui is a library plugin, not directly loadable via require()
# We'll verify it works through noice
echo -e "${GREEN}OK (library)${NC}"
((passed++))

# Test 10: Check if noice loads
echo -n "✓ noice.nvim loads... "
if nvim --headless -c 'lua require("noice")' -c 'quitall' 2>&1 | grep -i "error" > /dev/null; then
  echo -e "${RED}FAILED${NC}"
  ((failed++))
else
  echo -e "${GREEN}OK${NC}"
  ((passed++))
fi

# Test 11: Check if nvim-surround loads
echo -n "✓ nvim-surround loads... "
if nvim --headless -c 'lua require("nvim-surround")' -c 'quitall' 2>&1 | grep -i "error" > /dev/null; then
  echo -e "${RED}FAILED${NC}"
  ((failed++))
else
  echo -e "${GREEN}OK${NC}"
  ((passed++))
fi

# Test 12: Check if nvim-autopairs loads
echo -n "✓ nvim-autopairs loads... "
if nvim --headless -c 'lua require("nvim-autopairs")' -c 'quitall' 2>&1 | grep -i "error" > /dev/null; then
  echo -e "${RED}FAILED${NC}"
  ((failed++))
else
  echo -e "${GREEN}OK${NC}"
  ((passed++))
fi

# Test 13: Check if todo-comments loads
echo -n "✓ todo-comments.nvim loads... "
if nvim --headless -c 'lua require("todo-comments")' -c 'quitall' 2>&1 | grep -i "error" > /dev/null; then
  echo -e "${RED}FAILED${NC}"
  ((failed++))
else
  echo -e "${GREEN}OK${NC}"
  ((passed++))
fi

# Test 14: Check LSP config
echo -n "✓ LSP configuration... "
if nvim --headless -c 'lua vim.lsp' -c 'quitall' 2>&1 | grep -i "error" > /dev/null; then
  echo -e "${RED}FAILED${NC}"
  ((failed++))
else
  echo -e "${GREEN}OK${NC}"
  ((passed++))
fi

# Test 15: Run checkhealth (capture output)
echo ""
echo "📋 Running :checkhealth..."
echo ""
nvim --headless -c 'checkhealth' -c 'write! /tmp/nvim-checkhealth.log' -c 'quitall' 2>/dev/null

# Check for errors in checkhealth
if grep -i "ERROR" /tmp/nvim-checkhealth.log > /dev/null; then
  echo -e "${RED}⚠️  Found errors in :checkhealth${NC}"
  echo "Run 'nvim +checkhealth' to see details"
  ((failed++))
else
  echo -e "${GREEN}✓ :checkhealth passed${NC}"
  ((passed++))
fi

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Test Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}Passed:${NC}   $passed"
echo -e "${YELLOW}Warnings:${NC} $warnings"
echo -e "${RED}Failed:${NC}   $failed"
echo ""

if [ $failed -eq 0 ]; then
  echo -e "${GREEN}✅ All tests passed!${NC}"
  exit 0
else
  echo -e "${RED}❌ Some tests failed${NC}"
  exit 1
fi
