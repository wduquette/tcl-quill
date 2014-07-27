# Quill

Quill is a build tool for Tcl/Tk projects, inspired by
[Leiningen](http://leiningen.org).  It is intended to:

* Create new skeleton project trees.
* Manage dependencies
  * External and internal
* Run tests
* Build deployment targets:
  * Standalone executables ("starpacks")
  * Lightweight executables ("starkits")
  * Reusable packages (teapot modules, .tm or .zip)
* Make it easy to build and deploy Tcl applications and libraries.

## Building and Installation

To install Quill, see [docs/INSTALL.md](./docs/INSTALL.md).

To build Quill from scratch, see [docs/BUILD.md](./docs/BUILD.md).


## Assumptions

At present, Quill relies heavily on ActiveState's package repository
tool-chain, and particularly on "teacup" (delivered with ActiveTcl)
and "tclapp" (delivered as part of TclDevKit).  In particular, Quill
assumes the following:

* ActiveTcl 8.6.1 or later is installed on the system.
* ActiveTcl is on the path, and can be run as "tclsh" at the
  command line
* For building executables, TclDevKit 5.0 or later is installed on
  the system, and the "tclapp" tool can be run as "tclapp" at the
  command line.
* For Unix-based systems, including Mac OS X, it is assumed for
  certain operations that either ActiveTcl is installed in the
  user's home directory or the user has access to the "sudo"
  command.

## Ways to Help

I'm developing Quill on OS X, but I'm trying to write it so that will work 
on OS X, Linux, and Windows, and on Unix in general.  For Windows, I'm 
using that Quill is being used from a MinGW bash shell.

However, for personal work I only have access to OS X.  Thus, it would be 
a great help to me to have users try it out on other platforms and submit
bug reports and patches.

Note that platform-specific code is concentrated in `lib/quillapp/plat.tcl`.
That's where Quill finds external programs like `tkcon` and `teacup`, for
example.