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

# tagsplit tag text
#
# tag   - A -quill-*- tag, e.g., "ifneeded", "provide", "require"
# text  - Text from a file.
#
# The text is split into lines, and three lists of lines are returned:
# lines up to and including the -quill-$tag-begin line; subsequent lines,
# upto but not including the -quill-$tag-end line; and lines from the
# -quill-$tag-end line to the end of the file.
#
# If either or both tags are not found, returns the empty string.

proc ::quillapp::tagsplit {tag text} {
    set lines [split $text \n]
    set before [list]
    set block [list]
    set after [list]

    set state before

    while {[llength $lines] > 0} {
        set line [lshift lines]

        switch $state {
            before {
                lappend before $line
                if {[string match "# -quill-$tag-begin*" $line]} {
                    set state during
                }
            }

            during {
                if {![string match "# -quill-$tag-end*" $line]} {
                    lappend block $line 
                } else {
                    set state after
                    lappend after $line
                }
            }

            after {
                lappend after $line
            }
        }
    }

    if {[llength $after] == 0} {
        return ""
    }  else {
        return [list $before $block $after]
    }
}

