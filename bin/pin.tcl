#!/bin/sh
# -*-tcl-*-
# the next line restarts using tclsh\
exec tclsh "$0" "$@"

#-------------------------------------------------------------------------
# NAME: pin.tcl
#
# PROJECT:
#  Tcl-Pinion: A Project Build System for Tcl/Tk
#
# DESCRIPTION:
#  Loader script for the pin(1) tool.
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Prepare to load application

set bindir [file dirname [info script]]
set libdir [file normalize [file join $bindir .. lib]]

set auto_path [linsert $auto_path 0 $libdir]

package require Tcl 8.6
package require snit 2.3

# pinion(n) is a generated package containing this project's 
# metadata.
# TODO: package require pinion -- needed for project info.

# pin(n) is the package containing the bulk of the Pinion code.
package require pin

#-------------------------------------------------------------------------
# Main Routine

# main argv
#
# argv - Command line arguments

proc main {argv} {
	puts "Hello, <$argv>"
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
	puts "Unexpected error: $result\n"
	puts [dict get $eopt -errorinfo]
}
