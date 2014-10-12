#-------------------------------------------------------------------------
# TITLE: 
#    tool_config.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    "quill config" tool implementation.  This tool gives the user
#    access to the Quill configuration parameters.
#
#-------------------------------------------------------------------------

app_quill::tool define config {
    description "Quill configuration tool."
    argspec     {1 - "<subcommand> ?<arg>...?"}
    needstree   true
} {
    The "quill config" tool sets and queries Quill's configuration
    parameters.  See the config(5) man page for a description of 
    each of the parameters.

    The "quill config" tool has several subcommands:

    quill config list ?<pattern>?
        List configuration parameters and their values.  If pattern is
        given, it's a [string match] pattern; the list will include only
        parameters whose names match the pattern.

    quill config get <name>
        Prints the value of the named parameter.

    quill config set <name> <value>
        Sets the value of the named parameter.

    quill config reset
        Resets all configuration parameters to their default values.
} {
    # execute argv
    #
    # argv - command line arguments for this tool
    # 
    # Executes the tool given the arguments.

    typemethod execute {argv} {
        set sub [lshift argv]

        switch -exact -- $sub {
            list  { ConfigList $argv  }
            get   { ConfigGet $argv   }
            set   { ConfigSet $argv   }
            reset { ConfigReset $argv }
            default {
                throw FATAL [outdent "
                    Unknown 'quill config' subcommand: \"$sub\"
                "]
            }
        }
    }

    # ConfigList argv
    #
    # argv   - Command line arguments
    #
    # Lists configuration parameters.

    proc ConfigList {argv} {
        checkargs "quill config list" 0 1 {?pattern?} $argv

        set names [config names {*}$argv]

        set wid [lmaxlen $names]

        foreach name $names {
            set cv [config get $name]
            set dv [config getdefault $name]

            if {$cv eq $dv} {
                set dflag " "
            } else {
                set dflag "*"
            }

            if {$cv eq ""} {
                set cv "\"\""
            }

            puts [format "%s %-*s %s" $dflag $wid $name $cv]
        }
    }

    # ConfigGet argv
    #
    # argv   - Command line arguments
    #
    # Retrieve one parameter value.

    proc ConfigGet {argv} {
        checkargs "quill config get" 1 1 {name} $argv

        set name [lindex $argv 0]

        if {$name ni [config names]} {
            throw FATAL "Unknown configuration parameter: \"$name\""
        }

        puts [config get $name]
    }

    # ConfigSet argv
    #
    # argv   - Command line arguments
    #
    # Sets a parameter value.

    proc ConfigSet {argv} {
        checkargs "quill config set" 2 2 {name value} $argv
        lassign $argv name value

        try {
            config set $name $value
            config save
        } trap INVALID {result} {
            throw FATAL $result
        }
    }

    # ConfigReset argv
    #
    # argv   - Command line arguments
    #
    # Resets one or all parameter values.

    proc ConfigReset {argv} {
        checkargs "quill config reset" 0 1 {?pattern?} $argv
        lassign $argv pattern

        if {$pattern eq ""} {
            config clear
            puts "Reset all configuration parameters to their defaults."
        } else {
            set names [config names $pattern]
            foreach name $names {
                config set $name [config getdefault $name]
            }
            puts "Reset [llength $names] parameter(s) to their defaults."
        }

        config save
    }
}

