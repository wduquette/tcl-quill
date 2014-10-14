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

app_quill::tool define build {
    description "Build applications and libraries"
    argspec     {0 - "?app|lib? ?<name>..."}
    needstree   true
} {
    The "quill build" tool builds the project's applications and 
    provided libraries, as listed in the project.quill file.  By
    default, all applications and libraries are built.

    quill build
        Build all libraries and applications for the current platform.

    quill build app ?<name>...?
        Build all of the applications.  Optionally, build the named
        applications.

    quill build lib ?<name>...?
        Build all of the libraries.  Optionally, build the named libraries.

    quill build platforms
        Quill can build you applications for other platforms, provided 
        that none of your project's libraries contain compiled code built 
        for the current platform.  This command lists the platforms for
        which cross-platform builds can be done.

    quill build all
        Performs all build related tasks for the current platform, halting
        on error:

        * Verifies all external depencies.
        * Runs all tests
        * Formats all documentation
        * Builds all library .zip files
        * Builds all executables
        * Builds all distributions

        This is the command you use when you are ready to cut a release.
} {
    # execute argv
    #
    # argv - command line arguments for this tool
    # 
    # Executes the tool given the arguments.

    typemethod execute {argv} {
        # FIRST, get arguments
        set targetType [lshift argv]

        if {$targetType ni {"" app lib platforms all}} {
            throw FATAL "Usage: [tool usage build]"
        }

        if {$targetType eq ""} {
            set targetType libapp
        }

        # NEXT, dispatch
        switch -exact $targetType {
            lib {
                BuildLibs $argv
            }
            app {
                BuildApps $argv
            }
            libapp {
                BuildLibs
                BuildApps
            }
            platforms {
                ListBuildPlatforms
            }
            all {
                BuildAll
            }
        }
    }

    #---------------------------------------------------------------------
    # Building Library Teapot .zip files

    # BuildLibs ?names?
    #
    # Builds teapot .zip files for all libraries, or for the named
    # libraries.

    proc BuildLibs {{names ""}} {
        if {[llength $names] == 0} {
            set names [project provide names]
        } else {
            prepare names -listof [project provide names]
        }

        foreach lib $names {
            BuildLibZip $lib
        }
    }

    # BuildLibZip lib
    #
    # lib   - The name of the library
    #
    # Creates a teapot.txt file for the library, and then packages
    # it into <root>/.quill/teapot/* for later installation.
    #
    # TODO: Use zipfile::encode instead.

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

    #---------------------------------------------------------------------
    # Building Tcl Apps

    # BuildApps ?names?
    #
    # names  - Optional list of applications to build
    #
    # Builds executables for the named or all apps.

    proc BuildApps {{names ""}} {
        if {[llength $names] == 0} {
            set names [project app names]
        } else {
            prepare names -listof [project app names]
        }

        foreach app $names {
            if {[project app exetype $app] eq "exe"} {
                set plat [platform::identify]
            } else {
                set plat tcl
            }

            BuildTclApp $app $plat
        }
    }

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

        # NEXT, build up the command.  Paths can be relative to
        # the project root.
        cd [project root]

        set command [list]

        # tclapp, app loader script, lib directories
        lappend command \
            [env pathto tclapp] \
            [file join bin $app.tcl] \
            [file join lib * *]

        # Lib subdirectories?
        if {[llength [project glob lib * * *]] > 0} {
            lappend command \
                [file join lib * * *]
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
                set basekit [env pathto basekit.tk]
            } else {
                set basekit [env pathto basekit.tcl]
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
    # List Build Platforms

    # ListBuildPlatforms
    #
    # Finds the platforms for the current version of TCL for which 
    # basekits exist at teapot.activestate.com.

    proc ListBuildPlatforms {} {
        puts "Platforms for which cross-platform builds can be done:"
        puts ""
        
        set version [VerXY [env versionof tclsh]]
        set kits [dictable sort [teacup basekits $version] {
            platform {version -decreasing} tcltk threaded name 
        }]

        dictable puts $kits \
            -sep         "  "               \
            -showheaders                    \
            -skipsame    {platform version} \
            -columns     {
                platform version tcltk threaded name
            }
    }

    # VerXY version
    #
    # Returns the x.y from a possibly longer version.

    proc VerXY {version} {
        set vlist [split $version .]
        return [join [lrange $vlist 0 1] .]
    }

    #---------------------------------------------------------------------
    # Build All

    # BuildAll
    #
    # Builds the whole shebang for the current platform, halting on error.

    proc BuildAll {} {
        puts "quill build all"

        # FIRST, Verify all external depencies.
        Sep "Verifying external dependencies"

        if {![app_quill::tool::DEPS check]} {
            puts "External dependencies are not all up to date:\n"

            app_quill::tool::DEPS showstatus
            return
        } else {
            puts "All dependencies are up to date."
        }

        # NEXT, Run all tests
        Sep "Running all tests"

        set status [tester runall quiet]

        if {!$status} {
            puts ""
            throw FATAL "Build failed due to test failures."
        }

        # NEXT, Format all documentation
        # TODO: We should have a "docs" module.
        Sep "Formatting Documentation"
        app_quill::tool::DOCS execute {}

        # NEXT, Build all library .zip files
        # TODO: We should have a "builder" module.
        if {[got [project provide names]]} {
            Sep "Building Library .zip File(s)"
            app_quill::tool::BUILD execute lib
        }

        # NEXT, Build all executables
        # TODO: We should have a "builder" module.
        if {[got [project app names]]} {
            Sep "Building Application(s)"
            app_quill::tool::BUILD execute app
        }

        # NEXT, Build all distributions
        # TODO: We should have a "dister" module.
        if {[got [project dist names]]} {
            Sep "Building Distribution .zip File(s)"
            app_quill::tool::DIST execute {}
        }

        puts "\n***** Build Completed Successfully *****"
    }

    # proc Sep message
    #
    # message   - A section message
    #
    # Outputs a visual separator

    proc Sep {message} {
        puts "\n$message"
        puts [string repeat - 75]
    }
}

