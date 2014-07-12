#-----------------------------------------------------------------------
# TITLE:
#    code.tcl
#
# AUTHOR:
#    Will Duquette
#
# PROJECT:
#    Quill: Project Build System for Tcl
#
# DESCRIPTION:
#    code(n): Code Introspection and Manipulation
#
#-----------------------------------------------------------------------

namespace eval ::quill:: {
    namespace export \
        code
}

#-------------------------------------------------------------------------
# code ensemble

snit::type ::quill::code {
    pragma -hasinstances no -hastypedestroy no

    # getproc name
    #
    # name   - The name of a proc
    #
    # Retrieves the definition of the proc in a form which can be evaluated
    # to redefine it (including default values for optional args.
    # If the name includes a namespace, it is removed, so that the proc
    # can be defined into any desired namespace.

    typemethod getproc {name} {
        # FIRST, format the argument list
        set arglist {}

        foreach arg [info args $name] {
            if {[info default $name $arg defvalue]} {
                lappend arglist [list $arg $defvalue]
            } else {
                lappend arglist $arg
            }
        }

        # NEXT, return the proc definition.
        list proc [namespace tail $name] $arglist [info body $name]
    }
}

