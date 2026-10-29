#!/bin/bash
set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "pinned version 0.32.7 is installed" bash -c "kya --version | grep -qx '0.32.7'"

reportResults
