#-------------------------------------------------------------------------
# TITLE: 
#    element.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project build system for Tcl/TK
#
# DESCRIPTION:
#    Project element ensemble: project elements are rooted here.
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Exported Commands

namespace eval ::quillapp:: {
    namespace export element
}

snit::type ::quillapp::element {
    # pragma -hasinstances no -hastypedestroy no

    #---------------------------------------------------------------------
    # Type Variables

    # Registry of template names to commands.
    typevariable registry -array {}

    #---------------------------------------------------------------------
    # Registration of Element Commands

    # register name command
    #
    # name     - An element name
    # command  - The command that produces the element.

    typemethod register {name command} {
        set registry($name) $command
    }

    #---------------------------------------------------------------------
    # Element Execution

    # Delegate element names to RegisteredElement
    delegate typemethod * using {%t RegisteredElement %m}

    # RegisteredElement name args...
    #
    # name   - An element name.
    # args   - Element arguments.
    #
    # Calls the registered element's code given the args.

    typemethod RegisteredElement {name args} {
        if {![info exists registry($name)]} {
            throw FATAL "Unknown project element: \"$name\""
        }
        
        {*}$registry($name) {*}$args
    }
}
