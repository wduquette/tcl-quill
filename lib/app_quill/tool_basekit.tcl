#-------------------------------------------------------------------------
# TITLE: 
#    tool_basekit.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Basekit Manager
#
# DESCRIPTION:
#    "quill basekit" tool implementation.  This tool manages Quill's
#    access to cross-platform basekits.
#
#-------------------------------------------------------------------------

app_quill::tool define basekit {
    description "Basekit Manager"
    argspec     {0 - "?<subcommand>? ?<name>...?"}
    needstree   false
} {
    Quill builds standalone executables by appending the project's code
    to a "basekit", a single-file Tcl interpreter.  Basekits for the
    current platform usually come with the Tcl distribution; alternatively,
    they can be specified using 'quill config'.

    This command manages basekits for other platforms, which can be used
    to build your apps for those platforms from your current development
    environment.  See the help for 'quill build' for details on how to do
    so.  These basekits are referred to as "foreign basekits".

    quill basekit
        Lists all available basekits for other platforms and the 
        configured Tcl version (see 'quill env'), and indicates 
        whether they are on the local disk or at teapot.activestate.com.
        (This is equivalent to 'quill basekit list -source all'.)

    quill basekit list ?-source local|web|all?
        Lists the basekits available from the given source: the 
        local repository, from ActiveState's teapot, or both.

    quill basekit get <name> <version> <platform>
        Retrieves the stated basekit(s) from teapot.activestate.com and
        saves it locally.  The arguments can contain wildcards; all
        matching basekits are retrieved.  For example, to retrieve all
        Tcl/Tk 8.6.3 basekits, enter

            quill basekit get "*" "8.6.3.*" "*"

    quill basekit remove <name> <version> <platform>
        Removes the specific basekit(s) from the local cache. 
        The arguments can contain wildcards; all matching basekits 
        are retrieved.
} {
    # execute argv
    #
    # argv - command line arguments for this tool
    # 
    # Executes the tool given the arguments.

    typemethod execute {argv} {
        # FIRST, get arguments
        set sub [lshift argv]

        if {$sub eq ""} {
            set sub "list"
        }

        # NEXT, dispatch
        switch -exact -- $sub {
            list {
                checkargs "quill basekit" 0 - {?options...?} $argv
                ListBasekits $argv
            }
            get {
                checkargs "quill basekit get" 3 3 \
                    {name version platform} $argv
                lassign $argv name version platform
                GetBasekits $name $version $platform
            }
            remove {
                checkargs "quill basekit remove" 3 3 \
                    {name version platform} $argv
                lassign $argv name version platform
                RemoveBasekits $name $version $platform
            }
            default {
                throw FATAL "Unknown subcommand: \"$sub\""
            }
        }

        return
    }



    #---------------------------------------------------------------------
    # List Basekits

    # ListBasekits ?-local?
    #
    # Finds the basekits that are available locally or at 
    # teapot.activestate.com.

    proc ListBasekits {argv} {
        # FIRST, get a list of the available basekits.
        set source [from argv -source all]

        if {$source ne "local"} {
            puts "Finding basekits at teapot.activestate.com..."
            puts ""
        }

        try {
            set kits \
            [basekit table [env versionof tclsh] -source $source {*}$argv]
        } trap INVALID {result} {
            throw FATAL $result
        }
        
        # NEXT, sort them for display.
        set kits [dictable sort $kits {
            platform {version -decreasing} tcltk threaded name 
        }]

        # NEXT, display the list.
        puts "Platforms for which cross-platform builds can be done:"
        puts ""

        dictable puts $kits \
            -sep         "  "               \
            -showheaders                    \
            -skipsame    {platform version} \
            -columns     {
                platform version name tcltk source
            }
    }

    #---------------------------------------------------------------------
    # Get Basekit(s)

    # GetBasekits name version platform
    #
    # name     - The basekit's teapot package name, e.g., "base-tcl"
    # version  - The version number
    # platform - The platform
    #
    # Retrieves the specified basekit(s).  The arguments may contain
    # wildcards.

    proc GetBasekits {name version platform} {
        puts "Locating basekits:"
        puts "   Name:     $name"
        puts "   Version:  $version"
        puts "   Platform: $platform"
        puts ""
        set allkits [basekit table [env versionof tclsh] -source web]

        set kits [dictable filter $allkits \
            name $name version $version platform $platform]

        if {![got $kits]} {
            throw FATAL "Quill found no basekits that match the criteria."
        }

        foreach kdict $kits {
            dict with kdict {}
            try {
                teacup getkit $name $version $platform
            } on error {result} {
                throw FATAL "Could not retrieve basekit:\n=> $result"
            }
        }
    }

    #---------------------------------------------------------------------
    # Remove Basekit(s)

    # RemoveBasekits name version platform
    #
    # name     - The basekit's teapot package name, e.g., "base-tcl"
    # version  - The version number
    # platform - The platform
    #
    # Removes the matching basekit(s) from the local cache.  The arguments 
    # may contain
    # wildcards.

    proc RemoveBasekits {name version platform} {
        puts "Removing basekits:"
        puts "   Name:     $name"
        puts "   Version:  $version"
        puts "   Platform: $platform"
        puts ""
        set allkits [basekit table [env versionof tclsh] -source local]

        set kits [dictable filter $allkits \
            name $name version $version platform $platform]

        if {![got $kits]} {
            throw FATAL "Quill found no basekits that match the criteria."
        }

        foreach kdict $kits {
            set fullpath [basekit get $kdict]
            set appname [dict get $kdict appname]
            puts "Removing basekit: $appname"

            try {
                file delete $fullpath
            } on error {result} {
                throw FATAL "Could not remove basekit $appname\n=> $result"
            }
        }
    }

}