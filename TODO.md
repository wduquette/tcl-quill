# Project TODO List

This is the official list of work to be done.

# For Quill 0.2.x

* Fix bugs as found and reported.
* quilldoc(5) Changes:
  * Should manpage(5) be quillman(5)?  Probably.
* Quill user's guide
  * Documents how to use Quill
  * Documents Quill conventions, e.g., where to require packages, and the
    markings that appear in pkg* files.
  * Requires quilldoc(n) package.
* Quill needs to handle multiple test targets better; see Issue #19.
* Improved tool architecture
* Linux Testing
* Distinguish between linux flavors when building; could be 32 or 64.
  Support both.

# For Quill 0.3.0

* Make "platforms" a new project(5) command: lists supported platforms.
  * app -apptypes becomes -apptype again.
  * 'quill build all' builds exe for this platform and dist for this
    platform.
  * 'quill build all -allplatforms' builds exes for all platforms
  * Or something like this.  The current scheme isn't quite right, and
    doesn't handle flavors well.
* Use zipfile::encode to build teapot packages.
* 'quill new lib'
* 'quill add'
  * Requires ability to save project.quill.
* 'quill clean'
  * docstool's clean feature needs to clean up all *.html
* Add check on "teacup" executable for build 298288 or later.

# Desired Features

## Needed Tests

* quillapp(n) modules and tools

## Existing Tools

Quill's existing tools should provide the following additional features:

* quill add
  * Add a lib or app to the project.

* quill build
  * Build as ".app" on OSX.
  * Include icons in GUI apps
  * Support non-TDK build methods.
    * Direct creation of a starkit, per issue #3.
    * Freewrap?
      * How to make that work with teapot packages?

* quill docs
  * Translate .md files to HTML?
  * Provide other back-ends for manpage(5).

* quill shell
  * Allow selecting the specific app loader, or no app loader.
  * Support "shell" project.quill statement for shell initialization
    when running with no app loader
  * Allow user to specify script to execute on command line.

* quill deploy
  * Upload project libraries to remote repository
    * TBD: Which repository?  By what mechanism?

* Support for compiled (e.g., C/C++) library packages

