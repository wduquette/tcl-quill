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

set ::quill::tools(help) {
	command     "help"
	description "Displays this help."
	argspec     {0 1 "topic"}
	intree      false
	ensemble    ::quill::helptool
}

# No ::quill::help() entry is required; this is a special case.

#-------------------------------------------------------------------------
# Namespace Export

namespace eval ::quill:: {
	namespace export \
		helptool
} 

#-------------------------------------------------------------------------
# Tool Singleton: helptool

snit::type ::quill::helptool {
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
		puts "quill is a tool for working with Tcl projects.  It has"
		puts "the following subcommands:\n"

		foreach tool [lsort [array names ::quill::tools]] {
			set desc [dict get $::quill::tools($tool) description]

			puts [format "%-8s - %s" $tool $desc]
		}

		puts ""
		puts "Use 'quill help <topic>' to see more about any tool."
	}

	# DisplayTopic topic
	#
	# topic  - A tool name or other help topic
	#
	# Displays help for the topic.

	proc DisplayTopic {topic} {
		if {![info exists ::quill::help($topic)]} {
			throw FATAL "No help is available for this topic: \"$topic\""
		}

		puts [outdent $::quill::help($topic)]
	}


}

