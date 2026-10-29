#!/bin/bash
set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "kya is on PATH" command -v kya
check "Claude Code hook is wired for the remote user" bash -c "grep -q 'hook --host claude' \"\$HOME/.claude/settings.json\""

reportResults
