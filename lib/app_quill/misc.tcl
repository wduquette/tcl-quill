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

namespace eval ::app_quill:: {
	namespace export \
		checkargs    \
        gentree      \
        into         \
        outof        \
        prepare      \
        tagsplit     \
        tagreplace   \
        verxy
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

proc ::app_quill::checkargs {command min max usage argv} {
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

proc ::app_quill::tagsplit {tag text} {
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

# tagreplace tag text newblock
#
# tag       - A "-quill-$tag-begin/end" tag
# text      - A text string possibly containing the tag.
# newblock  - New text to replace the tagged block.
#
# Replaces the tagged block with the new block text, and returns
# the result.

proc ::app_quill::tagreplace {tag text newblock} {
    set result [tagsplit $tag $text]

    # No such tag.  Return the text unchange.
    if {[llength $result] == 0} {
        return $text
    } 

    lassign $result before block after

    return "[join $before \n]\n$newblock\n[join $after \n]"
}


# prepare var options...
#
# var   - A variable name
#
# Options:
#    -file      - Value must make a good file name (no special characters
#                 or internal whitespace).
#    -oneof     - A list of valid values
#    -listof    - A list of valid values.
#    -required  - Value must be non-empty
#    -tighten   - Condenses internal whitespace
#    -toupper   - Converts value to upper case
#    -tolower   - Converts value to lower case
#    -type      - A validation type; the value must be valid.
#
# Prepares a variable's content for validation, and in some cases
# does the validation.  In particular, values are "trimmed" automatically.

proc ::app_quill::prepare {var args} {
    upvar 1 $var theVar

    set theVar [string trim $theVar]

    foroption opt args -all {
        -file {
            if {$theVar ne "" && ![regexp {^[-[:alnum:]._]+$} $theVar]} {
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

        -listof {
            set values [lshift args]

            foreach val $theVar {
                if {$val ni $values} {
                    throw INVALID \
            "Input \"$var\" isn't a list of ([join $values {, }]): \"$theVar\""
                }
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
    }

    return $theVar
}

# gentree path content...
#
# path    - A path relative to the project root, using "/" as the
#           separator.
# content - Content to write to the path.
#
# The input is a set of path and content pairs.

proc ::app_quill::gentree {args} {
    # NEXT, process the files
    foreach {path content} $args {
        # FIRST get the paths
        set p [project root {*}[split $path /]]

        # NEXT, generate the files.
        writefile $p $content
    }
}

# verxy version
#
# Returns the x.y from a possibly longer version.

proc ::app_quill::verxy {version} {
    set vlist [split $version .]
    return [join [lrange $vlist 0 1] .]
}

# into dictvar keys... value
#
# dictvar   - A dictionary variable
# keys...   - One or more keys
# value     - A value
#
# Alias for dict set

interp alias {} ::app_quill::into {} dict set

# outof dict keys... 
#
# dict      - A dictionary 
# keys...   - One or more keys
#
# Alias for dict get

interp alias {} ::app_quill::outof {} dict get
