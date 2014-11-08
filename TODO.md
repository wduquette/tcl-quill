# Project TODO List

This is the official list of work to be done, along with possibilities,
blue sky ideas, and what-not.

# For Quill 0.3.0

* Fix bugs as found and reported.

# For Quill 0.4.0

* Include tclapp command line in log file.
* Complete dictable.test.
* quilldoc(5) Changes:
  * Should manpage(5) be quillman(5)?  Probably.
* Add tests for quill tools
  * Dual test scheme: modules containing mechanism, which are tested
    directly.
  * Tool modules, which are tested using mockup mechanisms.
  * Goal: test coverage similar to Snit's, so that when I run the tests
    on Windows or Linux, I've really shown that I've not broken anything.
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

