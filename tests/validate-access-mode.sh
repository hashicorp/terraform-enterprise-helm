#!/bin/bash
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: MPL-2.0
#
# Validates that TFE_ADMIN_CONSOLE_ACCESS_MODE is correctly rendered in the ConfigMap
# for each supported access mode value.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHART_DIR="$(dirname "$SCRIPT_DIR")"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

FAILED_TESTS=0
PASSED_TESTS=0

echo "=== Validating TFE_ADMIN_CONSOLE_ACCESS_MODE rendering ==="
echo ""

# Test helper function
test_access_mode() {
    local test_name="$1"
    local access_mode="$2"
    local expected_mode="$3"
    
    echo -n "Testing $test_name... "
    
    # Build helm template command with base values file
    local helm_args=(-f "$SCRIPT_DIR/test-values-access-mode-base.yaml")
    
    # Set accessMode via --set flag if provided
    if [ -n "$access_mode" ]; then
        helm_args+=(--set "tfe.adminConsole.accessMode=$access_mode")
    fi
    
    # Render the template
    local rendered
    if ! rendered=$(helm template test-release "$CHART_DIR" "${helm_args[@]}" 2>&1); then
        echo -e "${RED}FAILED${NC}"
        echo "  Error rendering template:"
        echo "$rendered" | sed 's/^/    /'
        ((FAILED_TESTS++))
        return 1
    fi
    
    # Extract ConfigMap data section
    local configmap
    configmap=$(echo "$rendered" | awk '/kind: ConfigMap/,/^---$/ {print}' | awk '/^data:/,/^---$/ {print}')
    
    # Check if TFE_ADMIN_CONSOLE_ACCESS_MODE is present and matches expected value
    if echo "$configmap" | grep -q "TFE_ADMIN_CONSOLE_ACCESS_MODE:"; then
        local actual_mode
        actual_mode=$(echo "$configmap" | grep "TFE_ADMIN_CONSOLE_ACCESS_MODE:" | awk '{print $2}' | tr -d '"')
        
        if [ "$actual_mode" = "$expected_mode" ]; then
            echo -e "${GREEN}PASSED${NC}"
            ((PASSED_TESTS++))
            return 0
        else
            echo -e "${RED}FAILED${NC}"
            echo "  Expected: TFE_ADMIN_CONSOLE_ACCESS_MODE: $expected_mode"
            echo "  Actual: TFE_ADMIN_CONSOLE_ACCESS_MODE: $actual_mode"
            ((FAILED_TESTS++))
            return 1
        fi
    else
        echo -e "${RED}FAILED${NC}"
        echo "  Expected: TFE_ADMIN_CONSOLE_ACCESS_MODE: $expected_mode"
        echo "  Actual: TFE_ADMIN_CONSOLE_ACCESS_MODE not found in ConfigMap"
        ((FAILED_TESTS++))
        return 1
    fi
}

# Run tests for each access mode
test_access_mode "accessMode=port" "port" "port"
test_access_mode "accessMode=both" "both" "both"
test_access_mode "accessMode=path" "path" "path"
test_access_mode "accessMode=disabled" "disabled" "disabled"
test_access_mode "accessMode=unset (empty string)" "" ""

echo ""
echo "=== Test Summary ==="
echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed: ${RED}$FAILED_TESTS${NC}"
echo ""

if [ $FAILED_TESTS -gt 0 ]; then
    echo -e "${RED}Some tests failed. Please review the output above.${NC}"
    exit 1
else
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
fi