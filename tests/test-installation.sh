#!/usr/bin/env bash
# Test suite for dotfiles installation and automation

set -uo pipefail
# Note: Not using -e to allow tests to continue even if individual tests fail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(dirname "$SCRIPT_DIR")"
TEST_TMPDIR="/tmp/dotfiles-test-$$"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[PASS]${NC} $1"; }
log_fail() { echo -e "${RED}[FAIL]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# Test framework functions
test_start() {
    local test_name="$1"
    echo -e "\n${BLUE}Running test:${NC} $test_name"
    ((TESTS_RUN++))
}

test_pass() {
    local test_name="$1"
    log_success "$test_name"
    ((TESTS_PASSED++))
}

test_fail() {
    local test_name="$1"
    local error_msg="${2:-Unknown error}"
    log_fail "$test_name - $error_msg"
    ((TESTS_FAILED++))
}

assert_command_exists() {
    local cmd="$1"
    local test_name="$2"
    
    if command -v "$cmd" >/dev/null 2>&1; then
        test_pass "$test_name"
        return 0
    else
        test_fail "$test_name" "Command '$cmd' not found"
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local test_name="$2"
    
    if [[ -f "$file" ]]; then
        test_pass "$test_name"
        return 0
    else
        test_fail "$test_name" "File '$file' not found"
        return 1
    fi
}

assert_symlink_valid() {
    local symlink="$1"
    local test_name="$2"
    
    if [[ -L "$symlink" ]] && [[ -e "$symlink" ]]; then
        test_pass "$test_name"
        return 0
    else
        test_fail "$test_name" "Symlink '$symlink' invalid or broken"
        return 1
    fi
}

# Setup test environment
setup_test_env() {
    log_info "Setting up test environment..."
    mkdir -p "$TEST_TMPDIR"
    export TEST_MODE=1
}

# Cleanup test environment
cleanup_test_env() {
    log_info "Cleaning up test environment..."
    rm -rf "$TEST_TMPDIR"
}

# Test script permissions
test_script_permissions() {
    test_start "Script permissions"
    
    local scripts=(
        "install-system.sh"
        "dotfiles-sync.sh"
        "auto-update.sh"
        "dotfiles.sh"
        "create-symlinks.sh"
        "setup-dotfiles-alias.sh"
    )
    
    local all_executable=true
    for script in "${scripts[@]}"; do
        local script_path="$DOTFILES_ROOT/scripts/$script"
        if [[ ! -f "$script_path" ]]; then
            test_fail "Script permissions" "Script '$script' not found"
            all_executable=false
        elif [[ ! -x "$script_path" ]]; then
            test_fail "Script permissions" "Script '$script' not executable"
            all_executable=false
        fi
    done
    
    if $all_executable; then
        test_pass "All scripts are executable"
    fi
}

# Test script syntax
test_script_syntax() {
    test_start "Script syntax validation"
    
    local scripts=(
        "install-system.sh"
        "dotfiles-sync.sh"
        "auto-update.sh"
        "dotfiles.sh"
        "create-symlinks.sh"
        "setup-dotfiles-alias.sh"
    )
    
    local all_valid=true
    for script in "${scripts[@]}"; do
        local script_path="$DOTFILES_ROOT/scripts/$script"
        if [[ ! -f "$script_path" ]]; then
            test_fail "Script syntax" "Script '$script' not found"
            all_valid=false
        elif ! bash -n "$script_path" 2>/dev/null; then
            test_fail "Script syntax" "Script '$script' has syntax errors"
            all_valid=false
        fi
    done
    
    if $all_valid; then
        test_pass "All scripts have valid syntax"
    fi
}

# Test dotfiles CLI help
test_dotfiles_cli() {
    test_start "Dotfiles CLI interface"
    
    local dotfiles_script="$DOTFILES_ROOT/scripts/dotfiles.sh"
    
    # Test if dotfiles script exists and is executable
    if [[ ! -f "$dotfiles_script" ]]; then
        test_fail "Dotfiles CLI" "Script not found"
        return
    fi
    
    if [[ ! -x "$dotfiles_script" ]]; then
        test_fail "Dotfiles CLI" "Script not executable"
        return
    fi
    
    # Test help command
    if "$dotfiles_script" help >/dev/null 2>&1; then
        test_pass "Dotfiles CLI help command works"
    else
        test_fail "Dotfiles CLI" "Help command failed"
    fi
}

# Test configuration files exist
test_config_files() {
    test_start "Configuration files"
    
    local configs=(
        "config/bash/bashrc"
        "config/fish/config.fish"
        "config/git/gitconfig.template"
        "config/git/gitignore_global"
        "config/shell/aliases.sh"
        "config/shell/exports.sh"
        "config/shell/aliases.fish"
        "config/shell/exports.fish"
    )
    
    local all_exist=true
    for config in "${configs[@]}"; do
        if [[ ! -f "$DOTFILES_ROOT/$config" ]]; then
            test_fail "Configuration files" "Config '$config' not found"
            all_exist=false
        fi
    done
    
    if $all_exist; then
        test_pass "All configuration files exist"
    fi
}

# Test documentation files
test_documentation() {
    test_start "Documentation files"
    
    local docs=(
        "README.md"
        "AUTOMATION.md"
        "ARCHITECTURE.md"
        "TROUBLESHOOTING.md"
        "SYSTEM-SETUP.md"
    )
    
    local all_exist=true
    for doc in "${docs[@]}"; do
        if [[ ! -f "$DOTFILES_ROOT/$doc" ]]; then
            test_fail "Documentation" "Doc '$doc' not found"
            all_exist=false
        fi
    done
    
    if $all_exist; then
        test_pass "All documentation files exist"
    fi
}

# Test package lists in installer
test_package_lists() {
    test_start "Package lists in installer"
    
    local installer="$DOTFILES_ROOT/scripts/install-system.sh"
    
    # Check if essential packages are defined
    if grep -q "ESSENTIAL_PACKAGES" "$installer" && \
       grep -q "DEVELOPMENT_PACKAGES" "$installer" && \
       grep -q "MODERN_CLI_PACKAGES" "$installer"; then
        test_pass "Package lists are defined"
    else
        test_fail "Package lists" "Package arrays not found in installer"
    fi
    
    # Check for key tools (use actual package names)
    local key_tools=("git" "fish" "bat" "eza" "fd-find" "ripgrep" "fzf")
    local all_found=true
    
    for tool in "${key_tools[@]}"; do
        if ! grep -q "\"$tool\"" "$installer"; then
            test_fail "Package lists" "Tool '$tool' not found in package lists"
            all_found=false
        fi
    done
    
    if $all_found; then
        test_pass "All key tools are in package lists"
    fi
}

# Test symlink creation (dry run)
test_symlink_creation() {
    test_start "Symlink creation (dry run)"
    
    # Create temporary test directory
    local test_home="$TEST_TMPDIR/test-home"
    mkdir -p "$test_home"
    
    # Test symlink script has help function
    local help_output
    if help_output=$("$DOTFILES_ROOT/scripts/create-symlinks.sh" --help 2>&1); then
        if echo "$help_output" | grep -qi "help\|usage"; then
            test_pass "Symlink script has help function"
        else
            test_fail "Symlink creation" "Help output doesn't contain expected text: $help_output"
        fi
    else
        test_fail "Symlink creation" "Help command failed with exit code $?"
    fi
}

# Test git configuration template
test_git_template() {
    test_start "Git configuration template"
    
    local git_template="$DOTFILES_ROOT/config/git/gitconfig.template"
    
    if [[ -f "$git_template" ]]; then
        # Check for template variables
        if grep -q "{{NAME}}" "$git_template" && grep -q "{{EMAIL}}" "$git_template"; then
            test_pass "Git template has required variables"
        else
            test_fail "Git template" "Template variables not found"
        fi
    else
        test_fail "Git template" "Template file not found"
    fi
}

# Test automation scripts have required functions
test_automation_functions() {
    test_start "Automation script functions"
    
    local sync_script="$DOTFILES_ROOT/scripts/dotfiles-sync.sh"
    local update_script="$DOTFILES_ROOT/scripts/auto-update.sh"
    
    # Check sync script functions
    if grep -q "update_dotfiles" "$sync_script" && \
       grep -q "create_symlinks" "$sync_script" && \
       grep -q "health_check" "$sync_script"; then
        test_pass "Sync script has required functions"
    else
        test_fail "Automation functions" "Sync script missing required functions"
    fi
    
    # Check update script functions
    if grep -q "update_system_packages" "$update_script" && \
       grep -q "update_rust" "$update_script" && \
       grep -q "cleanup" "$update_script"; then
        test_pass "Update script has required functions"
    else
        test_fail "Automation functions" "Update script missing required functions"
    fi
}

# Performance test - check script execution time
test_script_performance() {
    test_start "Script performance"
    
    # Test help commands (should be fast)
    local start_time=$(date +%s)
    "$DOTFILES_ROOT/scripts/dotfiles.sh" help >/dev/null 2>&1 || true
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Help should execute in under 5 seconds (being generous for CI)
    if [[ $duration -lt 5 ]]; then
        test_pass "Help command executes quickly ($duration seconds)"
    else
        test_fail "Script performance" "Help command too slow ($duration seconds)"
    fi
}

# Test README quality
test_readme_quality() {
    test_start "README quality"
    
    local readme="$DOTFILES_ROOT/README.md"
    
    # Check for key sections
    local required_sections=("Quick Start" "Installation" "Automation" "Commands")
    local all_found=true
    
    for section in "${required_sections[@]}"; do
        if ! grep -qi "$section" "$readme"; then
            test_fail "README quality" "Section '$section' not found"
            all_found=false
        fi
    done
    
    if $all_found; then
        test_pass "README has all required sections"
    fi
}

# Main test runner
run_all_tests() {
    log_info "Starting dotfiles test suite..."
    
    setup_test_env
    
    # Run all tests
    test_script_permissions
    test_script_syntax
    test_dotfiles_cli
    test_config_files
    test_documentation
    test_package_lists
    test_symlink_creation
    test_git_template
    test_automation_functions
    test_script_performance
    test_readme_quality
    
    cleanup_test_env
    
    # Print summary
    echo
    echo "========================================"
    echo "Test Summary:"
    echo "  Total tests: $TESTS_RUN"
    echo "  Passed: $TESTS_PASSED"
    echo "  Failed: $TESTS_FAILED"
    echo "========================================"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        log_success "All tests passed! ✨"
        exit 0
    else
        log_fail "$TESTS_FAILED test(s) failed"
        exit 1
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_all_tests "$@"
fi