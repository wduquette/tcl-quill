#-----------------------------------------------------------------------
# TITLE:
#    parmset.tcl
#
# AUTHOR:
#    Will Duquette
#
# DESCRIPTION:
#    quill(n) module: Parameter Sets
#
#    A parameter set is a set of parameters with typed values whose
#    name can implicitly define a hierarchical relationship between
#    parameters by means of "."'s.
#
#-----------------------------------------------------------------------

namespace eval ::quill:: {
    namespace export parmset
}

snit::type ::quill::parmset {

    #-------------------------------------------------------------------
    # Type Constructor

    typeconstructor {
        namespace import ::quill::*
    }

    #-------------------------------------------------------------------
    # Options

    # -notifycmd
    #
    # Specifies a command to be called when a parameter's value is set.
    # The command is called with one additional argument, the name of
    # the updated parameter.  On "load", when many parameters might
    # have changed, the argument is the empty string.

    option -notifycmd -default ""

    #-------------------------------------------------------------------
    # Instance Variables

    # info -- array of scalar data
    #
    # ignoreSetErrors  - If yes, invalid "set" arguments are ignored.
    #                    This is used when loading a file in
    #                    -forgiving mode.
    #
    # callNotify       - If yes, call -notifycmd on set.  This is set
    #                    to no when loading a file, when we want to
    #                    call -notifycmd just once at the end.

    variable info -array {
        ignoreSetErrors no
        callNotify      yes
    }

    # values: Array of current values by parameter name.  Contains only 
    # parameter names, i.e., leaf nodes.

    variable values

    # schema: Array of schema data: types and default values
    #
    # schema(type-$name)      - Validation type for parameter $name
    # schema(default-$name)   - Default value for parameter $name

    variable schema


    #-------------------------------------------------------------------
    # Methods

    # names ?pattern?
    #
    # pattern     A glob pattern; defaults to "*"
    #
    # Returns a sorted list of the parameter names which match the
    # pattern.

    method names {{pattern *}} {
        return [lsort -dictionary [array names values $pattern]]
    }

    # define name ptype value
    #
    # name    - The parameter name
    # ptype   - The parameter's validation type.
    # value   - The parameter's default value.
    #
    # Define a new parameter, giving it a default value.  If the parameter
    # already exists, it is redefined.

    method define {name ptype value} {
        # FIRST, validate the name
        precond {[regexp {^\S+$} $name]} \
            "Parameter name contains whitespace: \"$name\""

        # NEXT, validate the value
        try {
            set value [$ptype validate $value]
        } trap INVALID {result} {
            error "Invalid default value, parm '$name': $result"
        }

        # NEXT, save the parameter definition
        set schema(type-$name)    $ptype
        set schema(default-$name) $value
        set values($name)         $value

        return
    }

    # exists name
    #
    # name   - A parameter name
    #
    # Returns 1 if there's a parameter called name, and false otherwise.

    method exists {name} {
        return [info exists values($name)]
    }

    # type name
    #
    # name   - A parameter name
    #
    # Returns the parameter's type.  It's an error if the parameter
    # doesn't exist.

    method type {name} {
        precond {[$self exists $name]} "No such parameter: $name"

        return $schema(type-$name)
    }

    # getdefault name
    #
    # name   - A parameter name
    #
    # Returns the parameter's default value.  It's an error if the
    # parameter doesn't exist.

    method getdefault {name} {
        precond {[$self exists $name]} "No such parameter: $name"

        return $schema(default-$name)
    }

    # list ?pattern?
    #
    # pattern   - A glob pattern; defaults to "*"
    #
    # Returns a sorted list of the parameter names which match the
    # pattern, and their values, in two columns.

    method list {{pattern *}} {
        set names [$self names $pattern]

        set wid [lmaxlen $names]

        set out ""

        foreach name $names {
            append out [format "%-*s %s\n" $wid $name [list $values($name)]]
        }

        return $out
    }

    # clear
    #
    # Sets all parameters back to their default values.

    method clear {} {
        foreach name [array names values] {
            set values($name) $schema(default-$name)
        }

        if {$info(callNotify)} {
            callwith $options(-notifycmd) ""
        }
    }

    # set name value
    # 
    # name    - The parameter name
    # value   - The parameter's new value.
    #
    # Give a parameter a new value.  Throws INVALID if the value
    # is invalid for the parameter's type.

    method set {name value} {
        if {![$self exists $name]} {
            if {$info(ignoreSetErrors)} {
                return
            }

            throw INVALID "No such parameter: $name"
        }
        
        # FIRST, validate the type
        try {
            set value [$schema(type-$name) validate $value]
        } trap INVALID {result} {
            if {$info(ignoreSetErrors)} {
                # Return the old value.
                set value $values($name)
            } else {
                throw INVALID "Parm '$name': $result"
            }
        }

        set values($name) $value

        if {$info(callNotify)} {
            callwith $options(-notifycmd) $name
        }
    }

    # get name
    #
    # name - The parameter name.
    #
    # Get a parameter's value.  Returns "" if the parameter doesn't
    # exist.

    method get {name} {
        if {[info exists values($name)]} {
            return $values($name)
        }

        return ""
    }


    #-----------------------------------------------------------------------
    # Saving and Loading parmsets

    # save filename ?header?
    #
    # filename  - A file name
    # header    - Text for the header line. Defaults to "Parameter values"
    #
    # Saves the parmset to a file.  Any existing file will get replaced
    # (unless it's readonly, etc.)

    method save {filename {header {Parameter values}}} {
        # FIRST, open the file
        set f [open $filename w]

        set header [join [split $header "\n"] "\n# "]

        puts $f "# $header"
        puts $f "# [clock format [clock seconds]]"
        puts $f ""

        # NEXT, write all of the parameter values
        set names [$self names]
        set wid [lmaxlen $names]

        foreach name $names {
            if {$values($name) ne $schema(default-$name)} {
                puts $f [format "parm %-*s %s" $wid $name [list $values($name)]]
            }
        }

        # NEXT, close the file
        puts $f ""
        puts $f "# End of file"
        
        close $f

        return
    }

    # load filename -strict|-forgiving
    #
    # filename   - A file to load
    # mode       - -strict, -forgiving
    #
    # Loads a saved parmset file.  If mode is -strict,
    # then unknown parameters and known parameters with 
    # invalid values will cause an error; if mode is -forgiving,
    # then unknown parameters and known parameters with invalid
    # values are ignored.  If an error is thrown, the parmset's current
    # content will be unchanged.

    method load {filename {mode -strict}} {
        require {[file exists $filename]} \
            "No such file: \"[file normalize $filename]\"" \
            {PARMSET NOFILE}

        # FIRST, create the interpreter to parse the file.
        set interp [smartinterp %AUTO% -commands none]

        $interp smartalias parm "name value" 2 2 [mymethod set]

        # NEXT, save the current values.
        set oldValues [array get values]

        # NEXT, don't call the notify command until we're all done.
        set info(callNotify) no

        # NEXT, clear the parmset and parse the file; 
        # ignore errors if requested.

        $self clear

        if {$mode eq "-forgiving"} {
            set info(ignoreSetErrors) yes
        }

        set code [catch {
            $interp invokehidden source $filename
        } result]

        # Make "set" work normally again.
        set info(callNotify)      yes
        set info(ignoreSetErrors) no

        # NEXT, destroy the interp.
        $interp destroy

        # NEXT, on failure restore the old values and throw 
        # PARMSET BADFILE.
        if {$code} {
            array unset values
            array set values $oldValues

            throw {PARMSET BADFILE} \
                "Error, $result, in \"[file normalize $filename]\""
        }

        # NEXT, We were successful; call notify
        callwith $options(-notifycmd) ""

        return
    }

    #-----------------------------------------------------------------------
    # Helper Procs: operations on parameter names

    # parent name
    #
    # name    A parameter name, tokens delimited by ".".
    #
    # Returns the parent name, e.g., given "a.b.c" returns "a.b".
    # If name is a root name, e.g., "a", return "".

    method parent {name} {
        return [join [lrange [split $name "."] 0 end-1] "."]
    }

    # tail name
    #
    # name    A parameter name, tokens delimited by "."
    #
    # Returns the tail of the name, e.g., given "a.b.c" returns
    # "c".  If name is a root name, e.g., "a", returns "a".

    method tail {name} {
        return [lindex [split $name "."] end]
    }
}
