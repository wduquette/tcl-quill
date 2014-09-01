# Project TODO List

This is the official list of work to be done.

# For Quill 0.2.x

* docstool's clean feature needs to clean up all *.html
* Fix bugs as found and reported.
* Improved output using table(n)
  * quill info, quill env
* Quill user's guide
  * Documents how to use Quill
  * Documents Quill conventions, e.g., where to require packages, and the
    markings that appear in pkg* files.
  * Requires quilldoc(n) package.
* quillapp(n) doesn't really need a namespace.
  * Make it go away

# For Quill 0.3.0

* 'quill new lib'
* 'quill add'
  * Requires ability to save project.quill.
* Improved tool architecture
* 'app foo -apptype exe':
  * Allow "exe" apptype for building in just the local flavor, whatever it 
    is.
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

