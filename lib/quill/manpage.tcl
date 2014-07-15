#-------------------------------------------------------------------------
# TITLE: 
#    manpage.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl
#
# DESCRIPTION:
#    manpage(n): manpage processor built on macro(n).
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Namespace Exports

namespace eval ::quill:: {
    namespace export \
        manpage
}

snit::type ::quill::manpage {
    #---------------------------------------------------------------------
    # Components

    component macro  ;# The macro(n) object


    #---------------------------------------------------------------------
    # Instance Variables

    # Info Array
    #
    # TBD

    variable info -array {
    }

    #---------------------------------------------------------------------
    # Options

    # TBD

    #---------------------------------------------------------------------
    # Constructor

    constructor {} {
        # FIRST, create the components
        install macro using macro ${selfns}::macro \
            -brackets {< >}

        # NEXT, define the macros initially.
        $self reset
    }

    #---------------------------------------------------------------------
    # Public Methods

    delegate method expand to macro
    delegate method eval   to macro
    delegate method lb     to macro
    delegate method rb     to macro

    # reset 
    #
    # Resets the macro processor's interpreter.

    method reset {} {
        # FIRST, reset it.
        $macro reset

        # NEXT, define our own macros.
        $self DefineLocalMacros
    }

    # DefineLocalMacros
    #
    # Defines the default manpage set, which is quite small.

    method DefineLocalMacros {} {
        # FIRST, define some standard HTML tags
        foreach tag {
            b i code tt pre em strong 
        } {
            $self StyleTag $tag
        }

        $self Identity p
        $self Identity /p

        # NEXT, define brackets
        $self proc lb {} { return "&lt;"}
        $self proc rb {} { return "&gt;"}
    }

    # Identity tag
    #
    # Defines a macro that expands to the same named HTML tag.

    method Identity {tag} {
        $macro proc $tag {} [format {
            return "<%s>"
        } $tag]
    }

    # StyleTag tag
    #
    # tag   - A style tag name
    #
    # Defines a tag macros.

    method StyleTag {tag} {
        $macro proc $tag {args} [format {
            if {[llength $args] == 0} {
                return "<%s>"
            } else {
                return "<%s>$args</%s>"
            }
        } $tag $tag $tag]

        $macro proc /$tag {} [format {
            return "</%s>"
        } $tag]
    }
}







