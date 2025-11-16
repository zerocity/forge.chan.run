#!/usr/bin/env bash
# Shared gum helper functions for consistent styling across all tasks
# Source this file in your tasks: source "$(dirname "$0")/utils/lib/gum-helpers.sh"

# Color constants
readonly COLOR_PRIMARY=212    # Pink/Magenta - primary actions, success
readonly COLOR_SUCCESS=86     # Green - success states, enabled
readonly COLOR_WARNING=214    # Orange/Yellow - warnings, info
readonly COLOR_ERROR=196      # Red - errors, failures
readonly COLOR_MUTED=241      # Gray - debug, secondary info

# Header with title and optional description
# Usage: show_header "Title" ["Optional description"]
show_header() {
  local title="$1"
  local description="${2:-}"

  gum style \
    --foreground "$COLOR_PRIMARY" \
    --bold \
    "$title"

  if [[ -n "$description" ]]; then
    gum style \
      --foreground "$COLOR_MUTED" \
      "$description"
  fi

  echo ""
}

# Section header with description
# Usage: show_section "Section Title" "Description"
show_section() {
  local title="$1"
  local description="${2:-}"

  gum style --foreground "$COLOR_PRIMARY" "$title"

  if [[ -n "$description" ]]; then
    gum style --foreground "$COLOR_MUTED" "$description"
  fi

  echo ""
}

# Success message
# Usage: log_success "Message"
log_success() {
  gum style --foreground "$COLOR_SUCCESS" --bold "✓ $*"
}

# Success message (non-bold variant)
# Usage: log_success_plain "Message"
log_success_plain() {
  gum style --foreground "$COLOR_SUCCESS" "✓ $*"
}

# Error message
# Usage: log_error "Message"
log_error() {
  gum style --foreground "$COLOR_ERROR" "✗ $*"
}

# Error message (bold variant)
# Usage: log_error_bold "Critical error"
log_error_bold() {
  gum style --foreground "$COLOR_ERROR" --bold "✗ $*"
}

# Warning message
# Usage: log_warning "Message"
log_warning() {
  gum style --foreground "$COLOR_WARNING" "⚠ $*"
}

# Info message
# Usage: log_info "Message"
log_info() {
  gum style --foreground "$COLOR_SUCCESS" "ℹ $*"
}

# Debug/muted message
# Usage: log_debug "Message"
log_debug() {
  gum style --foreground "$COLOR_MUTED" "  $*"
}

# Primary message (pink/magenta)
# Usage: log_primary "Message"
log_primary() {
  gum style --foreground "$COLOR_PRIMARY" "$*"
}

# Primary message (bold variant)
# Usage: log_primary_bold "Message"
log_primary_bold() {
  gum style --foreground "$COLOR_PRIMARY" --bold "$*"
}

# Confirmation prompt
# Usage: if confirm "Are you sure?"; then ... fi
confirm() {
  gum confirm "$@"
}

# Choose from options
# Usage: choice=$(choose "Option 1" "Option 2" "Option 3")
#        choice=$(choose --header "Select:" "Opt1" "Opt2")
choose() {
  gum choose "$@"
}

# Multi-select from options
# Usage: selected=$(multi_choose "Option 1" "Option 2" "Option 3")
#        selected=$(multi_choose --header "Select multiple:" "Opt1" "Opt2")
multi_choose() {
  gum choose --no-limit "$@"
}

# Input prompt
# Usage: value=$(input "Enter name:")
#        value=$(input --placeholder "default" --prompt "Name: ")
input() {
  gum input "$@"
}

# Spinner for long operations
# Usage: if spinner "Loading..." do_work; then ... fi
#        if spinner --spinner dot "Processing..." command arg1 arg2; then ... fi
spinner() {
  local title="$1"
  shift

  gum spin --spinner dot --title "$title" -- "$@"
}

# Box with border
# Usage: box "Content here"
#        box --border-foreground "$COLOR_SUCCESS" "Success box"
box() {
  local border_color="${COLOR_PRIMARY}"
  local args=()

  # Parse optional --border-foreground argument
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --border-foreground)
        border_color="$2"
        shift 2
        ;;
      *)
        args+=("$1")
        shift
        ;;
    esac
  done

  gum style \
    --border rounded \
    --padding "1 2" \
    --border-foreground "$border_color" \
    "${args[@]}"
}

# Separator line
# Usage: separator
#        separator "Custom text"
separator() {
  local text="${1:-────────────────────────────────────────}"
  gum style --foreground "$COLOR_MUTED" "$text"
}

# Step indicator (for multi-step processes)
# Usage: show_step 1 "First step"
show_step() {
  local step_num="$1"
  local step_text="$2"

  gum style --foreground "$COLOR_SUCCESS" "Step $step_num: $step_text"
}

# Check if a feature/option is enabled (for multi-select results)
# Usage: if is_enabled "$FEATURES" "Feature Name"; then ... fi
is_enabled() {
  local features="$1"
  local feature="$2"

  echo "$features" | grep -q "$feature"
}

# Display key-value pair
# Usage: show_kv "Key" "Value"
show_kv() {
  local key="$1"
  local value="$2"

  echo "$(gum style --foreground "$COLOR_PRIMARY" "$key:")" "$(gum style --foreground "$COLOR_MUTED" "$value")"
}

# Banner message (centered with emoji)
# Usage: banner "🚀" "Starting Process"
banner() {
  local emoji="$1"
  local text="$2"

  gum style --foreground "$COLOR_PRIMARY" --bold "$emoji $text"
}
