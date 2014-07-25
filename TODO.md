# Project TODO List

This is the official list of work to be done.

## Next

* quill install
  * Install executables into ~/bin
  * Install specific executable
    * "quill install app" installs all apps
    * "quill install lib" installs all libs
    * "quill install app names..." installs the specific apps
    * "quill install lib names..." installs the specific libs
* Manage local teapot

## Before First Release

* quill install: Install executables into ~/bin
* Manage local teapot in ~/.quill/teapot
* quill deps: pull teapot packages into local teapot as needed.
* quill new: "lib" tree
* quill build: build libs as teapot .zips
* quill install: Install teapot .zips into local teapot
* Write INSTALL.md
* Write BUILD.md
* Build as 0.1.0 and release on github.
* Put announcements on wiki.tcl.tk and comp.lang.tcl.

## Needed Tests

* quill(n)
  * manpage(n), especially macros
  * Others?
* quillapp(n) modules

## Existing Tools

Quill's existing tools should provide the following additional features:

* quill build
  * Build "provide" libs as teapot .zips
  * Build a specific target
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

* quill deploy
  * Upload project libraries to remote repository
    * TBD: Which repository?  By what mechanism?

* quill deps
  * Check external dependencies, and retrieve missing ones.

* quill install
  * Install executables into ~/bin
  * Install provided libs into local teapot

* quill editing tools (?)
  * Project search and replace commands.

* quill run
  * Run the main app (or a given app) with a given command line.

