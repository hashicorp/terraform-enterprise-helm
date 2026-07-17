#!/usr/bin/env bash
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: MPL-2.0
#
# Template coverage for the Admin Console access mode (TF-38319).
#
# Renders the chart across the access-mode truth table and asserts the ConfigMap
# TFE_ADMIN_CONSOLE_ACCESS_MODE value matches, that omitting the value preserves
# the legacy unset behaviour (key absent), and that an unsupported value fails
# rendering. Dependency-free: needs only `helm`.

set -euo pipefail

CHART_DIR="${1:-.}"
KEY="TFE_ADMIN_CONSOLE_ACCESS_MODE"
failures=0

render() {
  # Prints the rendered ConfigMap access-mode line, if any.
  helm template "$CHART_DIR" "$@" 2>/dev/null | grep "$KEY" || true
}

expect_value() {
  local mode="$1" expected="  $KEY: \"$1\""
  local got
  got="$(render --set "tfe.adminConsole.accessMode=$mode")"
  if [[ "$got" == "$expected" ]]; then
    echo "PASS: accessMode=$mode renders $KEY=\"$mode\""
  else
    echo "FAIL: accessMode=$mode rendered [$got], expected [$expected]"
    failures=$((failures + 1))
  fi
}

# port / both / disabled must each render their value verbatim.
expect_value port
expect_value both
expect_value disabled

# Omitting the value (unset) must not render the key, preserving legacy behaviour.
if [[ -z "$(render)" ]]; then
  echo "PASS: unset accessMode omits $KEY (legacy default preserved)"
else
  echo "FAIL: unset accessMode should omit $KEY"
  failures=$((failures + 1))
fi

# An unsupported value must fail rendering rather than pass an invalid mode
# through to the container.
if helm template "$CHART_DIR" --set tfe.adminConsole.accessMode=enabled >/dev/null 2>&1; then
  echo "FAIL: unsupported accessMode=enabled should fail rendering"
  failures=$((failures + 1))
else
  echo "PASS: unsupported accessMode=enabled fails rendering"
fi

if [[ "$failures" -ne 0 ]]; then
  echo "$failures assertion(s) failed"
  exit 1
fi
echo "All Admin Console access-mode assertions passed"
