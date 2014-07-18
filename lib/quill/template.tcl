#-----------------------------------------------------------------------
# TITLE:
#    template.tcl
#
# AUTHOR:
#    Will Duquette
#
# PROJECT:
#    Tcl-quill: A Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    quill(n) module, template(n): Template Commands
#
#-----------------------------------------------------------------------

namespace eval ::quill:: {
    namespace export \
        template     \
        tsubst 
}

# template name arglist ?initbody? template
#
# name        The template name (a proc name)
# arglist     The template's arguments.
# initbody    A body of Tcl code
# template    A template into which variables and commands are interpolated.
#
# Defines a text template.

proc ::quill::template {name arglist initbody {template ""}} {
    # FIRST, have we an initbody?
    if {"" == $template} {
        set template $initbody
        set initbody ""
    }

    # NEXT, define the body of the new proc so that the initbody, 
    # if any, is executed and then the substitution is 
    set body "$initbody\n    tsubst [list $template]\n"

    # NEXT, define
    uplevel 1 [list proc $name $arglist $body]
}

# tsubst template
#
# template     A text template string.
#
# Like subst, but allows "|<--" on the first line to set the
# left margin.
proc ::quill::tsubst {template} {
    # If the string begins with the indent mark, process it.
    if {[regexp {^(\s*)\|<--[^\n]*\n(.*)$} \
             $template dummy leader body]} {

        # Determine the indent from the position of the indent mark.
        if {![regexp {\n([^\n]*)$} $leader dummy indent]} {
            set indent $leader
        }

        # Remove the indent spaces from the beginning of each indented
        # line, and update the template string.
        regsub -all -line "^$indent" $body "" template
    }

    # Process and return the template string.
    return [uplevel 1 [list subst $template]]
}




