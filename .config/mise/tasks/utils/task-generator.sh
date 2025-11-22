#!/usr/bin/env bash
# shellcheck disable=SC2312
#MISE description="Interactive wizard to generate mise file tasks"
#MISE alias="gen-task"
#MISE hide=false
#MISE tools={bat="latest"}

set -euo pipefail

# Source gum helpers
# shellcheck source=../../lib/gum-helpers.sh
source "$MISE_CONFIG_ROOT/.config/lib/gum-helpers.sh"

# Get task location
get_task_location() {
  show_section "Task Location" \
    "Simple tasks go in .config/mise/tasks/, grouped tasks in subdirectories"

  local task_type
  task_type=$(choose \
    "Simple task (root level)" \
    "Grouped task (in subdirectory)")

  if [[ "$task_type" == "Simple task (root level)" ]]; then
    TASK_NAME=$(input --placeholder "task-name" --prompt "Task name: ")
    TASK_PATH=".config/mise/tasks/${TASK_NAME}.sh"
  else
    local group
    group=$(input --placeholder "group-name" --prompt "Group name: ")
    TASK_NAME=$(input --placeholder "task-name" --prompt "Task name: ")
    TASK_PATH=".config/mise/tasks/${group}/${TASK_NAME}.sh"
  fi

  echo ""
}

# Get enabled features
get_enabled_features() {
  show_section "Select Features" \
    "Choose which optional features to configure (space to select, enter to confirm)"

  ENABLED_FEATURES=$(multi_choose \
    --header "Select optional features:" \
    "Alias" \
    "Hide from task list" \
    "Dependencies (runs before)" \
    "Wait for tasks" \
    "Post-dependencies (runs after)" \
    "Working directory" \
    "Environment variables" \
    "Confirmation prompt" \
    "Source files tracking" \
    "Output files tracking" \
    "Usage arguments/flags")

  echo ""
}

# Check if feature is enabled
is_feature_enabled() {
  is_enabled "$ENABLED_FEATURES" "$1"
}

# Get basic metadata
get_basic_metadata() {
  show_section "Basic Metadata" "Description shown in 'mise tasks'"

  DESCRIPTION=$(input --placeholder "What this task does" --prompt "Description: ")

  if is_feature_enabled "Alias"; then
    ALIAS=$(input --placeholder "shortname" --prompt "Alias: ")
  else
    ALIAS=""
  fi

  if is_feature_enabled "Hide from task list"; then
    HIDE="Hidden from 'mise tasks'"
  else
    HIDE="Visible in 'mise tasks'"
  fi

  echo ""
}

# Get dependencies
get_dependencies() {
  if ! is_feature_enabled "Dependencies" && \
     ! is_feature_enabled "Wait for" && \
     ! is_feature_enabled "Post-dependencies"; then
    DEPENDS=""
    WAIT_FOR=""
    DEPENDS_POST=""
    return
  fi

  show_section "Dependencies" \
    "depends=runs before, wait_for=waits but doesn't auto-run, depends_post=runs after"

  if is_feature_enabled "Dependencies (runs before)"; then
    DEPENDS=$(input --placeholder "build test (space-separated)" --prompt "Dependencies: ")
  else
    DEPENDS=""
  fi

  if is_feature_enabled "Wait for tasks"; then
    WAIT_FOR=$(input --placeholder "db:migrate (space-separated)" --prompt "Wait for: ")
  else
    WAIT_FOR=""
  fi

  if is_feature_enabled "Post-dependencies (runs after)"; then
    DEPENDS_POST=$(input --placeholder "cleanup (space-separated)" --prompt "Post-dependencies: ")
  else
    DEPENDS_POST=""
  fi

  echo ""
}

# Get execution settings
get_execution_settings() {
  if ! is_feature_enabled "Working directory" && \
     ! is_feature_enabled "Environment variables" && \
     ! is_feature_enabled "Confirmation prompt"; then
    DIR=""
    ENV_VARS=""
    CONFIRM=""
    return
  fi

  show_section "Execution Settings" \
    "dir=working directory, env=environment variables, confirm=user confirmation prompt"

  if is_feature_enabled "Working directory"; then
    DIR=$(input --placeholder "{{cwd}} or path" --prompt "Directory: " --value "{{cwd}}")
  else
    DIR=""
  fi

  if is_feature_enabled "Environment variables"; then
    ENV_VARS=$(input --placeholder "KEY1=value1 KEY2=value2" --prompt "Env vars: ")
  else
    ENV_VARS=""
  fi

  if is_feature_enabled "Confirmation prompt"; then
    CONFIRM=$(input --placeholder "Do you want to run this?" --prompt "Confirm message: ")
  else
    CONFIRM=""
  fi

  echo ""
}

