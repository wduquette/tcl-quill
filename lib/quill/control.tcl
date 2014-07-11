#-------------------------------------------------------------------------
# TITLE: 
#    control.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl
#
# DESCRIPTION:
#    control(n): Flow of Control commands
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Namespace Exports

namespace eval ::quill:: {
	namespace export \
		assert
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

proc ::quill::assert {expression} {
    if {[uplevel 1 [list expr $expression]]} {
        return
    }

    throw ASSERT "Assertion failed: $expression"
}

