# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Homebrew tap (`FranklinChen/tap`) containing custom formulae for software not in the main Homebrew repository. Users install via `brew tap FranklinChen/tap`.

## Repository Structure

- `Formula/`: Homebrew formula Ruby files (one `.rb` per package)
  - `cm3.rb`: Critical Mass Modula-3 compiler (three-stage bootstrap: C++ to bootstrap cm3 to full self-compile)
  - `f2c.rb`: Fortran-to-C compiler (versioned release from netlib, with a `resource` block for `libf2c`)
  - `hugs.rb`: Hugs98+ Haskell implementation (head-only, from personal fork `FranklinChen/hugs98-plus-Sep2006`)
  - `sather.rb`: GNU Sather compiler (source build, depends on bdw-gc; wrapper sets SATHER_HOME)
  - `unicon.rb`: Unicon compiler (Icon descendant; conflicts with the icon formula)
  - `camllight.rb`: Caml Light bytecode ML system (head-only, from personal fork `FranklinChen/camllight`; wrappers bake LIBDIR in at build time)

## Common Commands

```bash
# Install a versioned formula
brew install FranklinChen/tap/f2c

# Install a head-only formula
brew install --HEAD FranklinChen/tap/hugs

# Force a local source build: run this after editing a formula, before committing
brew install --build-from-source FranklinChen/tap/<formula>

# Run the formula's `test do` block against the installed binary
brew test FranklinChen/tap/<formula>

# Audit for correctness and style problems (run before every commit).
# Current Homebrew disabled the path form; audit by tap-qualified name, which
# reads the installed tap clone, so commit (or copy) your edit there first.
brew audit --strict FranklinChen/tap/<formula>

# Ruby style check (a subset of what audit covers)
brew style Formula/<formula>.rb

# Check upstream for a newer version (uses the formula's `livecheck` block)
brew livecheck FranklinChen/tap/<formula>
```

## Formula Conventions

- Each formula is a Ruby class inheriting from `Formula`.
- Formulae build from source using `system` calls to `make`/`configure`.
- These are old codebases, so most formulae suppress warnings-as-errors from pre-ANSI/K&R C on modern clang (`-Wno-error=implicit-function-declaration`, `-Wno-error=implicit-int`, and similar). Each threads the flags through whatever its build system exposes: `hugs`/`f2c` via `ENV["CFLAGS"]`, `camllight` via make's `OPTS`, `sather` via `inreplace` of its `Makefile`/`CONFIG`. See [macOS Porting Patterns](#macos-porting-patterns).
- Include a `test do` block that verifies the installed binary works.
- Head-only formulae (like `hugs`) require `--HEAD` for installation; versioned formulae (like `f2c`) do not.
- Versioned formulae (`cm3`, `f2c`, `unicon`) carry a `livecheck` block so `brew livecheck` can detect new upstream releases. Head-only formulae have nothing to check.
- License stanzas use an SPDX string where one fits (`unicon`, `sather`). Historical licenses with no SPDX id use `license :cannot_represent` (`cm3`) or omit the stanza with an explanatory comment (`camllight`); `f2c` (public-domain netlib code) omits it too.
- Every formula must have a corresponding section in `README.md` documenting what the software is, the install command, and a brief history.
- Every formula must have update instructions in the "Updating Formulae" section below.

## macOS Porting Patterns

Every package here predates Apple Silicon and most predate macOS, so the formulae share a handful of recurring fixes. Knowing these saves rediscovering them per formula:

- **Re-signing Mach-O binaries.** `cm3` and `unicon` both run `codesign -fs -` over their installed binaries at the end of `install`. Their build steps rewrite the executables after linking (cm3's backend relinks; unicon's `patchstr` embeds install paths), which invalidates the linker's ad-hoc code signature; an invalid signature makes macOS `SIGKILL` the binary on launch. The loop skips symlinks and non-Mach-O files, detected via `file -b`.
- **Baking the prefix in, or wrapping.** Homebrew installs into a versioned Cellar directory that is symlinked into the prefix, which breaks programs that locate their own runtime by path. Three solutions appear here: `camllight` bakes `LIBDIR` into its wrapper scripts at build time, so `LIBDIR` must be set on the `world` step, not just `install`; `sather` installs its runtime tree into `libexec` and ships a `bin/sacomp` shell wrapper that exports `SATHER_HOME`; `unicon` rewrites self-executing `icode` programs into wrappers that `exec iconx` with an absolute path, because icode cannot be read back through the Cellar symlink.
- **`inreplace` for Linux-isms.** `sather` is the heaviest example: it patches its `Makefile` and headers to swap `/lib/cpp` for `cc -E`, drop the missing `<values.h>`, and replace `echo -n` with `printf` (macOS `/bin/sh` `echo` has no `-n`). When a source build assumes GNU/Linux, prefer `inreplace` over carrying patch files.
- **Old-C warning suppression** (see Formula Conventions above) is the fourth recurring fix.

## Updating Formulae

When a new upstream release is available, update the formula as described below. Always recompute SHA256 hashes from the actual downloaded files (`curl -sL <url> | shasum -a 256`), never guess.

### cm3.rb

Upstream releases are at <https://github.com/modula3/cm3/releases>. Three things need updating:

1. **Main source URL + SHA256**: replace the tag in the `url` (e.g. `d5.12.0` to `d5.13.0`) and recompute the `sha256` for the new archive.
2. **Bootstrap resource URL + SHA256**: replace the tag and version in the resource `url`. The asset filename includes the version (e.g. `cm3-boot-AMD64_LINUX-d5.12.0.tar.xz`). Despite the `AMD64_LINUX` name, this tarball works on all 64-bit little-endian Unix including macOS (both Intel and Apple Silicon); there is no separate macOS asset. Check the release assets page for the exact filename, then recompute the `sha256`.
3. The version is inferred from the URL, so no separate `version` field to change.

### f2c.rb

Upstream is at <https://www.netlib.org/f2c/>. The URLs (`src.tgz`, `libf2c.zip`) are rolling tarballs that always point to the latest version; they do not change between releases.

1. **`version`**: update the date string (e.g. `20250303`) to reflect the new release date (check the netlib page or the source for a date).
2. **`sha256`**: recompute for both the main `src.tgz` and the `libf2c` resource `libf2c.zip`.

### hugs.rb

Head-only formula: always builds from the latest git commit of <https://github.com/FranklinChen/hugs98-plus-Sep2006>. No version or SHA256 to update. Only update if dependencies or build steps change.

### sather.rb

Dead project (last release 1.2.3 in July 2007, declared orphaned in 2002). No updates expected. If somehow a new release appeared on <https://ftp.nluug.nl/gnu/sather/>, update the `url` tag and recompute `sha256`.

### unicon.rb

Upstream releases are at <https://github.com/uniconproject/unicon/releases>.

1. **`url`**: replace the tag (e.g. `13.2` to `13.3`).
2. **`sha256`**: recompute for the new archive.

### camllight.rb

Head-only formula: always builds from the latest git commit of <https://github.com/FranklinChen/camllight>. No version or SHA256 to update. The build passes the project's modern-compiler warning flags through make's `OPTS` variable, and sets `BINDIR`/`LIBDIR` on the `world` step (not only on `install`) because the wrapper scripts (`camlc`, `camllight`, `camlmktop`) bake `LIBDIR` in at build time. Only update if build steps change. If a stable release tag is ever cut on the camllight repo, switch from head-only to `url` + `sha256` (as in `f2c`/`unicon`).
