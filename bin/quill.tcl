#!/bin/sh
# -*-tcl-*-
# the next line restarts using tclsh\
exec tclsh "$0" "$@"

#-------------------------------------------------------------------------
# NAME: quill.tcl
#
# PROJECT:
#  Quill: A Project Build System for Tcl/Tk
#
# DESCRIPTION:
#  Loader script for the quill(1) tool.
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Prepare to load application

set bindir [file dirname [info script]]
set libdir [file normalize [file join $bindir .. lib]]

set auto_path [linsert $auto_path 0 $libdir]

package require Tcl 8.6
package require snit 2.3

# quillinfo(n) is a generated package containing this project's 
# metadata.
# TODO: package require quillinfo -- needed for project info.

# quill(n) is the package containing the bulk of the quill code.
package require quill
namespace import quill::*

#-------------------------------------------------------------------------
# Main Routine

# main argv
#
# argv - Command line arguments

proc main {argv} {
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

	if {![info exists ::quill::tools($tool)]} {
		throw FATAL [outdent "
			Unknown subcommand: \"$tool\"
			See 'quill help' for a list of commands.
		"]
	}

	# NEXT, check the number of arguments.
	checkargs "quill $tool" {*}[dict get $::quill::tools($tool) argspec] $argv

	# NEXT, load the project info if the tool needs it.
	if {[dict get $quill::tools($tool) intree]} {
		if {![project intree]} {
			throw FATAL [outdent {
				This tool can only be used in a project tree.
				See "quill help" for more information.
			}]
		}
		project loadinfo
	}

	# NEXT, execute the tool.
	set cmd [dict get $quill::tools($tool) ensemble]
	$cmd execute $argv

	puts ""
}

#-------------------------------------------------------------------------
# Invoke the application

try {
	# Skip main if we're running interactively; this allows for 
	# interactive testing.
	if {!$tcl_interactive} {
		main $argv
	}
} trap FATAL {result} {
	# The application has flagged a FATAL error; display it and halt.
	puts $result
	exit 1
} on error {result eopt} {
	puts "Unexpected error: $result"
	puts "([dict get $eopt -errorcode])\n"
	puts [dict get $eopt -errorinfo]
}
