# Brainstorming

Nothing in this file should be presumed to be reflective of anything
in the project.  Everything in this file is either incomplete, obsolete, 
or wrong.

## Q: Is there a better way to do project file templates?

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

I think this is the way to do it.