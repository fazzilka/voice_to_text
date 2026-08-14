#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

fail() {
    printf 'VoiceToText security audit: %s\n' "$*" >&2
    exit 1
}

for command_name in git rg file sed; do
    command -v "$command_name" >/dev/null 2>&1 \
        || fail "required command is missing: $command_name"
done

git fsck --full --strict >/dev/null

pinned_revision="$(sed -n 's/.*revision: "\([0-9a-f]*\)".*/\1/p' swift/Package.swift)"
resolved_revision="$(sed -n 's/.*"revision"[[:space:]]*:[[:space:]]*"\([0-9a-f]*\)".*/\1/p' swift/Package.resolved)"
[[ "$pinned_revision" =~ ^[0-9a-f]{40}$ ]] \
    || fail "FluidAudio is not pinned to a full commit SHA"
[[ "$resolved_revision" == "$pinned_revision" ]] \
    || fail "Package.resolved does not match the FluidAudio pin"

while IFS= read -r tracked_file; do
    kind="$(file -b "$tracked_file")"
    case "$kind" in
        Mach-O*|ELF*|PE32*|MS-DOS\ executable*|current\ ar\ archive*)
            fail "tracked compiled executable or archive: $tracked_file ($kind)"
            ;;
    esac
done < <(git ls-files)

while read -r mode _ _ tracked_file; do
    [[ "$mode" == "100755" ]] || continue
    [[ "$tracked_file" == *.sh ]] \
        || fail "unexpected executable tracked file: $tracked_file"
    head -n 1 "$tracked_file" | rg -q '^#!/bin/(ba)?sh$' \
        || fail "executable script has an unexpected interpreter: $tracked_file"
done < <(git ls-files -s)

if rg -n -i \
    -g '!security-audit.sh' \
    'spctl[[:space:]]+--master-disable|xattr[[:space:]]+-[cdr]|chmod[[:space:]]+(-R[[:space:]]+)?777|(^|[;&|[:space:]])eval[[:space:]]|base64[^|]*(--decode|-d)|curl[^|]*\|[[:space:]]*(ba)?sh|wget[^|]*\|[[:space:]]*(ba)?sh' \
    install.sh uninstall.sh scripts; then
    fail "forbidden security-bypass, obfuscation, or remote-shell pattern found"
fi

if LC_ALL=C rg -n $'[\u202A-\u202E\u2066-\u2069]' \
    install.sh uninstall.sh scripts core swift/Sources .github; then
    fail "bidirectional control character found in executable source"
fi

printf 'VoiceToText security audit passed; FluidAudio=%s.\n' "$pinned_revision"
