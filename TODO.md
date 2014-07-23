# Project TODO List

## Next

* Things I can do on the plane, without wifi:
  * Consider moving "main" into the app package
  * quill shell enhancements
    * Support when no app defined
    * Support for "plain" shell when app defined
    * project.quill "shell" script, for plain shells.
  * Tests
    * manpage(n)
    * quillapps packages

* Implement effects of app options
  * -gui - Makes it a Tk app
  * -apptype - One of "kit", "uberkit", "exe".
    * kit: Just the app's own files.  Other packages are loaded from
      the environment. (i.e., from the local teapot)  Cross-platform.
    * uberkit: The app's own files plus all required packages.
      Cross-platform, provided that no non-Tcl packages are included.
    * exe: starpack, using basekit for the current platform.
* Support requires.
  * State them in project.quill. DONE.
  * Then, update "package require" blocks in project libs so that versions
    match requires in project.quill.  DONE.
    * Instead of simply replacing the block, Quill reads lines in block
      looking for "package require <package>" and rewrites them with the
      version spec from project.quill.
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
