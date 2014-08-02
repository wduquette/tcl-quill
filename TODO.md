# Project TODO List

This is the official list of work to be done.

# Next

* Write foropt loop.
* Use "plat pathto $tool -require" whenever getting tools.
* Grab parmset(n) and simplify, and use for "quill config".
* Use "catch" and "error" rather than "try" and "throw" in
  the apploader template.
* Add "tcl" requirement in project.quill; defaults to 8.6.
* Use "tcl" requirement version instead of $tcl_version in 
  app loader template.
* Support for other versions of TCL/TK.
  * I.e, use Quill for Tcl 8.5 projects.

# Possibilities For Quill 0.2.0

* Automate building a release .zip or .tar.gz file
* New Tools
  * quill add
    * Add apps and provides to existing project
* Update Tools
  * quill new
    * Create library tree
  * quill build
    * Support icons and .app builds
* Support for C/C++ library packages


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

## Missing Tools

Quill should provide the following tools.

* quill add
  * Add a lib or app to the project.

* quill config
  * Global configuration for Quill
  * Quill tries to find all helpers, etc., automatically.  This is the
    escape hatch; use it to establish locations of TDK, etc.
  * We might have other configuration items eventually.
    * E.g., on Windows, which command shell is in use?  bash?  Powershell?
      the old-fashioned "DOS" shell?

* quill deploy
  * Upload project libraries to remote repository
    * TBD: Which repository?  By what mechanism?

* quill editing tools (?)
  * Project search and replace commands.

* quill run
  * Run the main app (or a given app) with a given command line.

