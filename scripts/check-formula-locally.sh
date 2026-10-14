#!/usr/bin/env bash
# Run the CI check (scripts/ci-build-formula.sh) on a workstation against the
# formula in THIS working tree.
#
# Usage: scripts/check-formula-locally.sh <formula-name>
#
# `brew install FranklinChen/tap/<formula>` and every other tap-qualified brew
# command read Homebrew's own clone of the tap (`brew --repo FranklinChen/tap`),
# not this working tree, so an edited formula is silently ignored. This script
# copies it into that clone, runs the CI check, and restores the clone on exit
# whether the check passed or not. (CI needs no copy: there the clone is the
# checkout under test.)
set -euo pipefail

if [[ $# -ne 1 ]]
then
  echo "usage: $0 <formula-name>" >&2
  exit 2
fi

readonly name="$1"
root="$(cd "$(dirname "$0")/.." && pwd -P)"
readonly root
tap="$(brew --repo FranklinChen/tap)"
readonly tap
readonly source="${root}/Formula/${name}.rb"

if [[ ! -f "${source}" ]]
then
  echo "$0: no formula ${source}" >&2
  exit 2
fi

# Refuse local edits in Homebrew's clone: restoring it would destroy them.
tap_changes="$(git -C "${tap}" status --porcelain)"
if [[ -n "${tap_changes}" ]]
then
  echo "$0: ${tap} has local changes; resolve them first:" >&2
  echo "${tap_changes}" >&2
  exit 1
fi

# Undo exactly the one file this script writes, nothing else: check a tracked
# formula out again, or remove one the clone does not have.
readonly target="${tap}/Formula/${name}.rb"
restore() {
  if git -C "${tap}" ls-files --error-unmatch "Formula/${name}.rb" >/dev/null 2>&1
  then
    git -C "${tap}" checkout -q -- "Formula/${name}.rb"
  else
    rm -f "${target}"
  fi
}
trap restore EXIT
cp "${source}" "${target}"

"${root}/scripts/ci-build-formula.sh" "${name}"
