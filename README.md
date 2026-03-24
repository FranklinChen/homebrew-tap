# My Homebrew tap

To use my stuff:

```console
$ brew tap FranklinChen/tap
```

## f2c

[f2c](https://www.netlib.org/f2c/) is a Fortran 77 to C converter, originally developed at AT&T Bell Laboratories by S. I. Feldman, David M. Gay, Mark W. Maimone, and N. L. Schryer. It was based on the core of the first complete Fortran 77 compiler, the `f77` program by Feldman and Weinberger.

```console
$ brew install FranklinChen/tap/f2c
```

### History

Because `f77` was itself written in C and used a C compiler back end, f2c inherited excellent portability. After its release as free software through [Netlib](https://www.netlib.org/), f2c became one of the most common ways to compile Fortran code on systems where native Fortran compilers were unavailable or expensive. Several large Fortran libraries, including LAPACK, were made available as C libraries via f2c. The tool also influenced the development of GNU `g77`.

Unlike the other formulae in this tap, f2c is still actively maintained by David M. Gay. The Netlib source receives periodic updates, with the most recent in March 2024.

## Hugs

[Hugs](https://www.haskell.org/hugs/) (Haskell User's Gofer System) is a bytecode interpreter for Haskell 98. It is small, portable, written in C, and provides fast interactive interpretation.

```console
$ brew install --HEAD FranklinChen/tap/hugs
```

### History

Mark P. Jones developed [Gofer](http://web.cecs.pdx.edu/~mpj/pubs.html) at Yale University as a small functional programming language for teaching. On Valentine's Day 1995, he released Hugs, a derivative of Gofer with Haskell compliance. Development continued as a joint effort between the Universities of Nottingham and Yale, with Jones handing off maintainership in January 2000.

The [last official release](https://www.haskell.org/hugs/pages/users_guide/miscellaneous.html) was September 2006, a bugfix to the May 2006 release. Maintenance stopped in 2009. The formula in this tap builds from [a personal fork](https://github.com/FranklinChen/hugs98-plus-Sep2006) that patches the September 2006 source to compile on modern macOS. For serious Haskell work, use [GHC](https://www.haskell.org/ghc/) instead.

## CM3

[CM3](https://github.com/modula3/cm3) (Critical Mass Modula-3) is an open-source compiler and runtime for [Modula-3](https://en.wikipedia.org/wiki/Modula-3), a systems programming language designed for safe, modular software engineering.

```console
$ brew install FranklinChen/tap/cm3
```

**Note:** CM3 is built headless (no X11/GUI packages). For GUI support (Trestle, FormsVBT, etc.) install [XQuartz](https://www.xquartz.org/).

### History

Modula-3 was designed in the late 1980s by Luca Cardelli, Jim Donahue, Mick Jordan, Bill Kalsow, and Greg Nelson at the [Digital Equipment Corporation Systems Research Center](https://en.wikipedia.org/wiki/DEC_Systems_Research_Center) (DEC SRC) and Olivetti Research Center, as a successor to Niklaus Wirth's Modula-2. The language added garbage collection, exception handling, objects, generics, and threads to the Modula lineage while keeping the emphasis on safe, modular interfaces.

DEC SRC produced the first compiler (SRC Modula-3) and a rich set of libraries including the Trestle window toolkit and FormsVBT GUI builder. After DEC was acquired by Compaq and then Hewlett-Packard, the compiler was maintained as "Critical Mass Modula-3" (CM3) by a community that included several of the original DEC SRC engineers. The project went through periods of dormancy but was revived on GitHub, with release d5.11.10 appearing in February 2026.

## Sather

[GNU Sather](https://www.gnu.org/software/sather/) is an object-oriented language similar to Eiffel, designed to be simple, efficient, and safe. It compiles to C as an intermediate step. The compiler requires the [Boehm garbage collector](https://www.hboehm.info/gc/).

```console
$ brew install FranklinChen/tap/sather
```

### History

Sather was originally developed at the [International Computer Science Institute](https://www.icsi.berkeley.edu/) (ICSI) at UC Berkeley. Development there halted at the end of 1998 with the beta version 1.2b, and the project was adopted into [GNU](https://savannah.gnu.org/projects/sather) by Norbert Nemec, with ICSI agreeing to change the license to GPL/LGPL.

Keith Hopper at the University of Waikato (New Zealand) then worked on a 1.3 release, producing seven beta releases (1.3-beta-1 through 1.3-beta-7) between 2000 and 2001. A stable 1.3 was never released. In April 2002, Nemec [declared the project "completely orphaned"](https://lists.gnu.org/archive/html/info-sather/2002-04/msg00026.html) after Hopper could no longer continue due to health constraints and lack of personnel. Nemec characterized it as "hibernation" rather than death, leaving the door open for revival.

A 1.2.3 bugfix release appeared in July 2007. In December 2010 a new package maintainer was [announced on Savannah](https://savannah.gnu.org/projects/sather), but no further development has occurred. The project is effectively dead, and 1.2.3 is the final release.

## Unicon

[Unicon](https://github.com/uniconproject/unicon) (Unified Extended Dialect of Icon) is a very high level, goal-directed, object-oriented programming language descended from [Icon](https://en.wikipedia.org/wiki/Icon_(programming_language)). It extends Icon with objects, packages, networking, concurrency, SNOBOL4-style patterns, and optional 2D/3D graphics.

```console
$ brew install FranklinChen/tap/unicon
```

**Note:** Unicon conflicts with the `icon` formula because both install the `icont` and `iconx` binaries. If you have Icon installed, uninstall it first (`brew uninstall icon`). Unicon is a superset of Icon, so it can run Icon programs.

### History

Ralph Griswold designed Icon at the University of Arizona in the late 1970s as a successor to SNOBOL4, emphasizing goal-directed evaluation and string processing with generators. Clint Jeffery, a student of Griswold, began extending Icon in the 1990s with object orientation, networking, and POSIX interfaces. This work became Unicon, developed at the University of Texas at San Antonio and later the University of Idaho.

Unlike the other formulae in this tap, Unicon is actively maintained, with commits through 2026 and ongoing work including a language server protocol implementation. The formula builds with 2D graphics support via Homebrew's X11 libraries; 3D graphics require [XQuartz](https://www.xquartz.org/).
