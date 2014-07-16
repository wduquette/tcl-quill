# Project TODO List

## Next

* Support building man pages
  * DONE Add smartinterp to quill(n)
  * DONE Define macro(n)
  * DONE Test macro(n)
  * DONE Use macro(n) to define manpage(n)
  * DONE Build index.html page automatically
    * Requires basic section categories, and a mechanism for 
      defining new ones.
  * Define "quill docs" tool.
* Consider expanding templates rather than mapping them.
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
    * Man pages
    * Markdown?
    * A fancier format with section numbers?

* quill install
  * Install build products into the local environment.

* quill new
  * Create a new project tree given a template

* quill replace
  * Project search and replace command

* quill run
  * Run the main app (or a given app) with a given command line.

* quill shell
  * Allow selecting the app loader, or no app loader.
  * Support "shell" project.quill statement for shell initialization.
