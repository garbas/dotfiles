#!/usr/bin/env bash

################################################################################
# Claude Code Status Line Script
################################################################################
#
# Purpose: Display custom status line for Claude Code sessions
# Format: Model | Git Branch | Context % | Directory Path
#
# Input: JSON object from Claude Code via stdin containing:
#   - model.display_name: Claude model name
#   - workspace.current_dir: Current working directory
#   - transcript_path: Path to conversation transcript JSONL file
#   - exceeds_200k_tokens: Boolean flag if context exceeds 200k tokens
#
# Output: Colored status line with pipe separators
#   Example: Sonnet 4.5 | main | 47% | ~/dev/dotfiles
#
################################################################################

# Read JSON input from stdin (provided by Claude Code)
input=$(cat)

################################################################################
# Extract Data from Claude Code JSON Input
################################################################################

# Extract model name (e.g., "Sonnet 4.5")
model=$(echo "$input" | jq -r '.model.display_name')

# Extract current working directory
cwd=$(echo "$input" | jq -r '.workspace.current_dir')

# Extract path to conversation transcript (JSONL format)
transcript_path=$(echo "$input" | jq -r '.transcript_path')

# Extract flag indicating if context exceeds 200k tokens
exceeds_200k=$(echo "$input" | jq -r '.exceeds_200k_tokens')

################################################################################
# Calculate Token Usage
################################################################################
# Claude Sonnet 4.5 has a 200k token context window
tokens_max=200000

# Parse the transcript JSONL file to calculate accurate token usage
# This matches what the /context command shows
if [[ -f "$transcript_path" ]]; then
    # Strategy:
    # - Last message's input tokens = current context being sent to Claude
    # - Sum of all output tokens = all responses generated in this conversation
    # - Total = last input + all outputs (matches /context calculation)

    # Get the LAST message's input tokens
    # Includes: regular input + cache creation + cache reads
    last_input=$(grep '"usage"' "$transcript_path" | tail -1 | jq '(.message.usage.input_tokens // 0) + (.message.usage.cache_creation_input_tokens // 0) + (.message.usage.cache_read_input_tokens // 0)' 2>/dev/null || echo "0")

    # Sum ALL output tokens from all messages
    # Each assistant response adds to the conversation history
    all_outputs=$(grep '"usage"' "$transcript_path" | jq -s 'map(.message.usage.output_tokens // 0) | add // 0' 2>/dev/null || echo "0")

    # Calculate total tokens used in this session
    tokens_total=$((last_input + all_outputs))

    # Safety: Cap at max if the exceeds flag is set
    if [[ "$exceeds_200k" == "true" ]]; then
        tokens_total=$tokens_max
    fi
else
    # Transcript file doesn't exist yet (new session)
    tokens_total=0
fi

################################################################################
# Get Git Branch
################################################################################

# Check if current directory is inside a git repository
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    # Get current branch name, or "detached" if HEAD is detached
    git_branch=$(git -C "$cwd" branch --show-current 2>/dev/null || echo "detached")
else
    # Not a git repository
    git_branch="not a repo"
fi

################################################################################
# Calculate Context Usage Percentage
################################################################################

# Calculate percentage of context window used
# Output format: just the percentage (e.g., "47%")
if [ "$tokens_max" -gt 0 ] && [ "$tokens_total" -gt 0 ]; then
    tokens_percent=$(( (tokens_total * 100) / tokens_max ))
    context_display="${tokens_percent}%"
else
    context_display="0%"
fi

################################################################################
# Format Directory Path
################################################################################

# Replace home directory with ~ for cleaner display
# Ensure HOME environment variable is set
if [ -z "$HOME" ]; then
    HOME=$(eval echo ~)
fi

# Use sed to replace /Users/username with ~
dir_path=$(echo "$cwd" | sed "s|^$HOME|~|")

################################################################################
# Build and Output Status Line
################################################################################

# Define ANSI color codes
# Colors will be automatically dimmed by the terminal
CYAN=$(printf '\033[36m')      # Model name
GREEN=$(printf '\033[32m')     # Git branch
YELLOW=$(printf '\033[33m')    # (unused)
BLUE=$(printf '\033[34m')      # Context percentage
MAGENTA=$(printf '\033[35m')   # Directory path
RESET=$(printf '\033[0m')      # Reset to default

# Build and print status line with pipe separators
# Format: Model | Git Branch | Context % | Directory
printf "${CYAN}%s${RESET} | ${GREEN}%s${RESET} | ${BLUE}%s${RESET} | ${MAGENTA}%s${RESET}" \
    "$model" \
    "$git_branch" \
    "$context_display" \
    "$dir_path"
