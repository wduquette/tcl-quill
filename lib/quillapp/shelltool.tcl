#-------------------------------------------------------------------------
# TITLE: 
#    shelltool.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    "quill shell" tool implementation.  This tool invokes tkcon
#    on the project tree, making the project code available.
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Register the tool

set ::quillapp::tools(shell) {
	command     "shell"
	description "Opens a shell console on the project code."
	argspec     {0 0 ""}
	intree      true
	ensemble    ::quillapp::shelltool
}

set ::quillapp::help(shell) {
	The "quill shell" tool opens a Tkcon console window on the code in
	the project tree, allowing interactive testing.

	If the project defines an application, the application's loader
	script is loaded.
}

#-------------------------------------------------------------------------
# Namespace Export

namespace eval ::quillapp:: {
	namespace export \
		shelltool
} 

#-------------------------------------------------------------------------
# Tool Singleton: shelltool

snit::type ::quillapp::shelltool {
	# Make it a singleton
	pragma -hasinstances no -hastypedestroy no

	# execute argv
	#
	# argv - command line arguments for this tool
	# 
	# Executes the tool given the arguments.
	#
	# TODO: allow executing other app loaders.
	# TODO: allow -plain execution
	# TODO: allow shell initializer

	typemethod execute {argv} {
		# FIRST, set up the path.
		set ::env(TCLLIBPATH) [project libpath]

		# NEXT, we always start in the project root directory.
		cd [project root]

		# NEXT, set up the command.
		lappend command \
			[env pathto tclsh] \
			[env pathto tkcon]

		# NEXT, If there's an application, adds the first application's
		# loader to the command.
		if {[project gotapp]} {
			lappend command \
				[project app loader [lindex [project app names] 0]]
		}

		# NEXT, Execute the shell
		eval exec $command
	}
}

