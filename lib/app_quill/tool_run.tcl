#-------------------------------------------------------------------------
# TITLE: 
#    tool_run.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    "quill run" tool implementation.  This tool invokes tkcon
#    on the project tree, making the project code available.
#
#-------------------------------------------------------------------------

app_quill::tool define run {
    description "Runs the primary application."
    argspec     {0 - "?<arg>...?"}
    needstree   true
} {
    The "quill run" executes the project's primary application (if any),
    passing it the command-line arguments.  For projects that define
    more than one application, the primary application is the first to
    appear 

    To run arbitrary scripts in the context of the project's code base,
    just pass the script to 'quill' as its first argument, e.g.,

        $ quill myscript.tcl 1 2 3

    The executed script should be able to "package require" any of the
    project's packages.
} {
    # execute argv
    #
    # argv - command line arguments for the primary app
    # 
    # Executes the app given the arguments.

    typemethod execute {argv} {
        # FIRST, do we have a primary app?
        if {![project gotapp]} {
            throw FATAL "This project doesn't define any applications."
        }

        # NEXT, set up the path.
        set ::env(TCLLIBPATH) [project libpath]

        # NEXT, we always start in the project root directory.
        cd [project root]

        # NEXT, set up the command.
        lappend command \
            [env pathto tclsh] \
            [project app loader [lindex [project app names] 0]] \
            {*}$argv >@ stdout 2>@ stderr

        # NEXT, Execute the run
        try {
            eval exec $command
        } trap CHILDSTATUS {} {
            # Ignore CHILDSTATUS errors; all of the child's stdout and
            # stderr have been made invisible already.
        }
    }
}

