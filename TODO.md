# Project TODO List

This is the official list of work to be done.

# Next

* Cross-platform builds:
  * Make 'quill deps' check for a basekit in ~/.quill/basekits that 
    matches the current os flavor.
  * Make 'quill deps update' pull the basekit in.  On force, refresh it.
  * Make 'quill build' get the basekit from ~/.quill/basekits.
  * Change 'app' to allow specifying a list of kit|windows|linux|osx.
  * 'quill deps' then looks for and retrieves all required basekits.
  * 'quill build' builds all required version.

* 'quill version' should return just the quill name and version; move
  the other information to 'quill env'.
* Add check on "teacup" executable for build 298288 or later.
* Check "info(gottcl)" in appropriate spots, if it seems necessary.
* quillapp(n) doesn't really need a namespace.  App packages don't
  really need a namespace.

# Requirements For Quill 0.2.0

* Support for other versions of TCL/TK.
  * I.e, use Quill for Tcl 8.5 or 8.6 projects.  Can also support 8.4 if
    anyone wants it.
  * Support cross-platform starpack build.
  * Support for 'quill package' to package up a distribution for different
    platforms.
    * Includes bin/, docs/, provided lib .zip's, README, LICENSE, etc.
    * Use vfs::zip to create the .zip file.
* Update Tools
  * quill new
    * Create library tree

# Possibilities for Quill 0.2.0

* Automate building a release .zip or .tar.gz file
* New Tools
  * quill add
    * Add apps and provides to existing project
* Update Tools
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

