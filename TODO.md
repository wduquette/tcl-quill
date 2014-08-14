# Project TODO List

This is the official list of work to be done.

# Next

* Define "config.tcl" module that defines and delegates to configuration
  parmset.  Work remaining:
  * Write config(5) man page, documenting the configuration parms;
    or add them to the config help.
  * Split plat.tcl into plat.tcl and env.tcl.
  * Stuff that's genuinely platform-dependent goes into env.tcl,
    e.g., how to make a file executable.
  * Stuff about the current development environment (some of which does
    depend on the current platform) goes in env.tcl.
  * Revise env.tcl to that determines which helpers to use,
    based on what it can find and the config parameters.
  * Define envtool.tcl that describes the environment, and lists the 
    helpers and their source (found on path or from config).
    * This replaces most of what "versiontool" does.
* Add check on "teacup" executable for build 298288 or later.
* Move helpers list from version tool to 'quill helpers' or something.
* Check "info(gottcl)" in appropriate spots, if it seems necessary.
* quillapp(n) doesn't really need a namespace.  App packages don't
  really need a namespace.

# Requirements For Quill 0.2.0

* Support for other versions of TCL/TK.
  * I.e, use Quill for Tcl 8.4/8.5 projects.
  * Support cross-platform starpack builds, if possible.
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

