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

# The environment `brew test-bot` sets when it builds a formula: installing a
# dependency must not update Homebrew or upgrade unrelated installed software.
# Also skip the cleanup `brew install` runs afterwards (on all packages every
# 30 days), which on a workstation has nothing to do with this check.
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK=1
export HOMEBREW_NO_INSTALL_CLEANUP=1

if [[ $# -ne 1 ]]
then
  echo "usage: $0 <formula-name>" >&2
  exit 2
fi

readonly formula="FranklinChen/tap/$1"

# One `brew info` answers both questions below. Each step is its own
# assignment so that `set -e` sees a failure of either command.
info="$(brew info --json=v2 "${formula}")"

# `brew install` on an installed formula only warns and rebuilds nothing, so
# the checks below would silently pass against an old build. CI runners start
# clean; on a workstation, uninstall first to really test the formula.
installed="$(jq '.formulae[0].installed | length' <<<"${info}")"
if [[ "${installed}" -ne 0 ]]
then
  echo "$0: ${formula} is already installed; run 'brew uninstall ${formula}' first" >&2
  exit 1
fi

# Head-only formulae (hugs, camllight) have no stable spec, so install and test
# both need --HEAD. Ask Homebrew rather than keep a list here that could drift
# from Formula/: `versions.stable` is a version string, or JSON null.
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
