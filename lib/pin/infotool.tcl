#-------------------------------------------------------------------------
# TITLE: 
#    infotool.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Pinion: Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    "pin info" tool implementation.  This tool outputs the project's
#    information to the console.
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Register the tool

set ::pin::tools(info) {
	command     "info"
	description "Displays the project metadata to the console."
	argspec     {0 0 ""}
	intree      true
	ensemble    ::pin::infotool
}

set ::pin::help(info) {
	The "pin info" tool displays the project's metadata to the console 
	in human-readable form.
}

#-------------------------------------------------------------------------
# Namespace Export

namespace eval ::pin:: {
	namespace export \
		infotool
} 

#-------------------------------------------------------------------------
# Tool Singleton: infotool

snit::type ::pin::infotool {
	# Make it a singleton
	pragma -hasinstances no -hastypedestroy no

	# execute argv
	#
	# argv - command line arguments for this tool
	# 
	# Executes the tool given the arguments.

	typemethod execute {argv} {
		puts "[project name] [project version]: [project description]"
		puts ""
		puts "Root: [project root]"
		puts ""

		foreach app [project app names] {
			puts "App: $app"
		}
	}
}

