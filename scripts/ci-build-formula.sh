#!/usr/bin/env bash
# Build one formula of this tap from source and check the result the way
# `brew test-bot` checks a formula it builds: run its `test do` block, verify
# its dynamic linkage against its declared dependencies, and audit it strictly
# with the keg installed.
#
# Usage: scripts/ci-build-formula.sh <formula-name>
#
# CI runs this once per formula (see .github/workflows/tests.yml); it works
# the same locally on a machine where the tap is installed.
set -euo pipefail

if [[ $# -ne 1 ]]
then
  echo "usage: $0 <formula-name>" >&2
  exit 2
fi

readonly formula="FranklinChen/tap/$1"

# Head-only formulae (hugs, camllight) have no stable spec, so install and test
# both need --HEAD. Ask Homebrew rather than keep a list here that could drift
# from Formula/: `versions.stable` is a version string, or JSON null.
# Each step is its own assignment so that `set -e` sees a failure of either.
info="$(brew info --json=v2 "${formula}")"
stable="$(jq -r '.formulae[0].versions.stable' <<<"${info}")"
flags=(--verbose)
if [[ "${stable}" == null ]]
then
  flags+=(--HEAD)
fi

brew install --build-from-source "${flags[@]}" "${formula}"
brew test "${flags[@]}" "${formula}"
brew linkage --test "${formula}"
brew audit --strict "${formula}"
