#!/usr/bin/env bash
#MISE description="Check and grant CAP_NET_BIND_SERVICE capability to localias"
#MISE hide=false

set -euo pipefail

# shellcheck source=../lib/gum-helpers.sh
source "$MISE_PROJECT_ROOT/.config/lib/gum-helpers.sh"

# Check if localias has the required capability
if ! getcap "$(which localias)" | grep -q "cap_net_bind_service"; then
    log_warning "Localias needs permission to bind to ports 80/443"
    echo ""
    log_debug "Localias requires the CAP_NET_BIND_SERVICE capability to bind to privileged ports."
    echo ""

    if confirm "Grant capability now? (requires sudo)"; then
        if sudo setcap CAP_NET_BIND_SERVICE=+eip "$(which localias)"; then
            log_success "Capability granted successfully"
        else
            log_error_bold "Failed to grant capability"
            exit 1
        fi
    else
        log_error "Cannot start localias without capability"
        log_debug "Run: sudo setcap CAP_NET_BIND_SERVICE=+eip \$(which localias)"
        exit 1
    fi
fi
