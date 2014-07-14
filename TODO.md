# Project TODO List

## Next

* Create quillinfo(n) automatically.
* Support building man pages
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
  * Open Tkcon (or a similar shell) with the app's code accessible.
  * If app, run all but main
  * Otherwise, just set up the auto_path, and run "shell" script from
    project.quill.