# Get source/output tracking
get_tracking() {
  if ! is_feature_enabled "Source files tracking" && \
     ! is_feature_enabled "Output files tracking"; then
    SOURCES=""
    OUTPUTS=""
    return
  fi

  show_section "Source/Output Tracking" \
    "Mise skips task if sources haven't changed and outputs exist (up-to-date checking)"

  if is_feature_enabled "Source files tracking"; then
    SOURCES=$(input --placeholder "src/**/*.ts package.json" --prompt "Sources: ")
  else
    SOURCES=""
  fi

  if is_feature_enabled "Output files tracking"; then
    OUTPUTS=$(input --placeholder "dist/**/*" --prompt "Outputs: ")
  else
    OUTPUTS=""
  fi

  echo ""
}

# Get task type and implementation
get_task_implementation() {
  show_section "Task Implementation" \
    "Simple=inline commands, Complex=with usage args, gum styling, and helper functions"

  TASK_TYPE=$(choose \
    --header "Task type:" \
    "Simple commands (inline)" \
    "Complex bash script (with usage arguments)")

  if [[ "$TASK_TYPE" == "Simple commands (inline)" ]]; then
    USE_USAGE=false

    log_debug "Enter commands (empty line to finish):"

    COMMANDS=()
    while true; do
      local cmd
      cmd=$(input --placeholder "command or press Enter to finish" --prompt "> " || echo "")

      if [[ -z "$cmd" ]]; then
        break
      fi

      COMMANDS+=("$cmd")
    done
  else
    USE_USAGE=true

    if is_feature_enabled "Usage arguments/flags"; then
      ADD_USAGE_SPEC=true
      log_debug "You'll add #USAGE directives after generation"
    else
      ADD_USAGE_SPEC=false
    fi
  fi

  echo ""
}

# Show generated script preview
show_preview() {
  local content
  content=$(build_task_content)

  echo ""
  log_primary "Generated Script Preview"
  echo ""

  # Use bat if available, otherwise fallback to plain echo
  if command -v bat &>/dev/null; then
    echo "$content" | bat --language bash --style=numbers,grid --paging=never --file-name "$TASK_PATH"
  else
    separator
    echo ""
    echo "$content"
    echo ""
    separator
  fi

  echo ""
}

