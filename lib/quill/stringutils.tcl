#-------------------------------------------------------------------------
# TITLE: 
#    stringutils.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl
#
# DESCRIPTION:
#    stringutils(n): String Utilities
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Namespace Exports

namespace eval ::quill:: {
	namespace export \
		outdent      \
		tighten
}

#-------------------------------------------------------------------------
# Command Definitions


# outdent text
#
# text   - A multi-line text string
#
# This command outdents a multi-line text string to the left margin.

proc ::quill::outdent {text} {
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

proc ::quill::tighten {text} {
    regsub -all {\s+} $text " " text
    
    return [string trim $text]
}

