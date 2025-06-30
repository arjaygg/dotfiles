#!/usr/bin/env bash
# Locale fix script to eliminate locale warnings

# Export the correct locale that exists on the system
export LANG=C.utf8
export LC_ALL=C.utf8
unset LANGUAGE

# Re-exec bash with the corrected locale
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being run directly, not sourced
    exec "$@"
fi