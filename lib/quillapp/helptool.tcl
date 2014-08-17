#-------------------------------------------------------------------------
# TITLE: 
#    helptool.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    "quill help" tool implementation.  This tool outputs help information
#    for quill users to the console.
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Register the tool

set ::quillapp::tools(help) {
    command     "help"
    description "Displays this help."
    argspec     {0 1 "<topic>"}
    intree      false
    ensemble    ::quillapp::helptool
}

# No ::quillapp::help() entry is required; this is a special case.

#-------------------------------------------------------------------------
# Namespace Export

namespace eval ::quillapp:: {
    namespace export \
        helptool
} 

#-------------------------------------------------------------------------
# Tool Singleton: helptool

snit::type ::quillapp::helptool {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    # execute argv
    #
    # argv - command line arguments for this tool
    # 
    # Executes the tool given the arguments.

    typemethod execute {argv} {
        set topic [lindex $argv 0]

        if {$topic eq "" || $topic eq "help"} {
            DisplayToolList
        } else {
            DisplayTopic $topic
        }
    }

    # DisplayToolList
    #
    # Displays a list of all of the tool subcommands, with 
    # descriptions.

    proc DisplayToolList {} {
        puts ""
        puts "quill help ?<topic>?"
        puts [string repeat - 70]
        puts "quill is a tool for working with Tcl projects.  It has"
        puts "the following subcommands:\n"

        foreach tool [lsort [array names ::quillapp::tools]] {
            set desc [dict get $::quillapp::tools($tool) description]

            puts [format "%-8s - %s" $tool $desc]
        }

        puts ""

        puts [outdent {
            In addition, you can use 'quill' to execute Tcl scripts in
            the context of the project's code base (i.e., with access to
            the project's packages):

               $ quill myfile.tcl args....
        }]

        puts ""
        puts "Use 'quill help <topic>' to see more about any tool."
    }

    # DisplayTopic topic
    #
    # topic  - A tool name or other help topic
    #
    # Displays help for the topic.

    proc DisplayTopic {topic} {
        if {![info exists ::quillapp::help($topic)]} {
            throw FATAL "No help is available for this topic: \"$topic\""
        }

        puts ""

        if {[info exists ::quillapp::tools($topic)]} {
            set tdict $quillapp::tools($topic)
            set usage [lindex [dict get $tdict argspec] 2]
            puts "quill $topic $usage"
        } else {
            puts "Topic: $topic"
        }

        puts [string repeat - 70]
        puts [outdent $::quillapp::help($topic)]
    }


}

