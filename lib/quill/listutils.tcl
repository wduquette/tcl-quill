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
        ladd         \
		lshift
}

#-------------------------------------------------------------------------
# Command Definitions


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





