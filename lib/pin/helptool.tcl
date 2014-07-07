#-------------------------------------------------------------------------
# TITLE: 
#    helptool.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Pinion: Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    "pin help" tool implementation.  This tool outputs help information
#    for Pinion users to the console.
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Register the tool

set ::pin::tools(help) {
	command     "help"
	description "Displays this help."
	argspec     {0 1 "topic"}
	intree      false
	ensemble    ::pin::helptool
}

# No ::pin::help() entry is required; this is a special case.

#-------------------------------------------------------------------------
# Namespace Export

namespace eval ::pin:: {
	namespace export \
		helptool
} 

#-------------------------------------------------------------------------
# Tool Singleton: helptool

snit::type ::pin::helptool {
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
		puts "Pinion is a tool for working with Tcl projects.  It has"
		puts "the following subcommands:\n"

		foreach tool [lsort [array names ::pin::tools]] {
			set desc [dict get $::pin::tools($tool) description]

			puts [format "%-8s - %s" $tool $desc]
		}

		puts ""
		puts "Use 'pin help <topic>' to see more about any tool."
	}

	# DisplayTopic topic
	#
	# topic  - A tool name or other help topic
	#
	# Displays help for the topic.

	proc DisplayTopic {topic} {
		if {![info exists ::pin::help($topic)]} {
			throw FATAL "No help is available for this topic: \"$topic\""
		}

		puts [outdent $::pin::help($topic)]
	}


}

