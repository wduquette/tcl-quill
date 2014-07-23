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

# prepare var options...
#
# var   - A variable name
#
# Options:
#    -file      - Value must make a good file name (no special characters
#                 or internal whitespace).
#    -oneof     - A list of valid values
#    -required  - Value must be non-empty
#    -tighten   - Condenses internal whitespace
#    -toupper   - Converts value to upper case
#    -tolower   - Converts value to lower case
#    -type      - A validation type; the value must be valid.
#
# Prepares a variable's content for validation, and in some cases
# does the validation.  In particular, values are "trimmed" automatically.

proc ::quillapp::prepare {var args} {
    upvar 1 $var theVar

    set theVar [string trim $theVar]

    while {[llength $args] > 0} {
        set opt [lshift args]

        switch -exact -- $opt {
            -file {
                if {![regexp {^[-[:alnum:]_]+$} $theVar]} {
                    throw INVALID \
                        "Input \"$var\" contains illegal characters or whitespace: \"$theVar\""
                }
            }

            -oneof {
                set values [lshift args]

                if {$theVar ni $values} {
                    throw INVALID \
                        "Input \"$var\" is not one of ([join $values {, }]): \"$theVar\""
                }
            }

            -required {
                if {$theVar eq ""} {
                    throw INVALID \
                        "Input \"$var\" requires a non-empty value."
                }
            }

            -tighten {
                set theVar [tighten $theVar]
            }

            -toupper {
                set theVar [string toupper $theVar]
            }

            -tolower {
                set theVar [string tolower $theVar]
            }

            -type {
                set theType [lshift args]

                set theVar [{*}$theType validate $theVar]
            }

            default {
                error "Unknown option: \"$opt\""
            }
        }
    }
}