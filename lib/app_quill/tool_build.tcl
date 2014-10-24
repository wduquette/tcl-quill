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
    argspec     {0 - "?app|lib|platforms|all? ?<args>...?"}
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

    quill build all ?-platform <platform>?
        Performs all build related tasks for the current platform, halting
        on error:

        * Verifies all external depencies.
        * Runs all tests
        * Formats all documentation
        * Builds all library .zip files
        * Builds all executables
        * Builds all distributions

        This is the command you use when you are ready to cut a release.

        If -platform is given, the project is built for the given platform.
        NOTE: This can only be done successfully if the project's own 
        code base and any -local required packages are pure-Tcl.  Quill can
        pull the required basekits and binary external dependencies from
        teapot.activestate.com, but cannot cross-compile local binary 
        extensions.
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
                BuildAll $argv
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
            BuildTclApp $app
        }
    }

    # BuildTclApp app ?bdict?
    #
    # app     - The name of the application
    # bdict   - basekit definition dictionary, or ""
    #
    # Builds the application using tclapp.  The bdict will only be
    # non-empty for 'quill build all -platform <platform>'

    proc BuildTclApp {app {bdict ""}} {
        # FIRST, make sure the app is known.
        if {$app ni [project app names]} {
            throw FATAL "App \"$app\" is not defined in project.quill."
        }

        if {[project app exetype $app] eq "exe"} {
            if {[dict size $bdict] eq 0} {
                set plat [platform::identify]
            } else {
                set plat [dict get $bdict platform]
            }
        } else {
            set plat tcl
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

        if {[project app exetype $app] eq "exe"} {
            if {$plat eq [platform::identify]} {
                if {$guiflag} {
                    set basekit [env pathto basekit.tk]
                } else {
                    set basekit [env pathto basekit.tcl]
                }
            } else {
                set basekit [teacup getkit $bdict]
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

    # BuildAll argv
    #
    # argv - The command line options.
    #
    # Builds the entire project, as directed by the arguments.

    proc BuildAll {argv} {
        puts "quill build all"

        # FIRST, get the command-line arguments.
        set platform ""
        foroption opt argv -all {
            -platform { set platform [lshift argv] }
        }

        # NEXT, if -platform is this platform, we're fine.
        if {$platform eq [platform::identify]} {
            set platform ""
        }

        if {$platform eq ""} {
            BuildAllForHere
        } else {
            BuildAllForPlatform $platform
        }
    }


    # BuildAllForHere
    #
    # Builds the whole shebang for the current platform, halting on error.

    proc BuildAllForHere {} {
        # FIRST, Verify all external dependencies
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

    # BuildAllForPlatform platform
    #
    # platform - The platform to build for.
    #
    # Builds the executables and distribution for the given platform.

    proc BuildAllForPlatform {platform} {
        puts ""
        puts [outdent "
            NOTE: Quill will attempt to build this project's executables for 
            platform '$platform'.  Quill assumes that 'quill build all'
            has already succeeded for the current platform--all tests
            pass, all documentation has been formatted, and any library
            .zip files have been built.
        "]

        puts ""

        # FIRST, make sure we support this platform.
        set version [VerXY [env versionof tclsh]]
        set table [teacup basekits $version $platform]

        if {![got $table]} {
            puts ""
            throw FATAL "Basekits are not available for platform '$platform'."
        }

        # NEXT, gather app info.
        set exeCount 0
        set tclCount 0
        set tkCount  0

        foreach app [project app names] {
            if {[project app exetype $app] ne "exe"} {
                continue
            }

            incr exeCount

            if {[project app gui $app]} {
                incr tkCount 
            } else {
                incr tclCount
            }
        }

        # NEXT, are there any apps to build?
        if {!$exeCount} {
            throw FATAL [outdent "
                This project does not define any applications that are
                build as standalone executables, so there is nothing to
                do.
            "]
        }

        # NEXT, do we have the flavors we need?
        if {$tclCount > 0} {
            set bdict [GetBasekitFlavor $table tcl] 

            if {$bdict eq ""} {
                throw FATAL [outdent "
                    This project requires a Tcl-only basekit, but none
                    is available for '$platform'
                "]
            }
        }

        if {$tkCount > 0} {
            set bdict [GetBasekitFlavor $table tk]
            if {$bdict eq ""} {
                throw FATAL [outdent "
                    This project requires a Tk basekit, but none
                    is available for '$platform'
                "]
            }
        }

        # NEXT, Build all executables
        # TODO: We should have a "builder" module.
        Sep "Building Application(s)"

        foreach app [project app names] {
            if {[project app exetype $app] ne "exe"} {
                continue
            }

            if {[project app gui $app]} {
                set bdict [GetBasekitFlavor $table tk]
            } else {
                set bdict [GetBasekitFlavor $table tcl]
            }

            BuildTclApp $app $bdict
        }

        # NEXT, Build all distributions that are platform-specific.
        if {[got [project dist names]]} {
            Sep "Building Distribution .zip File(s)"

            foreach dist [project dist names] {
                if {![string match "*%platform*" $dist]} {
                    continue
                }

                puts "Pretending to build dist $dist for $platform"
            }
        }

        puts "\n***** Build Completed Successfully *****"
    }


    # GetBasekitFlavor table flavor
    #
    # Returns the best basekit dict for the given flavor.

    proc GetBasekitFlavor {table flavor} {
        set candidates [list]

        set v(thread)   0.0.0
        set v(unthread) 0.0.0
        set d(thread)   {}
        set d(unthread) {}

        foreach bdict $table {
            dict with bdict {}

            if {$tcltk ne $flavor} {
                continue
            }

            if {$threaded} {
                if {[package vcompare $version $v(thread)] == 1} {
                    set v(thread) $version
                    set d(thread) $bdict
                }
            } else {
                if {[package vcompare $version $v(unthread)] == 1} {
                    set v(unthread) $version
                    set d(unthread) $bdict
                }
            }
        }

        if {$d(thread) ne ""} {
            return $d(thread)
        } else {
            return $d(unthread)
        }
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

