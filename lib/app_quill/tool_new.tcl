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
#    "quill new" tool implementation.  This tool creates new
#    project trees.
#
#-------------------------------------------------------------------------

app_quill::tool define new {
    description "Create new project trees"
    argspec     {0 - "<template> <arg>..."}
    needstree   false
} {
    The "quill new" tool creates new project trees customized for
    particular purposes.  Enter "quill new" with no arguments
    for a list of available tree templates, and "quill new <template>"
    for a description of that template and its arguments.
} {
    # execute argv
    #
    # argv - command line arguments for this tool
    # 
    # Executes the tool given the arguments.

    typemethod execute {argv} {
        # FIRST, if we have no tree type, display the list of
        # tree types.
        if {[llength $argv] == 0} {
            DisplayTreeTypeList
            return
        }

        # NEXT, make sure it's a valid tree type.
        set ttype [lshift argv]

        if {$ttype ni [element tree names]} {
            throw FATAL [outdent "
                Quill doesn't define a project tree type called 
                \"$ttype\".  Enter \"quill new\" without any other
                arguments to see a complete list of tree types.
            "]
        }

        # NEXT, if we have a tree type but no additional arguments,
        # display the description and usage information for the
        # tree type.

        set project [lshift argv]
        prepare project -file

        if {$project eq ""} {
            puts [element tree usage $ttype]
            puts [string repeat - 70]
            puts [outdent [element tree help $ttype]]
            exit
        }

        try {
            element newtree $ttype $project {*}$argv
        } trap INVALID {result} {
            throw FATAL $result
        }
        return
    }

    # DisplayTreeTypeList
    #
    # Displays a list of the available tree types

    proc DisplayTreeTypeList {} {
        puts "Quill supports the following project tree types:\n"

        set table [list]

        foreach ttype [element tree names] {
            set description [element tree description $ttype]

            lappend table [list Type $ttype Description $description]
        }

        dictable puts $table  \
            -showheaders      \
            -leader      "  " \
            -sep         "  "

        puts ""

        puts [outdent {
            To see details about a particular tree type, enter
            "quill new <ttype>" with no additional arguments.
        }]
    }
}

