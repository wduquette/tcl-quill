#-------------------------------------------------------------------------
# TITLE: 
#    misc.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Pinion: Project Build System for Tcl
#
# DESCRIPTION:
#    Miscellaneous small procs.
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Namespace Exports

namespace eval ::pin:: {
	namespace export \
		assert       \
		checkargs    \
		lshift       \
		outdent      \
		readfile     \
		tighten
}

#-------------------------------------------------------------------------
# Command Definitions

# assert expression
#
# This command is used for checking procedure invariants: conditions
# which logically must be true if the procedure is written correctly,
# which will never be false in a properly written program.
#
# If the assertion fails an error is thrown indicating that an assertion 
# failed and what the condition was.  Assertions throw the error code
# ASSERT.

proc ::pin::assert {expression} {
    if {[uplevel 1 [list expr $expression]]} {
        return
    }

    throw ASSERT "Assertion failed: $expression"
}

# checkargs command min max usage argv
#
# command   - The base command, e.g., "pin new"
# min       - The minimum number of commands (an integer)
# max       - The maximum number of commands (an integer or "-")
# usage     - The argument usage list, doc-style.
# argv      - The actual argument list
#
# Verifies that the right number of arguments are provided to a tool.

proc ::pin::checkargs {command min max usage argv} {
	set len [llength $argv]

	if {$len >= $min && ($max eq "-" || $len <= $max)} {
		return
	}

	throw FATAL "Usage: $command $usage"
}

# ladd listvar value
#
# listvar - The name of a list variable
# value   - A value to add the list
#
# Adds the value to the list if it isn't already present.  Returns
# the new list.

proc ::pin::ladd {listvar value} {
	upvar 1 $listvar theList

	if {$value ni $theList} {
		lappend theList $value
	}

	return $theList
}

# lshift listvar
#
# listvar  - The name of a list variable
#
# Pops and returns the argument from the front of the list stored
# in the variable.

proc ::pin::lshift {listvar} {
    upvar 1 $listvar thelist

    set result [lindex $thelist 0]
    set thelist [lrange $thelist 1 end]

    return $result
}

# outdent text
#
# text   - A multi-line text string
#
# This command outdents a multi-line text string to the left margin.

proc ::pin::outdent {text} {
    # FIRST, remove any leading blank lines
    regsub {\A(\s*\n)} $text "" text

    # NEXT, remove any trailing whitespace
    set text [string trimright $text]

    # NEXT, get the length of the leading on the first line.
    if {[regexp {\A(\s*)\S} $text dummy leader]} {

        # Remove the leader from the beginning of each indented
        # line, and update the string.
        regsub -all -line "^$leader" $text "" text
    }

    return $text
}


# tighten text
#
# text     - A text string
#
# Tightens the text string by removing excess whitespace.  Leading and
# trailing whitespace is trimmed, and all internal whitespace
# is replaced with single space characters between non-whitespace tokens.

proc ::pin::tighten {text} {
    regsub -all {\s+} $text " " text
    
    return [string trim $text]
}

# readfile filename
#
# filename  - A filename
#
# Opens the named file and reads it into memory.

proc ::pin::readfile {filename} {
	set f [open $filename r]

	try {
		return [read $f]		
	} finally {
		close $f
	}
}

