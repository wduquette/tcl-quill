# Brainstorming

Nothing in this file should be presumed to be reflective of anything
in the project.  Everything in this file is either incomplete, obsolete, 
or wrong.

## Q: How to structure project tree templates.

Two kinds of thing: elements and trees.

A project tree is a collection of elements created by "quill new".

A project element is a collection of files created using 
maptemplate(n) and the gentree command.

Define two ensembles: element and tree.  Element creates elements.
tree creates trees.

Both ensembles are normal namespace ensembles, ::quillapp::element
and ::quillapp::tree.  That way, elements and trees can be added 
after the fact.

## Q: Is there a better way to do project file templates?

**Nut shell: Defined maptemplate(n).**

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



