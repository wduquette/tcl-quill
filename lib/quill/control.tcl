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
        callwith     \
        codecatch    \
        foroption    \
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


# foroption optvar listvar ?-all? body
#
# Iterates over the options in the named listvar, removing
# each option in turn using [lshift] and assigning it to the
# named optvar.  The body is a set of [switch] cases, one for each
# valid option (the default case is handled automatically).
# The command throws INVALID if it comes to an option it doesn't
# recognize.  The cases should retrieve option values using
# [lshift] on the listvar.
#
# By default, foroption stops on the first token it finds that
# doesn't begin with a hyphen "-".  If -all is given, it expects
# to consume the entire contents of the listvar, and throws 
# INVALID if it cannot.
#
# When foroption returns, the listvar will contain any remaining
# arguments.

proc ::quill::foroption {optvar listvar allflag {body ""}} {
    upvar $optvar opt
    upvar $listvar arglist

    # FIRST, process all or some?
    if {$body eq ""} {
        set body $allflag
        set all 0
    } else {
        if {$allflag ne "-all"} {
            error "Unexpected option: \"$allflag\""
        }

        set all 1
    }

    # NEXT, set up the switch command
    set switchcmd [format {
        switch -exact -- $%s {
            %s
            default { throw INVALID "Unknown option: \"$%s\"" }
        }
    } $optvar $body $optvar]

    while {
        [llength $arglist] > 0 &&
        ($all || [string index [lindex $arglist 0] 0] eq "-")
    } {
        set opt [lshift arglist]
        uplevel 1 $switchcmd
    }
}


# callwith prefix args...
#
# prefix    - A command prefix, or ""
# args      - Arguments to append to the prefix.
#
# If prefix is "", does nothing.  Otherwise, the args
# are appended to the prefix and the resulting command
# is called in the global scope.  Returns the resulting
# command's return value.

proc ::quill::callwith {prefix args} {
    if {[llength $prefix] == 0} {
        return
    }

    set command [concat $prefix $args]
    uplevel #0 $command
}
