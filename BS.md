# Brainstorming

Nothing in this file should be presumed to be reflective of anything
in the project.  Everything in this file is either incomplete, obsolete, 
or wrong.

## Q: Downloading Basekits

I shouldn't care where basekits come from.  

Any basekit in ~/.quill/basekits that matches the Tcl version should
be good.

I should offer those as well as the ones from the net.

It probably shouldn't be handled by tool_build.

## Q: How best to support builds on multiple platforms?

* The existing mechanism with -apptypes is not so good.
  * You always build for all specified apptypes, which is slow.
  * You should always be able to build for "exe", which is the current
    platform; and that might not be one of the "standard" platforms.
* If I add the "%platform" tag to distribution names, then I don't need
  specific distribution names for each platform.
* Suppose the 'quill build' command had some capabilities:
  * List all available platforms (the current platform, and the ones
    available at teapot.jpl.nasa.gov)
  * Do "build all" for a given set of platforms.
    * How to specify?
      * Full names (a lot to type)
      * By letter (assign a letter to each, give list)

* Steps: 
  * Define a command to list available platforms.
  * Define a new module appbuilder.tcl, used by build tool?
  * Base command takes platform "tcl" (for .kit) or architecture.
  * For "this" architecture, uses local basekits.
  * For other architectures, pulls basekits from teapot, either explicitly
    or implicitly.
  * I need to let them specify alternate basekits.
    * Can we simply save them in ~/.quill/basekits?  Any basekit there is
      available?

* QUESTION: 
  * Do I really need to download the basekits?  If I just give tclapp the 
    architecture, will it grab the basekit itself, just like it grabs the
    packages?
    * ANSWER: It appears that you need to download the basekit.

## Q: How to test the Quill application?

* Separate mechanism from policy.
* Test the mechanism first.
* Only test policy in a vacuum.

It seems to me that I'm going to need some kind of sandbox.  The config 
module is necessary to everything, for example, but we don't want our 
tests dependent on the user's configuration, nor do we want to affect 
the user's configuration.

Can I use a virtual read-write file system?  Hmmmm.

But even then, I need to shift the app into "test mode"; and certain modules
will work differently in test mode than in production mode.

Do I want a "testmain"?  Probably.


## Q: How to support building Quill for multiple platforms on OSX?

So long as Quill is pure-Tcl, this is easy: I just need to grab the
appropriate basekit.

Basekits can be retrieved from the ActiveState teapot as follows:

First, get a list of what's available:

```
teacup list --all-platforms base-tcl-thread
teacup list --all-platforms base-tk-thread
```

We only want platforms that match one of: win32-ix86, linux-*-ix86, 
or macosx*-x86_64.

We only want versions that match one of: 8.5.* 8.6.*.

On Tcl 8.4, it's similar, though -thread isn't always available.

We can retrieve these to disk using 

`teacup get base-tcl-thread version arch`

where the version and architecture are as in the list returned from teacup.

Now, in theory these can be pulled into the local teapot; but it can only
contain one architecture.  So pull these into ~/.quill/basekits on demand,
and save them.

Then, "quill build" can build any or all of the three versions, saving the
exe to bin/myapp-$arch or bin/myapp-$arch.exe.

Then "quill install" can grab the appropriate one for your local bin.

Then, "quill dist" can build the distribition any of the chosen flavors.

Or, in project.quill, the -apptype option becomes -exetype; it can be a list
of kit, osx, windows, linux.  When we build, we pull down the required 
basekit, saving it as described above; and we save the different versions 
into bin as described.  All can get packaged in one .tar file.

## Q: How to support multiple versions of TCL/TK?

When I made Quill public, the first comment I got back was from a user who
uses Tcl 8.5, but Quill requires Tcl 8.6.  So, what needs to be done to 
support other versions of Tcl/Tk?

* Build Quill as a starpack.  DONE.
* Use system tclsh
  * Find tclsh on path.  DONE.
    * Query tclsh for Tcl version DONE
  * Allow users to specify which tools to use, via "quill config"  DONE.
    * But this should perhaps be Tcl version specific: the project
      selects the Tcl version, and Quill selects the appropriate helpers.
* Request update of "teacup" if it's too old.
* Avoid using Tcl 8.6-specific code in templates.  DONE.
* Support Tcl/Tk requirements in project.quill. DONE.

## Q: A GUI version of Quill?

Would it be good to have a GUI version of Quill that abstracts completely
away from the command line?

* Need project tree widget: contents of the selected project.
* Need log widget, results of latest action.
* Scan for projects?
* Recent projects?
* Something like the GitHub for Mac/Windows apps.

## Q: How can I make Quill less dependent on the installed Tclsh?

* Build as "exe"
* Search for default tclsh as we search for teacup, etc.
* Build data structure in ~/.quill of known shells, by Tcl version
* Allow user to specify desired Tcl version in project.quill

