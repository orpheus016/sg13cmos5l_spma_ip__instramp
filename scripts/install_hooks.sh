#!/usr/bin/env bash
# Install the git hooks of this repository (.git/hooks is not versioned):  scripts/install_hooks.sh [--remove]
#   pre-commit  refreshes the schematic/layout pictures + README blocks of the cells whose .sch/.sym/.gds are committed
# An existing pre-commit hook that is not ours is kept and chained (ours runs first, then the old one).
set -euo pipefail
root="$(git rev-parse --show-toplevel)"
hook="$(git rev-parse --git-path hooks/pre-commit)"
case "$hook" in /*) ;; *) hook="$root/$hook";; esac
mark="# scripts/hooks/pre-commit (managed by scripts/install_hooks.sh)"
if [ "${1:-}" = "--remove" ]; then
  if grep -qF "$mark" "$hook" 2>/dev/null; then rm -f "$hook"; [ -f "$hook.orig" ] && mv "$hook.orig" "$hook"; echo "hook removed"; else echo "no managed hook installed"; fi
  exit 0
fi
mkdir -p "$(dirname "$hook")"
if [ -f "$hook" ] && ! grep -qF "$mark" "$hook"; then mv "$hook" "$hook.orig"; echo "existing pre-commit moved to $(basename "$hook").orig (chained)"; fi
cat >"$hook" <<HOOK
#!/usr/bin/env bash
$mark
"$root/scripts/hooks/pre-commit" || exit \$?
[ -x "$hook.orig" ] && exec "$hook.orig" "\$@"
exit 0
HOOK
chmod +x "$hook" "$root/scripts/hooks/pre-commit"
echo "installed $hook (pictures are refreshed when .sch/.sym/.gds are committed; remove with scripts/install_hooks.sh --remove)"
