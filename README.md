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

## Porting

Quill is being developed on OS X, but it is intended to be cross-platform.
Platform-specific code is concentrated in `lib/quillapp/plat.tcl`.  If 
Quill fails on a particular plaform, that's where to look.
