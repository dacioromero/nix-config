#!/usr/bin/env bash
set -euxo pipefail
SYSTEM=$(nix build ".#nixosConfigurations.$1.config.system.build.toplevel" --no-link --print-out-paths)
nix copy --to "ssh://$2" "$SYSTEM"
ssh "root@$2" "$SYSTEM/bin/switch-to-configuration $3"
