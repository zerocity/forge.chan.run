#!/usr/bin/env bash
#MISE description="Health check for Docker services with retry logic"
#MISE alias="status"

set -euo pipefail

# Source shared gum helpers
source "$MISE_CONFIG_ROOT/.config/lib/gum-helpers.sh"

readonly MAX_RETRIES=30
readonly RETRY_DELAY=2

check_postgres() {
  docker exec forge-postgres pg_isready -U testuser -d testdb &>/dev/null
}

check_airflow() {
  # http://localhost:8080/api/v2/monitor/health 
  curl -sf http://localhost:8080 &>/dev/null
}

wait_for_service() {
  local service_name="$1"
  local check_function="$2"
  local retries=0

  log_warning "Waiting for $service_name..."

  while [ $retries -lt $MAX_RETRIES ]; do
    if $check_function; then
      log_success "$service_name is healthy"
      return 0
    fi

    retries=$((retries + 1))
    sleep $RETRY_DELAY
  done

  log_error "$service_name failed to become healthy after $((MAX_RETRIES * RETRY_DELAY))s"
  return 1
}

main() {
  show_header "🏥 Health Check"

  # Wait for Postgres
  if ! wait_for_service "PostgreSQL" check_postgres; then
    exit 1
  fi

  # Wait for Airflow
  if ! wait_for_service "Airflow" check_airflow; then
    exit 1
  fi

  echo ""
  log_success "All services healthy!"
}

main "$@"
