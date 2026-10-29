#!/bin/sh
# Installs Shield KYA (@shield-agent/kya) globally with npm.
# Options arrive as env vars: VERSION (default latest), INSTALLHOOK ("true" or "false").
# Needs no secrets. Running it twice is safe.
set -eu

PKG="@shield-agent/kya"
# ponytail: must match engines.node of the npm package. Change it only here.
MIN_NODE_MAJOR=22
VERSION="${VERSION:-latest}"
INSTALLHOOK="${INSTALLHOOK:-false}"

if ! command -v node >/dev/null 2>&1; then
  echo "kya: Node.js is not installed. Nothing was installed. Add the node feature or install Node.js ${MIN_NODE_MAJOR} or newer."
  exit 0
fi

NODE_MAJOR=$(node -p "process.versions.node.split('.')[0]")
if [ "$NODE_MAJOR" -lt "$MIN_NODE_MAJOR" ]; then
  echo "kya: Node.js $(node -v) is older than ${MIN_NODE_MAJOR}. Nothing was installed. Use Node.js ${MIN_NODE_MAJOR} or newer."
  exit 0
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "kya: npm was not found next to node." >&2
  exit 1
fi

KYA_BIN="$(npm prefix -g)/bin/kya"

# Idempotent: a pinned version that is already installed is not installed again.
if [ "$VERSION" != "latest" ] && [ -x "$KYA_BIN" ] && [ "$("$KYA_BIN" --version 2>/dev/null)" = "$VERSION" ]; then
  echo "kya: ${VERSION} is already installed. Skipping npm."
else
  npm install -g "${PKG}@${VERSION}"
fi

# Assign first: a failing command inside echo "$(...)" would not stop the script under set -e.
INSTALLED_VERSION=$("$KYA_BIN" --version)
echo "kya: ${INSTALLED_VERSION} is installed at ${KYA_BIN}."

if [ "$INSTALLHOOK" = "true" ]; then
  REMOTE_USER_NAME="${_REMOTE_USER:-root}"
  REMOTE_HOME="${_REMOTE_USER_HOME:-/root}"
  # kya connect writes the remote user's ~/.claude.json and ~/.claude/settings.json.
  # Run it as that user so the files are not owned by root.
  if [ "$REMOTE_USER_NAME" = "root" ]; then
    env HOME="$REMOTE_HOME" KYA_TELEMETRY=0 "$KYA_BIN" connect claude --hooks
  else
    runuser -u "$REMOTE_USER_NAME" -- env HOME="$REMOTE_HOME" PATH="$PATH" KYA_TELEMETRY=0 "$KYA_BIN" connect claude --hooks
  fi
  grep -q "hook --host claude" "$REMOTE_HOME/.claude/settings.json"
  echo "kya: Claude Code hook wired for ${REMOTE_USER_NAME}. It takes effect in new sessions."
fi
