#-------------------------------------------------------------------------
# TITLE: 
#    listutils.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl
#
# DESCRIPTION:
#    listutils(n): List Utilities
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Namespace Exports

namespace eval ::quill:: {
	namespace export \
        got          \
        interleave   \
        ladd         \
        ldelete      \
        lmaxlen      \
		lshift
}

#-------------------------------------------------------------------------
# Command Definitions

# got list
#
# list  - A list
#
# Returns 1 if the list has any elements, and 0 otherwise.

proc ::quill::got {list} {
    expr {[llength $list] > 0}
}

# ladd listvar value...
#
# listvar - The name of a list variable
# values  - Values to add to the list
#
# Adds each value to the list if it isn't already present.  Returns
# the new list.

proc ::quill::ladd {listvar args} {
	upvar 1 $listvar theList

    foreach value $args {
        if {$value ni $theList} {
            lappend theList $value
        }
    }

	return $theList
}

# ldelete listvar value...
#
# listvar - The name of a list variable
# values  - Values to delete from the list if present.
#
# Removes each value from the list var if it is present.  Returns
# the new list.

proc ::quill::ldelete {listvar args} {
    upvar 1 $listvar theList

    foreach value $args {
        set i [lsearch -exact $theList $value]
        if {$i != -1} {
            set theList [lreplace $theList $i $i]
        }
    }

    return $theList
}

# lmaxlen list
#
# list  - A list value
#
# Returns the string length of the longest element of the list.

proc ::quill::lmaxlen {list} {
    set max 0

    foreach item $list {
        set len [string length $item]

        if {$len > $max} {
            set max $len
        }
    }

    return $max
}


# lshift listvar
#
# listvar  - The name of a list variable
#
# Pops and returns the argument from the front of the list stored
# in the variable.

proc ::quill::lshift {listvar} {
    upvar 1 $listvar thelist

    set result [lindex $thelist 0]
    set thelist [lrange $thelist 1 end]

    return $result
}

# interleave keys values
#
# keys   - A list of keys
# values - A list of values
#
# Given two lists, one of keys and one of values, returns a list
# of interleaved keys and values.  If the lists are the same 
# length, and the keys are all unique, the result is a valid
# dictionary.

proc ::quill::interleave {keys values} {
    set result [list]

    foreach key $keys value $values {
        lappend result $key $value
    }

    return $result
}




