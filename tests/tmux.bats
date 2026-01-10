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
