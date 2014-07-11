#-------------------------------------------------------------------------
# TITLE: 
#    misc.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl
#
# DESCRIPTION:
#    misc(n): Miscellaneous small procs.
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Namespace Exports

namespace eval ::quillapp:: {
	namespace export \
		checkargs
}

#-------------------------------------------------------------------------
# Command Definitions

# checkargs command min max usage argv
#
# command   - The base command, e.g., "quill new"
# min       - The minimum number of commands (an integer)
# max       - The maximum number of commands (an integer or "-")
# usage     - The argument usage list, doc-style.
# argv      - The actual argument list
#
# Verifies that the right number of arguments are provided to a tool.

proc ::quillapp::checkargs {command min max usage argv} {
	set len [llength $argv]

	if {$len >= $min && ($max eq "-" || $len <= $max)} {
		return
	}

	throw FATAL "Usage: $command $usage"
}

