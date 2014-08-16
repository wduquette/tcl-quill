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
	argspec     {0 - "?app|lib? ?names..."}
	intree      true
	ensemble    ::quillapp::buildtool
}

set ::quillapp::help(build) {
	The "quill build" tool builds the project's applications and 
	provided libraries, as listed in the project.quill file.  By
	default, all applications and libraries are built.

	To build only the apps:

	    $ quill build app

	To build specific apps:

	    $ quill build app myfirstapp mysecondapp ...

	To build only the provided libraries:

	    $ quill build lib

	To build specific libraries:

	    $ quill build lib myfirstlib mysecondlib ...


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
		set targetType [lshift argv]
		set names $argv

		# FIRST, build provided libraries
		if {$targetType in {lib ""}} {
			if {[llength $names] == 0} {
				set names [project provide names]
			}
			foreach lib $names {
				BuildLibZip $lib
			}
		}

		# NEXT, build applications
		if {$targetType in {app ""}} {
			if {[llength $names] == 0} {
				set names [project app names]
			}
			foreach app $names {
				BuildTclApp $app
			}
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
		# FIRST, make sure the app is known.
		if {$app ni [project app names]} {
			throw FATAL "App \"$app\" is not defined in project.quill."
		}

		# NEXT, get relevant data
		set guiflag [project app gui     $app]
		set apptype [project app apptype $app]
		set outfile [project app target  $app]

		# NEXT, tell the user what we are doing.
		if {$guiflag} {
			puts "Building GUI app $app as '$apptype' $outfile"
		} else {
			puts "Building Console app $app as '$apptype' $outfile"
		}

		# NEXT, build up the command
		set command [list]

		# tclapp, app loader script, lib directories
		lappend command \
			[env pathto tclapp] \
			[project root bin $app.tcl] \
			[project root lib * *]

		# Lib subdirectories?
		if {[llength [project glob lib * * *]] > 0} {
			lappend command \
				[project root lib * * *]
		}

		# Archive
		lappend command \
			-archive [env pathof teapot]

		# Output file
		lappend command \
			-out $outfile

		# Prefix
		if {$apptype eq "exe"} {
			if {$guiflag} {
				set basekit [env pathto tk-basekit]
			} else {
				set basekit [env pathto tcl-basekit]
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

	#---------------------------------------------------------------------
	# Building Tcl Lib teapot .zip files

	# BuildLibZip lib
	#
	# lib   - The name of the library
	#
	# Creates a teapot.txt file for the library, and then packages
	# it into <root>/.quill/teapot/* for later installation.

	proc BuildLibZip {lib} {
		# FIRST, make sure the lib is known.
		if {$lib ni [project provide names]} {
			throw FATAL "No such library is provided in project.quill: \"$lib\""
		}
		
		# NEXT, save the teapot.txt file.
		set teapotTxt [outdent "
			Package          $lib [project version]
    		Meta entrykeep 
    		Meta included    *
    		Meta platform    tcl
		"]

		writefile [project root lib $lib teapot.txt] $teapotTxt

		# NEXT, make sure the output directory exists.
		set outdir [project root .quill teapot]
		file mkdir $outdir

		# NEXT, prepare the packaging command
		set command ""
		lappend command [env pathto teapot-pkg] generate \
			-t zip                                        \
			-o $outdir                                    \
			[project root lib $lib]

		# NEXT, call the command
		set outfile [file join $outdir package-$lib-[project version]-tcl.zip]
		puts "\nBuilding lib $lib:"
		puts [eval exec $command]
	}
}

