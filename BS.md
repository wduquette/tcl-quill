# Brainstorming

Nothing in this file should be presumed to be reflective of anything
in the project.  Everything in this file is either incomplete, obsolete, 
or wrong.

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

## Q: How best to make the teapot writable?

The 'quill teapot link' approach isn't working on 64-bit Ubuntu:

1. 'teacup default' is only working with "sudo"; I've reported this as a bug.
2. 'sudo -E' isn't working; Quill can't find the tools when run with "sudo".

This approach is too dependent on the environment settings to work.  Here's
another approach:

1. 'quill teapot' diagnoses the situation.
2. 'quill teapot create' creates the Quill teapot. 
3. It also writes a script to ~/.quill/fixteapot to set up and link to
   the new teapot.
3. The script contains the full paths.
4. It's up to the user to run it with sudo.
5. On Windows, write a batch file; but tell the user it needs to be run
   with Admin privs.

The script looks like this:

```bash
# Get rid of root-owned cache
chown -R <user> <home>/.teapot
teacup default <quillTeapotDir>
teacup link make <quillTeapotDir> <tclshPath>
```


## Q: How to pull basekits from teapot?

* Needed operations:
  * Given the os flavor and the required Tcl version, see whether the
    given basekit is in ~/.quill/basekits, and return its path.
  * Given the os flavor and the required Tcl version, pull the desired
    record from 'teacup list'.
  * Then given that record, pull the desired basekit into ~/.quill/basekits.
* Steps:
  * Make 'quill deps' check for a basekit in ~/.quill/basekits that 
    matches the current os flavor.
  * Make 'quill deps update' pull the basekit in.  On force, refresh it.
  * Make 'quill build' get the basekit from ~/.quill/basekits.
  * Change 'app' to allow specifying a list of kit|windows|linux|osx.
  * 'quill deps' then looks for and retrieves all required basekits.
  * 'quill build' builds all required version.

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
  * Allow users to specify which tools to use, via "quill config"
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

## Q: How to do project file templates?

**Nutshell: Defined maptemplate(n).**

At present I use a file with string map parameters.  Quill has to know
what the parameters are, because there's no easy way to extract them 
from the file.  In addition, Quill has to know what they mean.  

For example, a standard pkgModules_tcl.template file is going to 
contain a %package tag.  It could be used for an application's main
package,  a project's main "lib" package, or a subsidiary package.
So you have to know how to use a template.  

### The macro(n) package is no help.

It would be a help if every replaceable tag in a template file could
simply be mapped to a non-parameterized project metadata value (like
the project name or version).  Otherwise, we need some way to specify
the mapping, and that's no better than what we have.

### We want to support plug-ins

In the long run, we'd like to support plug-ins for new kinds of 
projects and project elements.  Because the mapping for replaceable
parameters is semantic, we're always going to need code: not just
a set of template files.

### Q: Is there any benefit to having the templates in separate files?

Maybe, maybe not.  It makes them easy to edit, but there's no other
advantage.

### Q: What about the template(n) package?

I'm not sure about `tif` and `tforeach`.  But the basic template/tsubst
calls could be very useful:

* The parameters are clear, and can be introspected.
* A given project tree or element could define any number of templates
  of its own, and also use the basic ones.

**BUT!** Because template(n) uses Tcl syntax for the interpolated variables
and commands, it's lousy for creating Tcl code files.  Quoting Hell!  So
that isn't going to work.

### What's wanted

Here are the requirements so far:

* Each file template should be a Tcl command whose arguments flow into the
  template string.

* The template should produce a string; writing it to disk is orthogonal.

* The template command should be defined by a template(n)-like
  definition command, using some kind of outdenting.

It will have to use one of the following substitution mechanisms:

* `subst`
* `tsubst`
* `format`
* `string map`
* `macro(n)`

Of these, `subst` and `tsubst` are out because of quoting hell.  The 
`format` command is also out because the replacements are indicated
positionally, which doesn't translate well to something like a template
proc.

It would possible to use `string map` with `proc` and `outdent` to do 
something like this:

```Tcl
template pkgIndex {project package version} {
    # %project
    package ifneeded %package %version ...
}
```

Any replaceable parameter can be used multiple times.  This would
answer the mail; the only problem is that there's no error checking.
If the template string contains "%pkg", it simply won't be replaced.

We could build a similar feature on top of macro(n); but we'd need a
way to map in variables for replacement.  For example, we could use
an unknown handler to let "%variable" map to the given variable.

```Tcl
template pkgIndex {project package version} {
    # <<%project>>
    package ifneeded <<%package>> <<%version>> ...
}
```

This option has the advantage that we can make package metadata
available directly via pre-defined macros. However, it is much more
complex.

One problem both of these schemes have is that it's hard to provide an 
"initbody" as template(n)'s `template` does.  For `template`, the template
string is `tsubst`'d in the caller's context, and all defined variables 
are simply present.  However, we could conceivably use `info locals` to
retrieve all local variables in the initbody, and package them up as a
dict.



