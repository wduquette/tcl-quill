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
    needstree   false
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
        puts "Local Teapot: [env pathof teapot]"
        puts "" 
        puts "Helper Tools:"

        DisplayPath tclsh
        DisplayPath tkcon
        DisplayPath teacup 
        DisplayPath tclapp
        DisplayPath basekit.tcl.[os flavor]
        DisplayPath basekit.tk.[os flavor]
        DisplayPath teapot-pkg

        puts ""
        puts "!  - Helper tool could not be found on disk."
        puts "+  - Path is configured explicitly."

    }

    # DisplayPath tool
    #
    # tool    - The tool name
    #
    # Displays the path and the tool's env (if known).

    proc DisplayPath {tool} {
        set path [env pathto $tool]
        set ver  [env versionof $tool]

        set taglist [list]

        if {$path eq "" || ![file isfile $path]} {
            set code "!"
        } else {
            set code " "
        }

        if {$path eq ""} {
            set path "(NOT FOUND)"
        }

        if {[config get helper.$tool] ne ""} {
            append code "+"
        } else {
            append code " "
        }


        if {$ver ne ""} {
            set tag " (v$ver)"
        } else {
            set tag ""
        }
        
        puts [format "%-2s %-20s %s%s" $code $tool $path $tag]
    }
}

