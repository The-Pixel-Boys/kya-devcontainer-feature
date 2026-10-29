# kya-devcontainer-feature

A [Dev Container Feature](https://containers.dev/implementors/features/) that installs [Shield KYA](https://github.com/The-Pixel-Boys/shield-kya) (`@shield-agent/kya`, the Know Your Agent CLI) into a dev container with npm.

## Usage

Add the feature to `devcontainer.json`:

```json
{
  "features": {
    "ghcr.io/the-pixel-boys/kya-devcontainer-feature/kya:1": {}
  }
}
```

Pin a CLI version and wire the Claude Code hook:

```json
{
  "features": {
    "ghcr.io/the-pixel-boys/kya-devcontainer-feature/kya:1": {
      "version": "0.32.7",
      "installHook": true
    }
  }
}
```

## Options

| Option | Type | Default | Meaning |
|---|---|---|---|
| `version` | string | `latest` | The `@shield-agent/kya` version to install from npm. |
| `installHook` | boolean | `false` | Runs `kya connect claude --hooks` for the remote user. This writes the Claude Code `PreToolUse` hook and the MCP entry in that user's home directory. It takes effect in new Claude Code sessions. |

## What the feature does

1. Depends on the `node` feature, so Node.js is present.
2. Checks the Node.js version. The CLI needs Node.js 22 or newer. If Node.js is missing or older, the feature installs nothing and prints a message. The build continues.
3. Runs `npm install -g @shield-agent/kya@<version>`. If a pinned version is already installed, npm is not run again.
4. Runs `kya --version`. If that fails, the build fails.
5. Needs no secrets. No API key is read or written.

The CLI is advisory and fails open. It does not replace a hosted policy plane. See the CLI README for what it enforces.

## Requirements

- A Linux container with `npm` and Node.js 22 or newer. The `node` feature provides both.
- Network access to the npm registry during the build.

## Test

The tests use the Dev Container CLI (`@devcontainers/cli`):

```sh
npm install -g @devcontainers/cli@0.89.0
devcontainer features test -f kya -i mcr.microsoft.com/devcontainers/base:ubuntu .
devcontainer features test --global-scenarios-only -i mcr.microsoft.com/devcontainers/base:ubuntu .
```

Scenarios in `test/_global/scenarios.json`:

- `pinned-version`: installs `0.32.7` and checks the printed version.
- `install-hook`: sets `installHook: true` and checks that the Claude Code hook file contains the KYA hook.

The install script also has a shell lint step in CI (`shellcheck -s sh src/kya/install.sh`).

## Listing

To list this feature in the Dev Container Feature index, add this entry to `collection-index.yml` in `devcontainers/devcontainers.github.io`. The entry is not added by this repo.

```yaml
- name: Shield KYA
  maintainer: MFR Limited
  contact: https://github.com/The-Pixel-Boys/kya-devcontainer-feature/issues
  repository: https://github.com/The-Pixel-Boys/kya-devcontainer-feature
  ociReference: ghcr.io/the-pixel-boys/kya-devcontainer-feature
```

## Release

Push a tag that starts with `v` to publish. The `release.yml` workflow publishes the feature to GHCR with `devcontainers/action`. The workflow does not run on normal pushes or pull requests. The version that is published comes from `src/kya/devcontainer-feature.json`.

## License

MIT. See [LICENSE](LICENSE).
