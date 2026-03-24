# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Homebrew tap (`FranklinChen/tap`) containing custom formulae for software not in the main Homebrew repository. Users install via `brew tap FranklinChen/tap`.

## Repository Structure

- `Formula/` — Homebrew formula Ruby files (one `.rb` per package)
  - `cm3.rb` — Critical Mass Modula-3 compiler (three-stage bootstrap: C++ → bootstrap cm3 → full self-compile)
  - `f2c.rb` — Fortran-to-C compiler (versioned release from netlib, with a `resource` block for `libf2c`)
  - `hugs.rb` — Hugs98+ Haskell implementation (head-only, from personal fork `FranklinChen/hugs98-plus-Sep2006`)

## Common Commands

```bash
# Install a versioned formula
brew install FranklinChen/tap/f2c

# Install a head-only formula
brew install --HEAD FranklinChen/tap/hugs

# Test a formula
brew test FranklinChen/tap/<formula>

# Audit a formula for style issues
brew audit --strict Formula/<formula>.rb

# Lint/style check
brew style Formula/<formula>.rb
```

## Formula Conventions

- Each formula is a Ruby class inheriting from `Formula`.
- Formulae build from source using `system` calls to `make`/`configure`.
- Both formulae set `-Wno-error=implicit-function-declaration -Wno-error=implicit-int` in CFLAGS to handle older C code that triggers errors on modern compilers.
- Include a `test do` block that verifies the installed binary works.
- Head-only formulae (like `hugs`) require `--HEAD` for installation; versioned formulae (like `f2c`) do not.
- Every formula must have a corresponding section in `README.md` documenting what the software is, the install command, and a brief history.
- Every formula must have update instructions in the "Updating Formulae" section below.

## Updating Formulae

When a new upstream release is available, update the formula as described below. Always recompute SHA256 hashes from the actual downloaded files (`curl -sL <url> | shasum -a 256`), never guess.

### cm3.rb

Upstream releases are at <https://github.com/modula3/cm3/releases>. Three things need updating:

1. **Main source URL + SHA256** — replace the tag in the `url` (e.g. `d5.11.10` → `d5.12.0`) and recompute the `sha256` for the new archive.
2. **Bootstrap resource URL + SHA256** — replace the tag and version in the resource `url`. The asset filename includes the version (e.g. `cm3-boot-AMD64_LINUX-d5.11.10.tar.xz`). Despite the `AMD64_LINUX` name, this tarball works on all 64-bit little-endian Unix including macOS (both Intel and Apple Silicon) — there is no separate macOS asset. Check the release assets page for the exact filename, then recompute the `sha256`.
3. The version is inferred from the URL, so no separate `version` field to change.

### f2c.rb

Upstream is at <https://www.netlib.org/f2c/>. The URLs (`src.tgz`, `libf2c.zip`) are rolling tarballs that always point to the latest version — they do not change between releases.

1. **`version`** — update the date string (e.g. `20250303`) to reflect the new release date (check the netlib page or the source for a date).
2. **`sha256`** — recompute for both the main `src.tgz` and the `libf2c` resource `libf2c.zip`.

### hugs.rb

Head-only formula — always builds from the latest git commit of <https://github.com/FranklinChen/hugs98-plus-Sep2006>. No version or SHA256 to update. Only update if dependencies or build steps change.

### sather.rb

Dead project (last release 1.2.3 in July 2007, declared orphaned in 2002). No updates expected. If somehow a new release appeared on <https://ftp.nluug.nl/gnu/sather/>, update the `url` tag and recompute `sha256`.

### unicon.rb

Upstream releases are at <https://github.com/uniconproject/unicon/releases>.

1. **`url`** — replace the tag (e.g. `13.2` → `13.3`).
2. **`sha256`** — recompute for the new archive.
