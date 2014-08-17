#-------------------------------------------------------------------------
# TITLE: 
#    envtool.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    "quill env" tool implementation.  This tool outputs information
#    about the development environment as Quill sees it.
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Register the tool

set ::quillapp::tools(env) {
    command     "env"
    description "Describes the development environment."
    argspec     {0 0 ""}
    intree      false
    ensemble    ::quillapp::envtool
}

set ::quillapp::help(env) {
    The "quill env" tool displays information about the development
    environment as seen by Quill: the tclsh and other tools it is using,
    whether or not it can find them, and how it found them.
}

#-------------------------------------------------------------------------
# Namespace Export

namespace eval ::quillapp:: {
    namespace export \
        envtool
} 

#-------------------------------------------------------------------------
# Tool Singleton: envtool

snit::type ::quillapp::envtool {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    # execute argv
    #
    # argv - command line arguments for this tool
    # 
    # Executes the tool given the arguments.

    typemethod execute {argv} {
        set os [os name]

        puts "Quill [quillinfo version] thinks it is running on $os."
        puts "" 
        puts "Helper Tools:"

        DisplayPath tclsh
        DisplayPath tkcon
        DisplayPath teacup 
        DisplayPath tclapp
        DisplayPath basekit.tcl
        DisplayPath basekit.tk
        DisplayPath teapot-pkg

        puts ""
        puts "Local Teapot: [env pathof teapot]"
    }

    # DisplayPath tool
    #
    # tool    - The tool name
    #
    # Displays the path and the tool's env (if known).

    proc DisplayPath {tool} {
        set path [env pathto $tool]
        set ver  [env versionof $tool]

        if {![file isfile $path]} {
            set flag " (NOT FOUND)"
        } elseif {$ver ne ""} {
            set flag " ($ver)"
        } else {
            set flag ""
        }
        
        puts [format "    %-12s %s%s" $tool $path $flag]
    }
}

