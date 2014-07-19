#-----------------------------------------------------------------------
# TITLE:
#    maptemplate.tcl
#
# AUTHOR:
#    Will Duquette
#
# PROJECT:
#    Tcl-quill: A Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    quill(n) module, maptemplate(n): [string map]-based Template 
#    Commands
#
#-----------------------------------------------------------------------

namespace eval ::quill:: {
    namespace export \
        mapsubst     \
        maptemplate 
}

# mapsubst template
#
# template     A text template string.
#
# Maps %-variables into the template string given the local
# variables in the caller's context.  The template is outdented
# first.

proc ::quill::mapsubst {template} {
    # FIRST, outdent the template, retaining a closing newline.
    set template "[::quill::outdent $template]\n"

    # NEXT, get a dictionary of the local variables in the 
    # caller's context.
    set mapping [dict create]
    foreach var [uplevel 1 [list info locals]] {
        # Skip arrays
        if {[uplevel 1 [list array exists $var]]} {
            continue
        }

        dict set mapping %$var [uplevel 1 [list set $var]]
    }

    # Allow backslashes in input
    dict set mapping \\\\ \\

    return [string map $mapping $template]
}

# maptemplate name arglist ?initbody? template
#
# name        The template name (a proc name)
# arglist     The template's arguments.
# initbody    A body of Tcl code
# template    A template into which %-variables are mapped.
#
# Defines a text template.

proc ::quill::maptemplate {name arglist initbody {template ""}} {
    # FIRST, have we an initbody?
    if {"" == $template} {
        set template $initbody
        set initbody ""
    }

    # NEXT, define the body of the new proc so that the initbody, 
    # if any, is executed and then the substitution is 
    set body "$initbody\n    mapsubst [list $template]\n"

    # NEXT, define
    uplevel 1 [list proc $name $arglist $body]
}

