# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Homebrew tap (`FranklinChen/tap`) containing custom formulae for software not in the main Homebrew repository. Users install via `brew tap FranklinChen/tap`.

## Repository Structure

- `Formula/` — Homebrew formula Ruby files (one `.rb` per package)
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
