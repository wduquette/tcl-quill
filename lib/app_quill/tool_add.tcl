#-------------------------------------------------------------------------
# TITLE: 
#    newtool.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    "quill add" tool implementation.  This tool creates new
#    project trees.
#
#-------------------------------------------------------------------------

app_quill::tool define add {
    description "Add an element to a project"
    argspec     {0 - "<template> <arg>..."}
    needstree   true
} {
    The "quill add" tool creates adds new elements (e.g., library
    skeletons) to existing project trees.  Enter "quill add" with no 
    arguments for a list of available element templates, and 
    "quill add <template>" for a description of that template and its 
    arguments.
} {
    # execute argv
    #
    # argv - command line arguments for this tool
    # 
    # Executes the tool given the arguments.

    typemethod execute {argv} {
        # FIRST, if we have no element type, display the list of
        # element types.
        if {[llength $argv] == 0} {
            DisplayTemplateList
            return
        }

        # NEXT, make sure it's a valid element type.
        set etype [lshift argv]

        if {$etype ni [element fileset names]} {
            throw FATAL [outdent "
                Quill doesn't define an element type called 
                \"$etype\".  Enter \"quill add\" without any other
                arguments to see a complete list of element types.
            "]
        }

        # NEXT, if we have a element type but no additional arguments,
        # display the description and usage information for the
        # element type.

        if {![got $argv]} {
            puts [element fileset usage $etype]
            puts [string repeat - 70]
            puts [outdent [element fileset help $etype]]
            exit
        }

        try {
            element newset $etype {*}$argv
        } trap INVALID {result} {
            throw FATAL $result
        }
        return
    }

    # DisplayTemplateList
    #
    # Displays a list of the available element types

    proc DisplayTemplateList {} {
        puts "Quill supports the following project element types:\n"

        set table [list]

        foreach etype [element fileset names] {
            set description [element fileset description $etype]

            lappend table [list Type $etype Description $description]
        }

        dictable puts $table  \
            -showheaders      \
            -leader      "  " \
            -sep         "  "

        puts ""

        puts [outdent {
            To see details about a particular element type, enter
            "quill add <etype>" with no additional arguments.
        }]
    }
}

