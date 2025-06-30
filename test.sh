#!/usr/bin/env bash
# Test runner for dotfiles

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

main() {
    log_info "Running dotfiles tests..."
    
    # Run the main test suite
    if "$SCRIPT_DIR/tests/test-installation.sh"; then
        log_success "All tests passed!"
        exit 0
    else
        echo "Some tests failed. See output above for details."
        exit 1
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi