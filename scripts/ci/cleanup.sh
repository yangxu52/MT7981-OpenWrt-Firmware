#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/ci/lib.sh
source "${SCRIPT_DIR}/lib.sh"

cleanup_runner() {
  log_info "Cleaning runner disk space"

  sudo rm -rf /usr/local/lib/android || true
  sudo rm -rf /usr/share/dotnet || true
  sudo rm -rf /opt/ghc || true
  sudo rm -rf /usr/local/.ghcup || true
  sudo rm -rf /opt/hostedtoolcache/CodeQL || true

  sudo swapoff -a || true
  sudo rm -f /swapfile || true

  sudo docker image prune -af || true
}

case "${1:-}" in
  runner)
    cleanup_runner
    ;;
  *)
    log_error "Unknown command: ${1:-}"
    exit 1
    ;;
esac
