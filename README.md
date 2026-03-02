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

## Sather

[GNU Sather](https://www.gnu.org/software/sather/) is an object-oriented language similar to Eiffel, designed to be simple, efficient, and safe. It compiles to C as an intermediate step. The compiler requires the [Boehm garbage collector](https://www.hboehm.info/gc/).

```console
$ brew install FranklinChen/tap/sather
```

### History

Sather was originally developed at the [International Computer Science Institute](https://www.icsi.berkeley.edu/) (ICSI) at UC Berkeley. Development there halted at the end of 1998 with the beta version 1.2b, and the project was adopted into [GNU](https://savannah.gnu.org/projects/sather) by Norbert Nemec, with ICSI agreeing to change the license to GPL/LGPL.

Keith Hopper at the University of Waikato (New Zealand) then worked on a 1.3 release, producing seven beta releases (1.3-beta-1 through 1.3-beta-7) between 2000 and 2001. A stable 1.3 was never released. In April 2002, Nemec [declared the project "completely orphaned"](https://lists.gnu.org/archive/html/info-sather/2002-04/msg00026.html) after Hopper could no longer continue due to health constraints and lack of personnel. Nemec characterized it as "hibernation" rather than death, leaving the door open for revival.

A 1.2.3 bugfix release appeared in July 2007. In December 2010 a new package maintainer was [announced on Savannah](https://savannah.gnu.org/projects/sather), but no further development has occurred. The project is effectively dead, and 1.2.3 is the final release.
