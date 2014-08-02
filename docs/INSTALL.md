# Installing Quill

## Dependencies

In principle, Quill could be used with any installation of Tcl 8.4 or later.
At present, however, Quill requires some version of ActiveTcl, because of
ActiveTcl's support for "teapot" repositories).

Further, in order to build executables and libraries for deployment 
Quill currently relies on TclDevKit 5.

These requirements may be relaxed over time; for example, Quill could
in principle support FreeWrap.

## Installation

1. Install ActiveTcl 8.4 or later on your development machine.  Make
   sure that `tclsh` at your command shell of choice invokes
   this version of Tcl.

2. To build executables and libraries for deployment, install 
   TclDevKit 5.1 so that the `tclapp` and `teapot-pkg` executables 
   are on your PATH.  (Note: Quill can do quite a lot for you even
   without TDK installed.)

3. Download the Quill distribution for your platform.  It contains the 
   following:

   * `README.md`
   * `bin\quill` of `bin\quill.exe`
   * `docs\index.html`
   * `docs\...`

4. Copy `bin\quill` to your ~/bin directory (or wherever), and make sure it
   is marked executable.

5. Put the documentation somewhere where you can find it.

6. You should now be able to enter the command

    `$ quill version`

   This will tell you which version of Quill you are running, and what
   helper commands (e.g., `tclsh`, `teacup`, etc.) it has found and will
   use.
