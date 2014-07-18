# Project TODO List

## Next

* Need architecture for project trees and elements.  We don't want to
  put them all into gentree.tcl.
  * Maptemplates work nicely
* Add tests for manpage(n), including the macros.
* Support building trees
* Support building .kits
* Support requires.

## To Find Out

* Can tclapp take a teapot package file and include it straight into a
  wrapped app?

## Missing Tools

Quill should provide the following tools.

* quill add
  * Add a lib or app to the project.

* quill build
  * Build some or all of the build projects.

* quill deps
  * Check external dependencies, and retrieve missing ones.

* quill docs
  * Build documentation
    * DONE Man pages in manpage(5) format
    * Markdown?
    * A fancier format with section numbers?

* quill install
  * Install build products into the local environment.

* quill new
  * Create a new project tree given a template

* quill replace (?)
  * Project search and replace command

* quill run
  * Run the main app (or a given app) with a given command line.

* quill shell
  * Allow selecting the app loader, or no app loader.
  * Support "shell" project.quill statement for shell initialization.
