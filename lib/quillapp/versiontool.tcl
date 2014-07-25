#-------------------------------------------------------------------------
# TITLE: 
#    versiontool.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    "quill version" tool implementation.  This tool outputs the Quill
#    version information to the console.
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Register the tool

set ::quillapp::tools(version) {
	command     "version"
	description "Displays the Quill tool's version to the console."
	argspec     {0 0 ""}
	intree      false
	ensemble    ::quillapp::versiontool
}

set ::quillapp::help(version) {
	The "quill version" tool displays the Quill application's version
	to the console in human-readable form.  In addition, it lists the
	specific helper tools being used by Quill.  

	The Tcl shell is that used to execute Quill; the other applications are
	found relative to the Tcl shell where possible, or on the path when
	not.
}

#-------------------------------------------------------------------------
# Namespace Export

namespace eval ::quillapp:: {
	namespace export \
		versiontool
} 

#-------------------------------------------------------------------------
# Tool Singleton: versiontool

snit::type ::quillapp::versiontool {
	# Make it a singleton
	pragma -hasinstances no -hastypedestroy no

	# execute argv
	#
	# argv - command line arguments for this tool
	# 
	# Executes the tool given the arguments.

	typemethod execute {argv} {
		puts "Quill [quillinfo version]: [quillinfo description]"
		puts ""
		puts "Home Page: [quillinfo homepage]"
		puts ""
		puts "Please submit bug reports to the issue tracker at the home page."
		puts ""
		puts "Helper Tools:"

		DisplayPath tclsh
		DisplayPath tkcon
		DisplayPath teacup 
		DisplayPath tclapp
		DisplayPath tcl-basekit
		DisplayPath tk-basekit

		puts ""
		puts "Local Teapot: [plat pathof teapot]"
	}

	# DisplayPath tool
	#
	# tool - The tool name
	#
	# Displays the path, and whether the tool can be found or not.

	proc DisplayPath {tool} {
		set path [plat pathto $tool]

		if {[file isfile $path]} {
			set flag ""
		} else {
			set flag " (NOT FOUND)"
		}

		puts [format "    %-12s %s%s" $tool $path $flag]
	}
}

