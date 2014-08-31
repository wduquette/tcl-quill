#-----------------------------------------------------------------------
# TITLE:
#    smartinterp.tcl
#
# AUTHOR:
#    Will Duquette
#
# PROJECT:
#    Tcl-quill: A Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    quill(n) module, smartinterp(n): Smart Tcl Interpreter
#
#    This module defines a wrapper for Tcl interps with extra methods 
#    for defining commands with the interpreter.  The created interp
#    may be safe or unsafe.
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Export commands

namespace eval ::quill:: {
    namespace export smartinterp
}

#-----------------------------------------------------------------------
# smartinterp: smart Tcl interpreter

snit::type ::quill::smartinterp {
    #-------------------------------------------------------------------
    # Components

    component interp   ;# Tcl interpreter

    #-------------------------------------------------------------------
    # Options

    # -commands all|safe|none
    #
    # Specifies the set of commands to include in the interpreter:
    # all of the standard commands, only the safe commands, or
    # no commands at all.  This flag must be set when the interp is
    # created.
 
    option -commands  \
        -default  all \
        -readonly yes \
        -type     {snit::enum -values {all safe none}}


    #-------------------------------------------------------------------
    # Instance Variables

    # alias -- the smartalias table
    #
    #     ensemble-$name      1 if ensemble, 0 if not.
    #
    # When ensemble-$name is 1:
    #
    #     subcommands-$name   A list of the known subcommands.
    #
    # When ensemble-$name is 0:
    #
    #     arglist-$name       The alias's argument list
    #     syntax-$name        The alias's syntax string
    #     command-$name       The alias's command prefix

    variable alias

    #-------------------------------------------------------------------
    # Constructor

    constructor {args} {
        # FIRST, get the option values
        $self configurelist $args

        # NEXT, create the interpreter; name it so that it will be
        # destroyed automatically.
        if {$options(-commands) eq "all"} {
            set interp [interp create       -- ${selfns}::interp]
        } else {
            set interp [interp create -safe -- ${selfns}::interp]

            if {$options(-commands) eq "none"} {
                foreach cmd [$interp eval {info commands}] {
                    $interp hide $cmd
                }

                # FIXME: What about commands in namespaces?
            }
        }
    }

    #-------------------------------------------------------------------
    # Public Methods

    # Delegated methods
    delegate method *  to interp

    # clone srcProc targetProc
    #
    # srcProc      Proc name in slave
    # targetProc   Proc name in master
    #
    # Clones the named targetProc into the interpreter as srcProc.

    method clone {srcProc targetProc} {
        set def [lreplace [uplevel 1 [list code getproc $targetProc]] 1 1 $srcProc]
        $interp eval $def
    }

    # proc name arglist body
    #
    # name      The proc's name
    # arglist   The proc's arglist
    # body      The proc's body
    #
    # Defines a proc in the context of the interpreter.  This is 
    # equivalent to doing $interp eval { proc ... }.
    
    method proc {name arglist body} {
        $interp eval [list proc $name $arglist $body]
    }

    # ensemble name
    #
    # name    The ensemble command's name.
    #
    # Creates an ensemble.  If the name consists of two or more
    # elements, the leading elements must be the name of a
    # previously defined ensemble.

    method ensemble {name} {
        # FIRST, require that the parent command (if any) is already
        # defined as an ensemble.
        $self RequireThatParentIsEnsemble $name

        # NEXT, add it to the table as an ensemble
        set alias(ensemble-$name)    1
        set alias(subcommands-$name) {}

        # NEXT, if it has an ensemble parent, add the last token of
        # the name to the parent's list of subcommands.
        if {[llength $name] > 1} {
            set parent [lrange $name 0 end-1]
            set subcommand [lindex $name end]
            lappend alias(subcommands-$parent) $subcommand
        }

        # NEXT, this is a root ensemble (only one token) alias the
        # ensemble handler into the interpreter
        if {[llength $name] == 1} {
            $self alias $name $self EnsembleHandler $name
        }
    }



    # smartalias name syntax minArgs maxArgs prefix
    #
    # name       The alias name; may be a list.
    # syntax     The syntax string, excluding the name
    # minArg     The minimum number of arguments required
    # maxArgs    The maximum number of arguments allowed, or "-"
    #            for any number.
    # prefix     The command prefix of which name is an alias.
    #
    # Creates a smart alias.  If the name consists of two or more
    # elements, the leading elements must be the name of a
    # previously defined ensemble.

    method smartalias {name syntax minArgs maxArgs prefix} {
        # FIRST, require that the parent command (if any) is already
        # defined as an ensemble.
        $self RequireThatParentIsEnsemble $name

        # NEXT, save the alias data.
        set alias(ensemble-$name) 0
        set alias(min-$name)      $minArgs
        set alias(max-$name)      $maxArgs
        set alias(command-$name)  $prefix

        if {$syntax eq ""} {
            set alias(syntax-$name) "$name"
        } else {
            set alias(syntax-$name) "$name $syntax"
        }

        # NEXT, if it has an ensemble parent, add the last token of
        # the name to the parent's list of subcommands.
        if {[llength $name] > 1} {
            set parent [lrange $name 0 end-1]
            set subcommand [lindex $name end]
            lappend alias(subcommands-$parent) $subcommand
        }

        # NEXT, create the actual alias
        $self alias $name $self SmartAliasHandler $name
    }

    # RequireThatParentIsEnsemble name
    #
    # name       The alias/ensemble name
    #
    # If name is multiword, verifies that the leading element is an
    # ensemble.

    method RequireThatParentIsEnsemble {name} {
        if {[llength $name] > 1} {
            set parent [lrange $name 0 end-1]
            precond {
                [info exists alias(ensemble-$parent)] &&
                $alias(ensemble-$parent)
            } "parent is not an ensemble: \"$parent\""
        }
    }


    # EnsembleHandler name args
    #
    # name       The root ensemble name.
    # args       The arguments passed to the ensemble.
    #
    # Dispatches the command to the ensemble's subcommand, handling
    # nested ensembles on the way.  Eventually, the real command
    # is called at global scope.

    method EnsembleHandler {name args} {
        # FIRST, find the smart alias, tracing down the tree of
        # nested ensembles.

        while {$alias(ensemble-$name)} {
            # FIRST, do we have a subcommand?
            require {[llength $args] > 0} \
                "wrong # args: should be \"$name subcommand ?arg arg...?\""

            lappend name [lshift args]

            require {[info exists alias(ensemble-$name)]} \
                [$self SubcommandError $name]
        }

        # NEXT, we have the smart alias name, and the args for it.
        eval [list $self SmartAliasHandler $name] $args
    }

    # SubcommandError name
    #
    # name     A bad ensemble/subcommand pair
    #
    # Returns the appropriate error message

    method SubcommandError {name} {
        set parent [lrange $name 0 end-1]
        set subcommand [lindex $name end]

        set subs $alias(subcommands-$parent)

        if {[llength $subs] == 2} {
            set subs [join $subs " or "]
        } elseif {[llength $subs] > 2} {
            set last [lindex $subs end]
            set subs [join [lrange $subs 0 end-1] ", "]
            append subs " or $last"
        }

        return "bad subcommand \"$subcommand\": must be $subs"
    }

    # SmartAliasHandler name args
    #
    # name       The alias.
    # args       The arguments passed to the alias.
    #
    # Matches args to the alias's arglist, and throws
    # any resulting error.  Otherwise, calls the real command at 
    # global scope.

    method SmartAliasHandler {name args} {
        set len [llength $args]

        if {$len < $alias(min-$name) ||
            ($alias(max-$name) ne "-" && $len > $alias(max-$name))
        } {
            return -code error -errorcode USER \
                "wrong # args: should be \"$alias(syntax-$name)\""

        }

        uplevel \#0 $alias(command-$name) $args
    }
}
