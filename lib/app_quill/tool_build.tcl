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
    argspec     {0 - "?subcommand? ?<args>...?"}
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

    quill build for <platform> ?-version <version>? ?-threads yes|no?
        Builds the project's standalone executables for the named platform,
        downloading the required basekit(s) if necessary.  By default,
        Quill will choose the newest threaded basekits for the platform.  
        Use the options to select particular basekits.

        To see the available basekits, use

           quill basekit list -source local

        Use 'quill basekit get' to acquire additional basekits from 
        teapot.activestate.com.

        This command assumes that 'quill build all' has been performed
        successfully; thus, it performs only these tasks:

        * Builds the project's standalone executables for the given platform.
        * Builds any "%platform"-based distribution sets for the given platform.

        NOTE: An application can only be built "cross-platform" when the
        application's code is pure-Tcl.  Quill can pull binary external
        dependencies from teapot.activestate.com, but cannot cross-compile
        locally-built binary extensions.
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
            set sub libapp
        }

        # NEXT, dispatch
        switch -exact $sub {
            lib {
                BuildLibs $argv
            }
            app {
                BuildApps $argv
            }
            libapp {
                checkargs "quill build libapp" 0 0 {} $argv
                BuildLibs
                BuildApps
            }
            all {
                checkargs "quill build all" 0 0 {} $argv
                BuildAll 
            }
            for {
                checkargs "quill build for" 1 - {platform ?options...?} $argv
                set platform [lshift argv]

                set version ""
                set threads yes

                foroption opt argv -all {
                    -version { 
                        set version [lshift argv] 
                    }
                    -threads { 
                        set threads [lshift argv] 
                        if {$threads ni "yes no 1 0 true false"} {
                            throw FATAL "Invalid -threads value: \"$threads\""
                        }
                    } 
                }

                BuildFor $platform $version $threads
            }
            default {
                throw FATAL "Unknown subcommand: \"$sub\""
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

    # BuildTclApp app ?basekit?
    #
    # app     - The name of the application
    # basekit   - Full path to basekit or ""
    #
    # Builds the application using tclapp.  The basekit will only be
    # given when 'quill build for' is called; it is the caller's 
    # responsibility to be sure that it is appropriate for the 
    # app.

    proc BuildTclApp {app {basekit ""}} {
        # FIRST, make sure the app is known.
        if {$app ni [project app names]} {
            throw FATAL "App \"$app\" is not defined in project.quill."
        }

        if {[project app exetype $app] eq "exe"} {
            if {[dict size $basekit] eq 0} {
                set plat [platform::identify]
            } else {
                set plat [dict get $basekit platform]
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
                set basekit [basekit get $basekit]
            }

            if {$basekit eq ""} {
                throw FATAL [outdent "
                    Error building app $app: no basekit found.
                "]
            }

            puts "Basekit: $basekit"

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
    # Build All

    # BuildAll
    #
    # Builds the entire project.

    proc BuildAll {} {
        puts "quill build all"

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

    #---------------------------------------------------------------------
    # Build For Platform

    # BuildFor platform version threads
    #
    # platform - The platform to build for.
    # version  - The specific version, or "" for latest.
    # threads  - yes, no, or "" to prefer threads but accept no threads.
    #
    # Builds the executables and distribution for the given platform.
    # By default, Quill will prefer the latest threaded version.
    
    proc BuildFor {platform version threads} {
        # FIRST, get the tcl and tk basekits for the given requirements.
        array set kits [GetPlatformBasekits $platform $version $threads]

        # NEXT, verify that we have a basekit for each app that needs one.
        set count 0

        foreach app [project app names] {
            if {[project app exetype $app] ne "exe"} {
                continue
            }

            incr count

            if {[project app gui $app]} {
                if {$kits(tk) eq ""} {
                    throw FATAL [outdent "
                        This project requires a Tk basekit, but no Tk
                        basekit that meets your constraints was found on
                        the local disk.  Use 'quill basekit list' to see
                        the basekits available from the 'net, and 
                        'quill basekit get' to retrieve the one you need.  
                    "]
                }
            } else {
                if {$kits(tcl) eq ""} {
                    throw FATAL [outdent "
                        This project requires a Tcl-only basekit, but no 
                        Tcl-only basekit that meets your constraints was found 
                        on the local disk.  Use 'quill basekit list' to see
                        the basekits available from the 'net, and 
                        'quill basekit get' to retrieve the one you need.  
                    "]
                }
            }
        }

        # NEXT, are there any apps to build?
        if {!$count} {
            throw FATAL [outdent "
                This project does not define any applications that are
                build as standalone executables, so there is nothing to
                do.
            "]
        }


        puts ""
        puts [outdent "
            Quill will now attempt to build this project's executables for 
            platform '$platform'.  Quill assumes that 'quill build all'
            has already succeeded for the current platform--all tests
            pass, all documentation has been formatted, and any library
            .zip files have been built.
        "]

        puts ""

        # NEXT, Build all executables
        Sep "Building Application(s)"

        foreach app [project app names] {
            if {[project app exetype $app] ne "exe"} {
                continue
            }

            if {[project app gui $app]} {
                set kdict $kits(tk)
            } else {
                set kdict $kits(tcl)
            }

            BuildTclApp $app $kdict
        }

        # NEXT, Build all distributions that are platform-specific.
        if {[got [project dist names]]} {
            Sep "Building Distribution .zip File(s)"

            foreach dist [project dist names] {
                if {![string match "*%platform*" $dist]} {
                    continue
                }

                dist make $dist $platform
            }
        }

        puts "\n***** Build Completed Successfully *****"
    }

    # GetPlatformBasekits platform argv
    #
    # platform  - The specific platform string
    # version   - The specific version, or "" for latest.
    # threads   - yes, no, or "" to prefer threads but accept no threads.
    #
    # Returns a dictionary of basekit kdicts for "tcl" and "tk".

    proc GetPlatformBasekits {platform version threads} {
        # FIRST, get the available basekits.
        dict set filter platform $platform

        if {$version ne ""} {
            dict set filter version $version
        }

        if {$threads ne ""} {
            if {$threads} {
                dict set filter threaded yes
            } else {
                dict set filter threaded no
            }
        }


        set kits [dictable filter \
            [basekit table [env versionof tclsh] -source local] \
            {*}$filter]

        if {![got $kits]} {
            return [dict create tcl "" tk ""]
        }

        # NEXT, we want the basekit with the highest version number.
        # Find them for both flavors, tcl and tk.

        set ver(tcl) 0.0
        set kit(tcl) ""
        set ver(tk)  0.0
        set kit(tk)  ""

        foreach kdict $kits {
            set flavor [dict get $kdict tcltk]
            set kver   [dict get $kdict version]

            if {[package vcompare $kver $ver($flavor)] == 1} {
                set ver($flavor) $kver
                set kit($flavor) $kdict
            }
        }

        return [array get kit]
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

