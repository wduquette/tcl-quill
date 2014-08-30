# Project TODO List

This is the official list of work to be done.

# Next

* Fix the distributions in project.quill; they contain different things.
* quill new lib
* Update release docs.
* Building exes:
  * Allow "exe" apptype for building in just the local flavor, whatever it is.
* Add check on "teacup" executable for build 298288 or later.

* New tool architecture
* Infrastructure for tabular output
* Improved 'quill info' output
* 'quill teapot list' to list contents of local teapot.

# Requirements For Quill 0.2.0

* Support for other versions of TCL/TK.
  * I.e, use Quill for Tcl 8.5 or 8.6 projects.  Can also support 8.4 if
    anyone wants it. DONE
  * Support cross-platform starpack build. DONE
  * Support for 'quill dist' to package up a distribution for different
    platforms. DONE.
    * Includes bin/, docs/, provided lib .zip's, README, LICENSE, etc.
    * Use zipfile::encode to create the .zip file.
* Update Tools
  * quill new
    * Create library tree

# Desired changes

* quillapp(n) doesn't really need a namespace.
  * Make it go away, at least before plug-ins come in.


# Possibilities for Quill 0.2.0

* New Tools
  * quill new lib
  * quill add
    * Add apps and provides to existing project


## Needed Tests

* quill(n)
  * manpage(n), especially macros
  * Others?
* quillapp(n) modules

## Existing Tools

Quill's existing tools should provide the following additional features:

* quill build
  * Build as ".app" on OSX.
  * Include icons in GUI apps
  * Support non-TDK build methods.
    * Direct creation of a starkit, per issue #3.
    * Freewrap?
      * How to make that work with teapot packages?

* quill docs
  * Translate .md files to HTML?
  * Provide a format for non-manpage docs?
  * Provide other back-ends for manpage(5).

* quill new
  * Create "lib" tree

* quill shell
  * Allow selecting the specific app loader, or no app loader.
  * Support "shell" project.quill statement for shell initialization
    when running with no app loader
  * Allow user to specify script to execute on command line.


## Missing Tools and features

Quill should provide the following tools.

* quill add
  * Add a lib or app to the project.

* quill deploy
  * Upload project libraries to remote repository
    * TBD: Which repository?  By what mechanism?

* Support for C/C++ library packages

