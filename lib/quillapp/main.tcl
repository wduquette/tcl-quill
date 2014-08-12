#-------------------------------------------------------------------------
# TITLE: 
#    main.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    "quill" app's Main routine.
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Namespace Export

namespace eval ::quillapp:: {
	namespace export \
		main
} 

#-------------------------------------------------------------------------
# App "quill": main routine

# main argv
#
# argv - Command line arguments

proc ::quillapp::main {argv} {
	# FIRST, are we in a project tree, and if so what's the project
	# root?
	project findroot

	# NEXT, load the configuration data.
	config init

	# NEXT, if there are no arguments then just display the help.
	if {[llength $argv] == 0} {
		helptool execute {}
		return
	}

	# NEXT, get the subcommand.  It must be either a .tcl file to execute,
	# or one of Quill's tools.
	set projectInfoNeeded 0
	set tool [lshift argv]

	if {[file isfile $tool]} {
		set userScript [file normalize $tool]
		set tool "UserScript"
		set projectInfoNeeded 1
	} else {
		if {![info exists ::quillapp::tools($tool)]} {
			throw FATAL [outdent "
				Unknown subcommand: \"$tool\"
				See 'quill help' for a list of commands.
			"]
		}
		# NEXT, check the number of arguments.
		checkargs "quill $tool" \
			{*}[dict get $::quillapp::tools($tool) argspec] $argv

		if {[dict get $quillapp::tools($tool) intree]} {
			set projectInfoNeeded 1
		}
	}

	# NEXT, load the project info if the tool needs it.
	if {$projectInfoNeeded} {
		# FIRST, fail if we need to be a project and we aren't.
		if {![project intree]} {
			throw FATAL [outdent {
				This tool can only be used in a project tree.
				See "quill help" for more information.
			}]
		}

		# NEXT, load the project info.
		project loadinfo

		# NEXT, save the project metadata, in case it has changed.
		project quillinfo save
	}

	# NEXT, execute the tool.
	if {$tool eq "UserScript"} {
		ExecuteScript $userScript $argv
	} else {
		set cmd [dict get $quillapp::tools($tool) ensemble]
		$cmd execute $argv
	}

	puts ""
}

# ExecuteScript path argv
#
# path  - The full path to the script file
# argv  - Arguments for the script.
#
# Attempts to execute the script in the context of the project.

proc ExecuteScript {path argv} {
	# FIRST, prepare the environment.
	set ::env(TCLLIBPATH) [project libpath]

	# NEXT, run the tests.
	exec [plat pathto tclsh] $path {*}$argv >@ stdout 2>@ stderr
}
