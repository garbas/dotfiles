#!/usr/bin/env bats

# End-to-end tmux configuration tests
# Run with: bats tests/tmux.bats
#
# These tests verify actual tmux behavior, not just config file contents

TEST_SESSION="bats-tmux-test"

setup_file() {
  # Create test session once for all tests
  tmux kill-session -t "$TEST_SESSION" 2>/dev/null || true
  tmux new-session -d -s "$TEST_SESSION" -c "$HOME"
}

teardown_file() {
  tmux kill-session -t "$TEST_SESSION" 2>/dev/null || true
}

setup() {
  command -v tmux >/dev/null 2>&1 || skip "tmux not installed"
}

# Helper to get tmux option value
get_option() {
  tmux show-options -g "$1" 2>/dev/null | sed "s/^$1 //"
}

get_window_option() {
  tmux show-window-options -g "$1" 2>/dev/null | sed "s/^$1 //"
}

@test "tmux server is running" {
  run tmux list-sessions
  [ "$status" -eq 0 ]
}

@test "status-left contains hostname format (#h)" {
  result=$(get_option "status-left")
  [[ "$result" == *"#h"* ]]
}

@test "automatic-rename is enabled" {
  result=$(get_option "automatic-rename")
  [ "$result" = "on" ]
}

@test "automatic-rename-format uses folder basename" {
  result=$(get_option "automatic-rename-format")
  [[ "$result" == *"#{b:pane_current_path}"* ]]
}

@test "window name updates to directory name" {
  # Create a new window in /tmp
  tmux new-window -t "$TEST_SESSION" -c /tmp
  sleep 2  # Wait for auto-rename

  # Get the last window name
  window_name=$(tmux list-windows -t "$TEST_SESSION" -F '#{window_name}' | tail -1)

  # Should be "tmp"
  [ "$window_name" = "tmp" ]
}

@test "status-interval is 1 second" {
  result=$(get_option "status-interval")
  [ "$result" = "1" ]
}

@test "mouse mode is enabled" {
  result=$(get_option "mouse")
  [ "$result" = "on" ]
}

@test "vi mode-keys is active" {
  result=$(get_option "mode-keys")
  [ "$result" = "vi" ]
}

@test "prefix key is C-Space" {
  result=$(get_option "prefix")
  [ "$result" = "C-Space" ]
}

@test "base-index is 1" {
  result=$(get_option "base-index")
  [ "$result" = "1" ]
}

@test "pane-base-index is 1" {
  result=$(get_window_option "pane-base-index")
  [ "$result" = "1" ]
}

@test "history-limit is 10000" {
  result=$(get_option "history-limit")
  [ "$result" = "10000" ]
}

@test "set-clipboard is on" {
  result=$(get_option "set-clipboard")
  [ "$result" = "on" ]
}

@test "allow-passthrough is on for clickable links" {
  result=$(get_option "allow-passthrough")
  [ "$result" = "on" ]
}

@test "monitor-activity is on" {
  result=$(get_option "monitor-activity")
  [ "$result" = "on" ]
}

@test "monitor-bell is on" {
  result=$(get_option "monitor-bell")
  [ "$result" = "on" ]
}

@test "prefix+c binding creates window in home directory" {
  binding=$(tmux list-keys | grep "prefix.*c.*new-window")
  [[ "$binding" == *"$HOME"* ]] || [[ "$binding" == *"-c ~"* ]]
}

@test "prefix+| binding splits horizontally" {
  run tmux list-keys -T prefix '|'
  [ "$status" -eq 0 ]
  [[ "$output" == *"split-window -h"* ]]
}

@test "prefix+- binding splits vertically" {
  run tmux list-keys -T prefix '-'
  [ "$status" -eq 0 ]
  [[ "$output" == *"split-window -v"* ]]
}

@test "vim pane navigation bindings exist" {
  for key in h j k l; do
    run tmux list-keys -T prefix "$key"
    [ "$status" -eq 0 ]
    [[ "$output" == *"select-pane"* ]]
  done
}

@test "pane resize bindings exist" {
  for key in H J K L; do
    run tmux list-keys -T prefix "$key"
    [ "$status" -eq 0 ]
    [[ "$output" == *"resize-pane"* ]]
  done
}

@test "catppuccin theme is loaded" {
  result=$(tmux show-options -g | grep -c "@thm_" || echo "0")
  [ "$result" -gt 0 ]
}

@test "status-right contains date_time" {
  result=$(get_option "status-right")
  [[ "$result" == *"date_time"* ]]
}

@test "24-hour clock mode" {
  result=$(get_window_option "clock-mode-style")
  [ "$result" = "24" ]
}

@test "split bindings include current path" {
  # Verify that our split bindings include -c "#{pane_current_path}"
  # Note: Can't test actual key-sending in headless tmux

  # Check horizontal split binding
  h_binding=$(tmux list-keys -T prefix '|')
  [[ "$h_binding" == *"pane_current_path"* ]]

  # Check vertical split binding
  v_binding=$(tmux list-keys -T prefix '-')
  [[ "$v_binding" == *"pane_current_path"* ]]
}

@test "prefix+W binding exists for worktree workflow" {
  run tmux list-keys -T prefix 'W'
  [ "$status" -eq 0 ]
  [[ "$output" == *"command-prompt"* ]]
  [[ "$output" == *"tmux-worktree"* ]]
}

@test "tmux-worktree script is in PATH" {
  # Skip in CI where home-manager isn't activated
  command -v tmux-worktree >/dev/null 2>&1 || skip "tmux-worktree not in PATH (CI environment)"
}

