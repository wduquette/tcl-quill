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
		assert       \
        codecatch    \
        precond      \
        require
}

#-------------------------------------------------------------------------
# Command Definitions

# assert expression
#
# expression  - A boolean expression
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

# codecatch script
#
# script   - A tcl script
#
# Executes the script in the caller's context, catching the result.  
# Returns a 2-element list, the errorCode and the error message. If 
# there was no error, returns "ok" and the return value.

proc ::quill::codecatch {script} {
    try {
        set output [uplevel 1 $script]
    } on error {result eopts} {
        return [list [dict get $eopts -errorcode] $result]
    }

    return [list ok $output]
}


# precond expression message
#
# This command is used for checking procedure preconditions: invariants
# on the command's arguments, which will never be false in a properly 
# written program.
#
# If the precondition fails an error is thrown indicating that a
# precondition failed, with the given message.  The error code is
# ASSERT.

proc ::quill::precond {expression message} {
    if {[uplevel 1 [list expr $expression]]} {
        return
    }

    throw ASSERT $message
}

# require expression message ?errorCode?
#
# This command is used to validate user input.  Require evaluates the
# expression, and returns silently if it is true.  If it is false,
# require throws an error with the given message and error code,
# which defaults to INVALID.
#
# This allows the user interface to distinguish between validation
# errors and unexpected programming errors.

proc ::quill::require {expression message {errorCode INVALID}} {
    if {[uplevel 1 [list expr $expression]]} {
        return
    }

    throw $errorCode $message
}