# Release Notes

## Quill v0.4.0

Significant Changes:

* Quill has a new template architecture for project trees and other 
  project elements.
* There are now two project tree templates, "app" and "lib".
* There is now a 'quill add' command, for adding skeleton project
  elements (libs, apps, etc.) to existing projects.

Issues Closed in Quill v0.4.0

* #50: 'quill basekit''s help is out-of-date.
* #49: Can't bootstrap Quill easily
* #48: 'quill add' command
* #46: Feature Request - Release checklist
* #45: Tool usage string convention
* #34: 'quill new -force'
* #10: 'quill new lib'  

## Quill v0.3.0

Significant Changes:

* There is now a minimally complete user's guide.
* Quill can now format section-numbered documents as well as man pages.
* Quill build products reference the full platform string.  I.e., Quill now knows 
  the difference between 32-bit and 64-bit Linux.
* `quill build all`: One command now serves to:
  * Check the project's dependencies
  * Run the project's tests
  * Format the project's documentation
  * Build the project's libraries
  * Build the project's applications for the current platform.
  * Build the distribution .zip file(s) for the current platform.
* `quill build for`: Following `quill build all`, Quill can now build the
   project for any platform for which a basekit available, building the 
   project's applications and distribution files for the platform with 
   one command.
* `quill basekit`: The user can list basekits available locally and at
   teapot.activestate.com, and retrieve basekits for local use.
* `quill teapot fix`: Quill has a new scheme for managing the permissions on the 
  local teapot that does not require running Quill with `sudo`.  It should also 
  work better on Linux. 
* Considerable work on the internals.

Issues Closed in Quill v0.3.0

* #39 quilldoc(n): xref of top-level section includes erroneous "."
* #38 quilldoc(n): 'section' stack traces if prior section cannot be found.
* #37 quilldoc(n): xref fails with an error on unknown xref ID
* #35 Quill doesn't update "package require" version for unprovided packages
* #30 Default Distribution set
* #29 New project has zero test failures
* #28 table(n) should be dictable(n)  refactor
* #27 'quill env' should use dictable for formatting output.
* #26 'package require' in project.quill results in "unexpected error"
* #25 quillinfo(n) has no man page
* #24 Application library packages should be "app_name", not "nameapp".
* #23 'quill new' adds docs/index.html, not docs/index.quilldoc.
* #22 Use relative paths with tclapp
* #21 Dist names with "%platform" are expanded too early
* #20 'quill build' error checking is bad.
* #19 'quill test' on multiple test targets
* #16 'quill teapot' reports that teapot is not linked when it is.
* #14 test pathfind-1.1 and 1.3 fail on Windows
* #13 quill build all