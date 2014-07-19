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

#-------------------------------------------------------------------------
# Register the tool

set ::quillapp::tools(new) {
	command     "new"
	description "Create new project trees"
	argspec     {0 - "treetype args..."}
	intree      false
	ensemble    ::quillapp::newtool
}

set ::quillapp::help(new) {
	The "quill new" tool creates new project trees customized for
	particular purposes.  Enter "quill new" with no arguments
	for a list of available tree types, and "quill new <treetype>"
	for a description of that tree type and its arguments.
}

#-------------------------------------------------------------------------
# Namespace Export

namespace eval ::quillapp:: {
	namespace export \
		newtool
} 

#-------------------------------------------------------------------------
# Tool Singleton: newtool

snit::type ::quillapp::newtool {
	# Make it a singleton
	pragma -hasinstances no -hastypedestroy no

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

		if {$ttype ni [tree names]} {
			throw FATAL [outdent "
				Quill doesn't define a project tree type called 
				\"$ttype\".  Enter \"quill new\" without any other
				arguments to see a complete list of tree types.
			"]
		}

		# NEXT, if we have a tree type but no additional arguments,
		# display the description and usage information for the
		# tree type.
		array set tdata [tree get $ttype]

		set len [llength $argv]

		if {$len < $tdata(min) || 
			($tdata(max) ne "-" && $len > $tdata(max))
		} {
			puts "Usage: quill new $ttype $tdata(usage)\n\n"
			puts $tdata(help)

			return
		}

		# NEXT, if we're in a tree that's a problem.
		if {[project intree]} {
			throw FATAL [outdent {
				Quill will not create a project tree within another
				project tree.  Please move to a directory outside
				any project tree.
			}]
		}

		# NEXT, validate the new project name
		set project [lindex $argv 0]
		# TODO

		# NEXT, if there's already a tree here, that's a problem.
		if {[file exists $project]} {
			throw FATAL "A directory called \"$project\" already exists here."
		}

		# NEXT, create the project tree
		tree $ttype {*}$argv
	}

	# DisplayTreeTypeList
	#
	# Displays a list of the available tree types

	proc DisplayTreeTypeList {} {
		puts "Quill supports the following project tree types:\n"
		puts ""

		set fmt "  %-8s %s"

		puts [format $fmt "Type"     "Arguments"]
		puts [format $fmt "--------" "---------------------------------"]
		foreach ttype [tree names] {
			set usage [tree get $ttype usage]
			puts [format $fmt $ttype $usage]
		}

		puts ""

		puts [outdent {
			To see details about a particular tree type, enter
			"quill new <ttype>" with no additional arguments.
		}]
	}
}

