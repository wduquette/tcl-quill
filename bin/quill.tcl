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

# quillinfo(n) is a generated package containing this project's 
# metadata.
package require quillinfo

# quill(n) is the package containing the bulk of the quill code.
package require app_quill
namespace import app_quill::*

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
