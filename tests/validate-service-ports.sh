#!/bin/bash
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: MPL-2.0
#
# Validates that the admin-https-port is correctly exposed or hidden in the Service
# based on the TFE_ADMIN_CONSOLE_ACCESS_MODE value.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHART_DIR="$(dirname "$SCRIPT_DIR")"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

FAILED_TESTS=0
PASSED_TESTS=0

echo "=== Validating Service admin port exposure based on access mode ==="
echo ""

# Test helper function
test_service_port() {
    local test_name="$1"
    local values_file="$2"
    local should_expose_admin_port="$3"  # "true" or "false"
    
    echo -n "Testing $test_name... "
    
    # Render the template
    local rendered
    if ! rendered=$(helm template test-release "$CHART_DIR" -f "$values_file" 2>&1); then
        echo -e "${RED}FAILED${NC}"
        echo "  Error rendering template:"
        echo "$rendered" | sed 's/^/    /'
        ((FAILED_TESTS++))
        return 1
    fi
    
    # Extract Service ports section
    local service_ports
    service_ports=$(echo "$rendered" | awk '/kind: Service/,/^---$/ {print}' | awk '/^  ports:/,/^  selector:/ {print}')
    
    # Check if admin-https-port is present
    if echo "$service_ports" | grep -q "name: admin-https-port"; then
        if [ "$should_expose_admin_port" = "true" ]; then
            echo -e "${GREEN}PASSED${NC}"
            ((PASSED_TESTS++))
            return 0
        else
            echo -e "${RED}FAILED${NC}"
            echo "  Expected: admin-https-port should NOT be exposed"
            echo "  Actual: admin-https-port is present in Service"
            ((FAILED_TESTS++))
            return 1
        fi
    else
        if [ "$should_expose_admin_port" = "false" ]; then
            echo -e "${GREEN}PASSED${NC}"
            ((PASSED_TESTS++))
            return 0
        else
            echo -e "${RED}FAILED${NC}"
            echo "  Expected: admin-https-port should be exposed"
            echo "  Actual: admin-https-port not found in Service"
            ((FAILED_TESTS++))
            return 1
        fi
    fi
}

# Run tests for service port exposure
test_service_port \
    "accessMode=port (should expose admin port)" \
    "$SCRIPT_DIR/test-values-service-port-mode.yaml" \
    "true"

test_service_port \
    "accessMode=both (should expose admin port)" \
    "$SCRIPT_DIR/test-values-access-mode-both.yaml" \
    "true"

test_service_port \
    "accessMode=path (should NOT expose admin port)" \
    "$SCRIPT_DIR/test-values-service-path-mode.yaml" \
    "false"

test_service_port \
    "accessMode=disabled (should NOT expose admin port)" \
    "$SCRIPT_DIR/test-values-access-mode-disabled.yaml" \
    "false"

test_service_port \
    "accessMode=unset (should expose admin port - legacy)" \
    "$SCRIPT_DIR/test-values-access-mode-unset.yaml" \
    "true"

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