# Build task content (for preview and generation)
build_task_content() {
  {
    if [[ "$USE_USAGE" == true ]]; then
      echo "#!/usr/bin/env -S usage bash"
      echo "# shellcheck disable=SC2154"
    else
      echo "#!/usr/bin/env bash"
    fi

    # Add MISE directives (always include description)
    echo "#MISE description=\"$DESCRIPTION\""

    # Optional directives - active if enabled, commented if not
    if [[ -n "$ALIAS" ]]; then
      echo "#MISE alias=\"$ALIAS\""
    else
      echo "##MISE alias=\"shortname\""
    fi

    if [[ "$HIDE" == "Hidden from 'mise tasks'" ]]; then
      echo "#MISE hide=true"
    else
      echo "##MISE hide=true"
    fi

    # Dependencies - show examples as comments if not enabled
    if [[ -n "$DEPENDS" ]]; then
      local deps_array
      deps_array=$(echo "$DEPENDS" | tr ' ' '\n' | sed 's/^/"/;s/$/"/' | paste -sd ',' -)
      echo "#MISE depends=[$deps_array]"
    else
      echo "##MISE depends=[\"build\", \"test\"]"
    fi

    if [[ -n "$WAIT_FOR" ]]; then
      local wait_array
      wait_array=$(echo "$WAIT_FOR" | tr ' ' '\n' | sed 's/^/"/;s/$/"/' | paste -sd ',' -)
      echo "#MISE wait_for=[$wait_array]"
    else
      echo "##MISE wait_for=[\"db:migrate\"]"
    fi

    if [[ -n "$DEPENDS_POST" ]]; then
      local post_array
      post_array=$(echo "$DEPENDS_POST" | tr ' ' '\n' | sed 's/^/"/;s/$/"/' | paste -sd ',' -)
      echo "#MISE depends_post=[$post_array]"
    else
      echo "##MISE depends_post=[\"cleanup\"]"
    fi

    # Execution settings
    if [[ -n "$DIR" ]]; then
      echo "#MISE dir=\"$DIR\""
    else
      echo "##MISE dir=\"{{cwd}}\""
    fi

    if [[ -n "$ENV_VARS" ]]; then
      local env_formatted
      env_formatted=$(echo "$ENV_VARS" | sed 's/ /, /g; s/=/\" = \"/g; s/^/{/; s/$/}/')
      echo "#MISE env=$env_formatted"
    else
      echo "##MISE env={NODE_ENV = \"development\", DEBUG = \"true\"}"
    fi

    # Source/Output tracking
    if [[ -n "$SOURCES" ]]; then
      local sources_array
      sources_array=$(echo "$SOURCES" | tr ' ' '\n' | sed 's/^/"/;s/$/"/' | paste -sd ',' -)
      echo "#MISE sources=[$sources_array]"
    else
      echo "##MISE sources=[\"src/**/*\", \"package.json\"]"
    fi

    if [[ -n "$OUTPUTS" ]]; then
      local outputs_array
      outputs_array=$(echo "$OUTPUTS" | tr ' ' '\n' | sed 's/^/"/;s/$/"/' | paste -sd ',' -)
      echo "#MISE outputs=[$outputs_array]"
    else
      echo "##MISE outputs=[\"dist/**/*\"]"
    fi

    if [[ -n "$CONFIRM" ]]; then
      echo "#MISE confirm=\"$CONFIRM\""
    else
      echo "##MISE confirm=\"Are you sure?\""
    fi

    # Additional directives (always commented as reference)
    echo "##MISE shell=\"bash -c\""
    echo "##MISE quiet=true"
    echo "##MISE silent=true"
    echo "##MISE raw=true"
    echo "##MISE tools={node = \"22\", python = \"3.12\"}"

    echo ""

    # Add usage spec if requested
    if [[ "$USE_USAGE" == true ]]; then
      if [[ "$ADD_USAGE_SPEC" == true ]]; then
        echo "# Add your #USAGE directives here:"
        echo "#USAGE arg \"<environment>\" help=\"Target environment\""
        echo "#USAGE complete \"environment\" run=\"echo dev; echo staging; echo prod\""
        echo "#USAGE flag \"-f --force\" help=\"Force operation without confirmation\""
        echo "#USAGE flag \"--dry-run\" help=\"Preview changes only\""
        echo ""
        echo "# Commented examples of other #USAGE patterns:"
      else
        echo "# Uncomment and customize these #USAGE examples as needed:"
      fi

      # Always include commented usage examples as reference
      echo "## Common #USAGE patterns:"
      echo "##USAGE bin \"task-name\""
      echo ""
      echo "## Arguments:"
      echo "##USAGE arg \"<required-arg>\" help=\"Required positional argument\""
      echo "##USAGE arg \"[optional-arg]\" help=\"Optional argument\" default=\"value\""
      echo "##USAGE arg \"<files>\" help=\"Multiple files\" var=#true"
      echo "##USAGE arg \"<items>\" help=\"2-5 items\" var=#true var_min=2 var_max=5"
      echo "##USAGE arg \"<env>\" help=\"Environment\" choices \"dev\" \"staging\" \"prod\""
      echo ""
      echo "## Flags:"
      echo "##USAGE flag \"-v --verbose\" help=\"Verbose output\" count=#true global=#true"
      echo "##USAGE flag \"--config <file>\" help=\"Config file\" env=\"CONFIG_FILE\" default=\"config.toml\""
      echo "##USAGE flag \"--format <fmt>\" help=\"Output format\" choices \"json\" \"yaml\" \"toml\""
      echo "##USAGE flag \"--output <file>\" help=\"Output file\" required_if=\"--format\""
      echo "##USAGE flag \"--file <f>\" help=\"Input file\" required_unless=\"--stdin\""
      echo "##USAGE flag \"--stdin\" help=\"Read from stdin\" overrides=\"--file\""
      echo "##USAGE flag \"--color\" help=\"Colorize output\" negate=\"--no-color\" default=\"true\""
      echo "##USAGE flag \"--debug\" help=\"Debug mode\" hide=#true"
      echo ""
      echo "## Completions:"
      echo "##USAGE complete \"branch\" run=\"git branch --list --format='%(refname:short)'\""
      echo "##USAGE complete \"env\" run=\"echo dev; echo staging; echo prod\""
      echo "##USAGE complete \"file\" run=\"find . -type f -name '*.sh'\""
      echo ""
      echo "## Subcommands (simple):"
      echo "##USAGE cmd \"start\" help=\"Start the service\""
      echo "##USAGE cmd \"stop\" help=\"Stop the service\""
      echo "##USAGE cmd \"status\" help=\"Show service status\""
      echo ""
      echo "## Subcommands (nested):"
      echo "##USAGE cmd \"db\" help=\"Database commands\""
      echo "##USAGE cmd \"db migrate\" help=\"Run database migrations\""
      echo "##USAGE cmd \"db rollback\" help=\"Rollback last migration\""
      echo "##USAGE cmd \"db seed\" help=\"Seed database with test data\""
      echo "##USAGE cmd \"config\" help=\"Manage configuration\""
      echo "##USAGE cmd \"config get\" help=\"Get configuration value\""
      echo "##USAGE cmd \"config set\" help=\"Set configuration value\""
      echo "##USAGE cmd \"config list\" help=\"List all configuration\""
      echo ""
      echo "## Subcommand routing example:"
      echo "## case \"\$1\" in"
      echo "##   start) start_service ;;"
      echo "##   stop) stop_service ;;"
      echo "##   status) show_status ;;"
      echo "##   db)"
      echo "##     case \"\$2\" in"
      echo "##       migrate) db_migrate ;;"
      echo "##       rollback) db_rollback ;;"
      echo "##       seed) db_seed ;;"
      echo "##     esac"
      echo "##     ;;"
      echo "##   config)"
      echo "##     case \"\$2\" in"
      echo "##       get) config_get ;;"
      echo "##       set) config_set ;;"
      echo "##       list) config_list ;;"
      echo "##     esac"
      echo "##     ;;"
      echo "## esac"
      echo ""
    fi

    echo "set -euo pipefail"
    echo ""

    # Add implementation
    if [[ "$USE_USAGE" == false ]]; then
      # Simple commands - include gum helpers
      echo "# Source gum helpers for consistent styling"
      echo "# shellcheck source=utils/lib/gum-helpers.sh"

      # Calculate relative path to gum-helpers from task location
      local task_dir
      task_dir=$(dirname "$TASK_PATH")
      local depth
      depth=$(echo "$task_dir" | awk -F'/' '{print NF-3}') # Count levels below .config/mise/tasks/
      local relative_path=""
      for ((i=0; i<depth; i++)); do
        relative_path="../$relative_path"
      done

      echo "source \"\$(dirname \"\$0\")/${relative_path}utils/lib/gum-helpers.sh\""
      echo ""
      echo "# Task implementation"
      for cmd in "${COMMANDS[@]}"; do
        echo "$cmd"
      done
    else
      # Complex script with usage - include gum helpers
      echo "# Source gum helpers for consistent styling"
      echo "# shellcheck source=utils/lib/gum-helpers.sh"

      # Calculate relative path to gum-helpers from task location
      local task_dir
      task_dir=$(dirname "$TASK_PATH")
      local depth
      depth=$(echo "$task_dir" | awk -F'/' '{print NF-3}') # Count levels below .config/mise/tasks/
      local relative_path=""
      for ((i=0; i<depth; i++)); do
        relative_path="../$relative_path"
      done

      echo "source \"\$(dirname \"\$0\")/${relative_path}utils/lib/gum-helpers.sh\""
      echo ""
      echo "# Configuration"
      echo "readonly TASK_NAME=\"$TASK_NAME\""
      echo ""
      echo "# Main implementation"
      echo "main() {"
      echo "  # Add your task logic here"
      echo "  log_info \"Running \$TASK_NAME...\""
      echo "  "
      echo "  # Example:"
      echo "  # if spinner \"Processing...\" sleep 1; then"
      echo "  #   log_success \"Task completed\""
      echo "  # else"
      echo "  #   log_error \"Task failed\""
      echo "  #   exit 1"
      echo "  # fi"
      echo "}"
      echo ""
      echo "main"
    fi
  }
}

