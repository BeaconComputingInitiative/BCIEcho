#!/usr/bin/env bash
# BEACON COMPUTING INITIATIVE (BCI)
# Developer Seal: CJB-DEV-2026
# Component: BCIEcho — Local Kali Source Publication v1.0
# Purpose: Import actual local source without publishing telemetry.
# Integrity: Generates docs/LOCAL_SNAPSHOT_SHA256SUMS.txt.

set -Eeuo pipefail
umask 077

REPO="BeaconComputingInitiative/BCIEcho"
SOURCE="${BCIECHO_SOURCE:-$HOME/BCIEcho}"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
STAGE="$(mktemp -d)"
trap 'rm -rf -- "$STAGE"' EXIT

fatal() { printf '[BCI][ERROR] %s\n' "$*" >&2; exit 1; }
note() { printf '[BCI] %s\n' "$*"; }

# Ready if and only if the authoritative local source exists
# and the required QML/bridge entry points are present.
if [[ -f "$SOURCE/main_qml.py" &&
      -f "$SOURCE/bciecho_qml/bridge.py" &&
      -f "$SOURCE/qml/Main.qml" ]]; then
  note "Source verified: $SOURCE"
else
  fatal "Incomplete BCIEcho source at $SOURCE. No push attempted."
fi

for tool in git gh rsync sha256sum grep find; do
  command -v "$tool" >/dev/null 2>&1 || fatal "Missing dependency: $tool"
done

gh auth status >/dev/null 2>&1 || fatal "Run 'gh auth login' first."
gh auth setup-git --hostname github.com >/dev/null 2>&1 ||
  fatal "Unable to configure GitHub CLI Git authentication."

note 'Cloning existing BCIEcho repository.'
git clone --quiet "https://github.com/$REPO.git" "$STAGE/repo"
TARGET="$STAGE/repo"

# Exclusions precede includes. Preserve root README + publication docs.
rsync -a --prune-empty-dirs \
  --exclude='.git/' --exclude='.venv/' --exclude='.venv-*/' \
  --exclude='venv/' --exclude='node_modules/' --exclude='__pycache__/' \
  --exclude='.pytest_cache/' --exclude='backups/' --exclude='logs/' \
  --exclude='recordings/' --exclude='reports/' --exclude='results/' \
  --exclude='private/' --exclude='secrets/' --exclude='data/' \
  --exclude='.env' --exclude='.env.*' --exclude='*.pem' \
  --exclude='*.key' --exclude='*.p12' --exclude='*.pfx' \
  --exclude='*.wav' --exclude='*.mp3' --exclude='*.flac' \
  --exclude='*.db' --exclude='*.sqlite*' --exclude='*.jsonl' \
  --exclude='room_survey_*.json' --exclude='*token*' \
  --exclude='*credential*' --exclude='/README.md' \
  --include='*/' --include='*.py' --include='*.qml' \
  --include='*.js' --include='*.sh' --include='*.md' \
  --include='*.toml' --include='*.txt' --include='*.json' \
  --include='*.yaml' --include='*.yml' --include='*.cfg' \
  --include='*.ini' --include='*.qrc' \
  --exclude='*' "$SOURCE/" "$TARGET/"

cd "$TARGET"
git add -A

# Prevent obviously sensitive material from entering a public repository.
if git diff --cached --unified=0 -- . ':!docs/LOCAL_SNAPSHOT_SHA256SUMS.txt' |
   grep -E '^[+][^+].*(BEGIN (RSA |OPENSSH |EC )?PRIVATE KEY|ghp_[A-Za-z0-9]{20}|github_pat_[A-Za-z0-9_]{20}|sk-proj-[A-Za-z0-9_-]{20})'; then
  fatal 'Possible credential detected in staged source; nothing pushed.'
fi

if git diff --cached --check; then
  note 'Whitespace and patch-format check passed.'
else
  fatal 'Git diff check failed. No push attempted.'
fi

install -d -m 700 docs
MANIFEST='docs/LOCAL_SNAPSHOT_SHA256SUMS.txt'
{
  printf '# BEACON COMPUTING INITIATIVE | Developer Seal: CJB-DEV-2026\n'
  printf '# Snapshot UTC: %s\n' "$STAMP"
  printf '# Verify hashes from repository root with sha256sum -c\n'
} > "$MANIFEST"

while IFS= read -r -d '' path; do
  if [[ "$path" != "$MANIFEST" && -f "$path" ]]; then
    sha256sum -- "$path" >> "$MANIFEST"
  fi
done < <(git ls-files -z)

chmod 600 "$MANIFEST"
git add "$MANIFEST"

if git diff --cached --quiet; then
  note 'No local-source changes to publish.'
  exit 0
fi

note 'Staged changes:'
git diff --cached --stat

LOGIN="$(gh api user --jq '.login')"
ACCOUNT_ID="$(gh api user --jq '.id')"
[[ -n "$LOGIN" && -n "$ACCOUNT_ID" ]] ||
  fatal 'GitHub account identity unavailable.'
git config user.name "$LOGIN"
git config user.email "${ACCOUNT_ID}+${LOGIN}@users.noreply.github.com"

git commit -qm "snapshot: publish BCIEcho local source $STAMP"
COMMIT="$(git rev-parse HEAD)"
git push origin HEAD:main

REMOTE_COMMIT="$(git ls-remote origin refs/heads/main | cut -f1)"

# Publication succeeds if and only if remote main equals the local
# committed tree. A successful git push alone is not sufficient.
if [[ "$REMOTE_COMMIT" == "$COMMIT" ]]; then
  note "PUBLISHED: https://github.com/$REPO/commit/$COMMIT"
  note "SHA-256 manifest: $MANIFEST"
  sha256sum "$MANIFEST"
else
  fatal 'Remote HEAD verification failed; inspect GitHub repository.'
fi
