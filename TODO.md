# Project TODO List

## Next

* Support requires.
  * State them in project.quill.
  * Then, update "package require" blocks in project libs so that versions
    match requires in project.quill.
  * Then write code to check local teapot and update it using teacup.
* Support building .kits and .exes
* Add tests for manpage(n), including the macros.

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
