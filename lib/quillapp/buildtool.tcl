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
		# FIRST, get relevant data
		set guiflag [project app gui $app]
		set apptype [project app apptype $app]

		# NEXT, tell the user what we are doing.
		if {$guiflag} {
			puts "Building GUI app $app as '$apptype'..."
		} else {
			puts "Building Console app $app as '$apptype'..."
		}

		# NEXT, build up the command
		set command [list]

		# tclapp, app loader script, lib directories
		lappend command \
			[plat pathto tclapp] \
			[project root bin $app.tcl] \
			[project root lib * *]

		# Lib subdirectories?
		if {[llength [project glob lib * * *]] > 0} {
			lappend command \
				[project root lib * * *]
		}

		# Archive
		lappend command \
			-archive [plat pathof teapot]

		# Output file
		if {$apptype eq "exe"} {
			set outfile [project root bin [plat appfile $app]]
		} else {
			set outfile [project root bin $app.kit]
		}

		lappend command \
			-out $outfile

		# Prefix
		if {$apptype eq "exe"} {
			if {$guiflag} {
				set basekit [plat pathto tk-basekit]
			} else {
				set basekit [plat pathto tcl-basekit]
			}

			if {$basekit eq ""} {
				throw FATAL [outdent "
				    Error building app $app: no basekit found.
				"]
			}

			lappend command \
				-prefix $basekit
		}

		# Required packages
		if {$apptype ne "kit"} {
			foreach pkg [project require names] {
				set ver [project require version $pkg]
				lappend command \
					-pkgref "$pkg $ver"
			}
		}

		# Logging
		set log [project quilldir build_$app.log]
		lappend command \
			>& $log


		try {
			eval exec $command
		} on error {result eopt} {
			throw FATAL [outdent "
			    Error building app $app: $result
			    See $log for details.
			"]
		}
	}
}

