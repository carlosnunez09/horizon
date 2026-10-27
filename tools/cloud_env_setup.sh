#!/usr/bin/env bash
# Setup script for a Claude Code cloud environment that builds and tests Horizon.
# Paste it into the environment's "Setup script" box. It installs the system
# libraries the game needs and warms the Cargo cache. It does not fetch Mojang's
# files: Horizon imports them from your own Minecraft install (see the note below).
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y --no-install-recommends \
  libasound2-dev libudev-dev pkg-config xvfb

# Warm the dependency cache for the game workspace (no compile, just downloads).
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo /home/user/horizon)"
cargo fetch --locked

# Keep scratch game data away from any real player folders.
mkdir -p /tmp/horizon-scratch
cat >> ~/.bashrc <<'EOF'
export HORIZON_NO_AUDIO=1
export HORIZON_LAUNCHER_NO_SELF_UPDATE=1
EOF

# Vanilla data (.local/): needs JDK 25 and your own Minecraft Java install, then
#   python3 tools/lab.py prepare && python3 tools/lab.py decompile
# Without it, `python3 tools/pr_ready.py --quick` and unit tests still work, and
# CI runs the parity harnesses on your PR.
