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

    # Registry of element details
    #
    # public       - Names of public elements
    # private      - Names of private elements
    # edict-$name  - Element dictionary for this element
    #
    #    name - Element name
    #    public  - Public flag, 1 or 0
    #    usage   - Usage string (arguments)
    #    min     - Min number of arguments
    #    max     - Max number of arguments (or "-")
    #    command - The element command

    typevariable registry -array {
        public  {}
        private {}
    }

    #---------------------------------------------------------------------
    # Registration of Element Commands

    # private name command
    #
    # name     - An element name
    # command  - The command that produces the element.

    typemethod private {name command} {
        dict set edict name    $name
        dict set edict public  0
        dict set edict command $command

        lappend registry(private) $name
        set registry(edict-$name) $edict
    }

    # public name usage min max command
    #
    # name     - An element name
    # usage    - A usage string for the element arguments.
    # min      - Minimum number of arguments.
    # max      - Maximum number of arguments, or "-"
    # command  - The command that produces the element.

    typemethod public {name usage min max command} {
        dict set edict name    $name
        dict set edict public  1
        dict set edict usage   $usage
        dict set edict min     $min
        dict set edict max     $max
        dict set edict command $command

        set register(public) $name
        set registry(edict-$name) $edict
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
        if {![info exists registry(edict-$name)]} {
            throw FATAL "Unknown project element: \"$name\""
        }

        set command [dict get $registry(edict-$name) command]

        {*}$command {*}$args
    }
}
