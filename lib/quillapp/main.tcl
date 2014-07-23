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

	# NEXT, if there are no arguments then just display the help.
	if {[llength $argv] == 0} {
		helptool execute {}
		return
	}

	# NEXT, get the tool
	set tool [lshift argv]

	if {![info exists ::quillapp::tools($tool)]} {
		throw FATAL [outdent "
			Unknown subcommand: \"$tool\"
			See 'quill help' for a list of commands.
		"]
	}

	# NEXT, check the number of arguments.
	checkargs "quill $tool" \
		{*}[dict get $::quillapp::tools($tool) argspec] $argv

	# NEXT, load the project info if the tool needs it.
	if {[dict get $quillapp::tools($tool) intree]} {
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
	set cmd [dict get $quillapp::tools($tool) ensemble]
	$cmd execute $argv

	puts ""
}
