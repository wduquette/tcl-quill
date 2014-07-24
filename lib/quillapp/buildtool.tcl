#-------------------------------------------------------------------------
# TITLE: 
#    buildtool.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    "quill build" tool implementation.  This tool builds project build
#    targets.
#
#    TODO: Allow building particular targets.
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Register the tool

set ::quillapp::tools(build) {
	command     "build"
	description "Build applications and libraries"
	argspec     {0 0 ""}
	intree      true
	ensemble    ::quillapp::buildtool
}

set ::quillapp::help(build) {
	The "quill build" tool builds the project's applications and 
	provided libraries, as listed in the project.quill file.
}

#-------------------------------------------------------------------------
# Namespace Export

namespace eval ::quillapp:: {
	namespace export \
		buildtool
} 

#-------------------------------------------------------------------------
# Tool Singleton: buildtool

snit::type ::quillapp::buildtool {
	# Make it a singleton
	pragma -hasinstances no -hastypedestroy no

	# execute argv
	#
	# argv - command line arguments for this tool
	# 
	# Executes the tool given the arguments.

	typemethod execute {argv} {
		# FIRST, build provided libraries
		foreach lib [project provide names] {
			puts "TODO: Build library $lib!"
		}

		# NEXT, build applications
		foreach app [project app names] {
			BuildTclApp $app
		}
	}

	#---------------------------------------------------------------------
	# Building Tcl Apps

	# BuildTclApp app
	#
	# app  - The name of the application
	#
	# Builds the application using tclapp.

	proc BuildTclApp {app} {
		
	}
}