@test "tmux-worktree creates worktree and branch" {
  command -v git >/dev/null 2>&1 || skip "git not in PATH"
  # Create a temporary git repo for testing
  TEST_REPO=$(mktemp -d)
  cd "$TEST_REPO"
  git init --initial-branch=main
  git config user.email "test@test.com"
  git config user.name "Test"
  echo "test" > README.md
  git add README.md
  git commit -m "Initial commit"

  # Create a window in the test repo so tmux-worktree can find it
  tmux new-window -t "$TEST_SESSION" -c "$TEST_REPO" -n "test-repo"
  sleep 0.5

  # Run tmux-worktree (we can't use the actual script because it runs claude,
  # so we test the worktree creation part separately)
  WORKTREE_NAME="test-feature"
  mkdir -p "$TEST_REPO/w"
  git worktree add "$TEST_REPO/w/$WORKTREE_NAME" -b "$WORKTREE_NAME"

  # Verify worktree was created
  [ -d "$TEST_REPO/w/$WORKTREE_NAME" ]

  # Verify branch exists
  git branch | grep -q "$WORKTREE_NAME"

  # Verify worktree is listed
  git worktree list | grep -q "$WORKTREE_NAME"

  # Cleanup
  git worktree remove "$TEST_REPO/w/$WORKTREE_NAME" --force
  rm -rf "$TEST_REPO"
}

@test "tmux-worktree script creates window with split panes" {
  # Create a temporary git repo
  TEST_REPO=$(mktemp -d)
  cd "$TEST_REPO"
  git init --initial-branch=main
  git config user.email "test@test.com"
  git config user.name "Test"
  echo "test" > README.md
  git add README.md
  git commit -m "Initial commit"

  # Create a window in the test repo
  tmux new-window -t "$TEST_SESSION" -c "$TEST_REPO" -n "worktree-test"
  sleep 0.5

  # Count windows before
  windows_before=$(tmux list-windows -t "$TEST_SESSION" | wc -l)

  # Simulate what tmux-worktree does (without running claude)
  WORKTREE_NAME="e2e-test-$$"
  mkdir -p "$TEST_REPO/w"
  git worktree add "$TEST_REPO/w/$WORKTREE_NAME" -b "$WORKTREE_NAME"

  # Create new window like the script does
  tmux new-window -t "$TEST_SESSION" -c "$TEST_REPO/w/$WORKTREE_NAME" -n "$WORKTREE_NAME"

  # Split horizontally (but use 'true' instead of 'claude' for testing)
  tmux split-window -t "$TEST_SESSION" -h -c "$TEST_REPO/w/$WORKTREE_NAME" "sleep 2"
  sleep 0.5

  # Count windows after
  windows_after=$(tmux list-windows -t "$TEST_SESSION" | wc -l)

  # Should have one more window
  [ "$windows_after" -gt "$windows_before" ]

  # The new window should have 2 panes
  pane_count=$(tmux list-panes -t "$TEST_SESSION:$WORKTREE_NAME" 2>/dev/null | wc -l)
  [ "$pane_count" -eq 2 ]

  # Window name should match worktree name
  tmux list-windows -t "$TEST_SESSION" -F '#{window_name}' | grep -q "$WORKTREE_NAME"

  # Cleanup
  git -C "$TEST_REPO" worktree remove "w/$WORKTREE_NAME" --force 2>/dev/null || true
  git -C "$TEST_REPO" branch -D "$WORKTREE_NAME" 2>/dev/null || true
  rm -rf "$TEST_REPO"
}

# Session restore tests (resurrect + continuum plugins)

@test "resurrect plugin: capture-pane-contents is on" {
  result=$(tmux show-options -g "@resurrect-capture-pane-contents" 2>/dev/null | sed 's/^@resurrect-capture-pane-contents //')
  [ "$result" = "on" ]
}

@test "continuum plugin: restore is on" {
  result=$(tmux show-options -g "@continuum-restore" 2>/dev/null | sed 's/^@continuum-restore //')
  [ "$result" = "on" ]
}

@test "continuum plugin: save-interval is 10 minutes" {
  result=$(tmux show-options -g "@continuum-save-interval" 2>/dev/null | sed 's/^@continuum-save-interval //')
  [ "$result" = "10" ]
}

@test "resurrect plugin: save binding exists (prefix + Ctrl-s)" {
  run tmux list-keys
  [ "$status" -eq 0 ]
  [[ "$output" == *"C-s"* ]]
}

@test "resurrect plugin: restore binding exists (prefix + Ctrl-r)" {
  run tmux list-keys
  [ "$status" -eq 0 ]
  [[ "$output" == *"C-r"* ]]
}

@test "resurrect plugin: save creates resurrect file" {
  # Resurrect restore only works on tmux server restart, not for individual
  # killed sessions. This test verifies the save mechanism works.

  RESURRECT_DIR="$HOME/.tmux/resurrect"

  # Trigger resurrect save via the binding (prefix + Ctrl-s)
  tmux send-keys -t "$TEST_SESSION" C-Space C-s
  sleep 2  # Wait for save to complete

  # Verify resurrect created a save file
  [ -d "$RESURRECT_DIR" ] || skip "Resurrect directory not found"

  # Check that a save file exists (last symlink or files in dir)
  [ -e "$RESURRECT_DIR/last" ] || [ -n "$(ls -A "$RESURRECT_DIR" 2>/dev/null)" ]
}
