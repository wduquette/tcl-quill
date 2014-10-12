#-------------------------------------------------------------------------
# TITLE: 
#    tree.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project build system for Tcl/TK
#
# DESCRIPTION:
#    Project tree ensemble: manages registered project trees.
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Exported Commands

namespace eval ::app_quill:: {
    namespace export tree
}

snit::type ::app_quill::tree {
    # pragma -hasinstances no -hastypedestroy no

    #---------------------------------------------------------------------
    # Type Variables

    # Registry of tree details
    #
    # trees        - Names of registered trees
    # tdict-$name  - tree dictionary for this tree
    #
    #    name    - tree name
    #    usage   - Usage string (arguments)
    #    min     - Min number of arguments
    #    max     - Max number of arguments (or "-")
    #    command - The tree command

    typevariable registry -array {
        trees {}
    }

    #---------------------------------------------------------------------
    # Registration of tree Commands

    # register name usage min max command
    #
    # name     - An tree name
    # usage    - A usage string for the tree arguments.
    # min      - Minimum number of arguments.
    # max      - Maximum number of arguments, or "-"
    # command  - The command that produces the tree.
    # help     - Help text
    #
    # Registers a new tree create command.

    typemethod register {name usage min max command help} {
        precond {$min >= 1} "At least one argument is required"
        precond {[lindex $usage 0] eq "project"} \
            "The first tree argument must be \"project\""

        dict set tdict name    $name
        dict set tdict usage   $usage
        dict set tdict min     $min
        dict set tdict max     $max
        dict set tdict command $command
        dict set tdict help    [outdent $help]

        set registry(trees) $name
        set registry(tdict-$name) $tdict
    }

    # names
    #
    # Returns a list of the registered project tree names.

    typemethod names {} {
        return $registry(trees)
    }

    # get name ?parm?
    #
    # name - The tree name
    # parm - A tree parameter
    #
    # Returns the value of the named parameter, or the entire
    # tree dict.

    typemethod get {name {parm ""}} {
        if {$parm ne ""} {
            return [dict get $registry(tdict-$name) $parm]
        } else {
            return $registry(tdict-$name)
        }
    }

    #---------------------------------------------------------------------
    # tree Execution

    # Delegate tree names to Registeredtree
    delegate typemethod * using {%t Registeredtree %m}

    # Registeredtree name args...
    #
    # name   - An tree name.
    # args   - tree arguments.
    #
    # Calls the registered tree's code given the args.

    typemethod Registeredtree {name args} {
        if {![info exists registry(tdict-$name)]} {
            throw FATAL "Unknown project tree: \"$name\""
        }

        set command [dict get $registry(tdict-$name) command]

        {*}$command {*}$args
    }
}