# Generate the task file
generate_task() {
  local dir
  dir=$(dirname "$TASK_PATH")

  if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir"
  fi

  build_task_content > "$TASK_PATH"
  chmod +x "$TASK_PATH"
}

# Main wizard flow
main() {
  show_header "Mise Task Generator" \
    "Create a new mise file task with full configuration"

  get_task_location
  get_enabled_features
  get_basic_metadata
  get_dependencies
  get_execution_settings
  get_tracking
  get_task_implementation

  # Show preview
  show_preview

  # Confirm before creating
  if ! confirm "Create this task?"; then
    log_warning "Cancelled"
    exit 0
  fi

  echo ""
  log_warning "Generating task..."

  if generate_task; then
    echo ""
    log_success "Task created successfully!"
    echo ""

    log_debug "Location: $TASK_PATH"
    echo ""

    log_primary "Next steps:"
    log_debug "1. Edit the task: \$EDITOR $TASK_PATH"
    log_debug "2. Test it: mise run ${TASK_NAME}"
    log_debug "3. List tasks: mise tasks"

    echo ""

    if confirm "Open in editor now?"; then
      local editor="${EDITOR:-vim}"
      if command -v "$editor" &>/dev/null; then
        "$editor" "$TASK_PATH"
      else
        log_warning "Editor '$editor' not found, skipping"
      fi
    fi
  else
    log_error "Failed to generate task"
    exit 1
  fi
}

main
