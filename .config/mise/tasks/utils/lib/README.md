# Gum Helpers Library

Shared helper functions for consistent gum styling across all mise tasks.

## Usage

Source the library in your task:

```bash
#!/usr/bin/env bash
#MISE description="My task"

set -euo pipefail

# Source gum helpers
source "$(dirname "$0")/utils/lib/gum-helpers.sh"

# Now use the helpers
show_header "My Task" "Does something cool"

log_info "Starting process..."

if spinner "Processing..." do_work; then
  log_success "Task completed!"
else
  log_error "Task failed"
  exit 1
fi
```

## Available Functions

### Headers & Sections

- `show_header "Title" ["Description"]` - Main header with optional description
- `show_section "Title" ["Description"]` - Section header
- `separator ["Custom text"]` - Separator line
- `banner "🚀" "Text"` - Banner with emoji

### Logging

- `log_success "Message"` - Green success (bold)
- `log_success_plain "Message"` - Green success (plain)
- `log_error "Message"` - Red error
- `log_error_bold "Message"` - Red error (bold)
- `log_warning "Message"` - Orange warning
- `log_info "Message"` - Info message
- `log_debug "Message"` - Muted/debug message
- `log_primary "Message"` - Primary color
- `log_primary_bold "Message"` - Primary color (bold)

### Interactive Components

- `confirm "Question?"` - Yes/no confirmation
- `choose "Opt1" "Opt2" "Opt3"` - Single choice
- `multi_choose "Opt1" "Opt2" "Opt3"` - Multi-select
- `input [--placeholder "text"] [--prompt "Name:"]` - Text input
- `spinner "Loading..." command args` - Spinner for long operations
- `box "Content"` - Box with rounded border
- `box --border-foreground "$COLOR_SUCCESS" "Content"` - Colored box

### Utilities

- `is_enabled "$FEATURES" "Feature Name"` - Check if feature is in multi-select result
- `show_kv "Key" "Value"` - Display key-value pair
- `show_step 1 "Step description"` - Step indicator

## Color Constants

Available after sourcing:

- `COLOR_PRIMARY` (212) - Pink/Magenta
- `COLOR_SUCCESS` (86) - Green
- `COLOR_WARNING` (214) - Orange/Yellow
- `COLOR_ERROR` (196) - Red
- `COLOR_MUTED` (241) - Gray

## Examples

### Simple Task

```bash
#!/usr/bin/env bash
#MISE description="Build project"

source "$(dirname "$0")/utils/lib/gum-helpers.sh"

show_header "Build" "Compiling project"

if spinner "Building..." npm run build; then
  log_success "Build complete"
else
  log_error "Build failed"
  exit 1
fi
```

### Multi-Step Process

```bash
#!/usr/bin/env bash
#MISE description="Deploy application"

source "$(dirname "$0")/utils/lib/gum-helpers.sh"

show_header "Deploy"

show_step 1 "Running tests"
if spinner "Testing..." npm test; then
  log_debug "✓ Tests passed"
else
  log_error "Tests failed"
  exit 1
fi

show_step 2 "Building"
if spinner "Building..." npm run build; then
  log_debug "✓ Build complete"
fi

show_step 3 "Deploying"
if confirm "Deploy to production?"; then
  spinner "Deploying..." ./deploy.sh
  log_success "Deployed successfully!"
fi
```

### Interactive Configuration

```bash
#!/usr/bin/env bash
#MISE description="Configure settings"

source "$(dirname "$0")/utils/lib/gum-helpers.sh"

show_header "Configuration"

env=$(choose --header "Environment:" "dev" "staging" "prod")
features=$(multi_choose --header "Features:" "Auth" "Analytics" "Logging")

log_primary "Configuration:"
show_kv "Environment" "$env"
show_kv "Features" "$features"

if confirm "Save configuration?"; then
  log_success "Configuration saved"
fi
```
