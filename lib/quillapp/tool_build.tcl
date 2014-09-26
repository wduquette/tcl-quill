#-------------------------------------------------------------------------
# TITLE: 
#    tool_build.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    "quill build" tool implementation.  This tool builds project build
#    targets.
#
#-------------------------------------------------------------------------

quillapp::tool define build {
    description "Build applications and libraries"
    argspec     {0 - "?app|lib? ?<name>..."}
    needstree   true
} {
    The "quill build" tool builds the project's applications and 
    provided libraries, as listed in the project.quill file.  By
    default, all applications and libraries are built.

    quill build app ?<name>...?
        Build all of the applications.  Optionally, build the named
        applications.

    quill build lib ?<name>...?
        Build all of the libraries.  Optionally, build the named libraries.
} {
    # execute argv
    #
    # argv - command line arguments for this tool
    # 
    # Executes the tool given the arguments.

    typemethod execute {argv} {
        # FIRST, get arguments
        set targetType [lshift argv]
        set names $argv

        if {$targetType ni {"" app lib}} {
            throw FATAL "Usage: [tool usage build]"
        }

        # NEXT, build provided libraries
        if {$targetType in {lib ""}} {
            if {[llength $names] == 0} {
                set names [project provide names]
            }
            foreach lib $names {
                BuildLibZip $lib
            }
        }

        # NEXT, build applications
        if {$targetType in {app ""}} {
            if {[llength $names] == 0} {
                set names [project app names]
            }

            foreach app $names {
                if {$app ni [project app names]} {
                    throw FATAL "No such application in project.quill: \"$app\""
                }

                if {[project app exetype $app] eq "exe"} {
                    set plat [platform::identify]
                } else {
                    set plat tcl
                }

                BuildTclApp $app $plat
            }
        }
    }

    #---------------------------------------------------------------------
    # Building Tcl Apps

    # BuildTclApp app plat
    #
    # app     - The name of the application
    # plat    - The desired platform.
    #
    # Builds the application using tclapp.

    proc BuildTclApp {app plat} {
        # FIRST, make sure the app is known.
        if {$app ni [project app names]} {
            throw FATAL "App \"$app\" is not defined in project.quill."
        }

        # NEXT, get relevant data
        set guiflag [project app gui $app]
        set outfile [project root bin [project app exename $app $plat]]

        # NEXT, tell the user what we are doing.
        if {$guiflag} {
            puts "Building GUI app $app as [file tail $outfile]"
        } else {
            puts "Building Console app $app as [file tail $outfile]"
        }

        # NEXT, build up the command
        set command [list]

        # tclapp, app loader script, lib directories
        lappend command \
            [env pathto tclapp] \
            [project root bin $app.tcl] \
            [project root lib * *]

        # Lib subdirectories?
        if {[llength [project glob lib * * *]] > 0} {
            lappend command \
                [project root lib * * *]
        }

        # Archive
        foreach repo [teacup repos] {
            lappend command -archive $repo
        }

        # Output file
        lappend command \
            -out $outfile

        # Prefix

        if {$plat ne "tcl"} {
            # FIXME: At this point, we can only do the current platform.
            if {$plat ne [platform::identify]} {
                throw FATAL "Cross-platform builds temporarily disabled"
            }

            set flavor [os flavor]

            if {$guiflag} {
                set basekit [env pathto basekit.tk.$flavor]
            } else {
                set basekit [env pathto basekit.tcl.$flavor]
            }

            if {$basekit eq ""} {
                throw FATAL [outdent "
                    Error building app $app: no basekit found.
                "]
            }

            lappend command \
                -prefix $basekit
        }

        # Required packages
        lappend command \
            -follow

        foreach pkg [project require names] {
            set ver [project require version $pkg]
            lappend command \
                -pkgref "$pkg $ver"
        }

        # Logging
        set log [project quilldir build_$app.log]
        lappend command \
            >& $log


        try {
            eval exec $command
        } on error {result eopt} {
            throw FATAL [outdent "
                Error building app $app: $result
                See $log for details.
            "]
        }
    }

    #---------------------------------------------------------------------
    # Building Tcl Lib teapot .zip files

    # BuildLibZip lib
    #
    # lib   - The name of the library
    #
    # Creates a teapot.txt file for the library, and then packages
    # it into <root>/.quill/teapot/* for later installation.

    proc BuildLibZip {lib} {
        # FIRST, make sure the lib is known.
        if {$lib ni [project provide names]} {
            throw FATAL "No such library is provided in project.quill: \"$lib\""
        }
        
        # NEXT, save the teapot.txt file.
        set teapotTxt [outdent "
            Package          $lib [project version]
            Meta entrykeep 
            Meta included    *
            Meta platform    tcl
        "]

        writefile [project root lib $lib teapot.txt] $teapotTxt

        # NEXT, make sure the output directory exists.
        set outdir [project root .quill teapot]
        file mkdir $outdir

        # NEXT, prepare the packaging command
        set command ""
        lappend command [env pathto teapot-pkg] generate \
            -t zip                                        \
            -o $outdir                                    \
            [project root lib $lib]

        # NEXT, call the command
        set outfile [file join $outdir package-$lib-[project version]-tcl.zip]
        puts "\nBuilding lib $lib:"
        puts [eval exec $command]
    }
}

