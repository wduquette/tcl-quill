#-------------------------------------------------------------------------
# TITLE: 
#    depstool.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project deps System for Tcl/Tk
#
# DESCRIPTION:
#    "quill deps" tool implementation.  This tool manages Quill's
#    external dependencies, i.e., its required packages.
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Register the tool

set ::quillapp::tools(deps) {
    command     "deps"
    description "Manages external dependencies"
    argspec     {0 - "?<subcommand>? ?<name>...?"}
    intree      true
    ensemble    ::quillapp::depstool
}

set ::quillapp::help(deps) {
    Quill installs the project's 'require''d packages into a local
    teapot repository (see 'quill help teapot').  Once installed, they 
    are available for use during development, and are included in 
    "exe" and "uberkit" apps.

    Called with no arguments, "quill deps" lists the project's 
    required packages and indicates whether each is available in the
    local teapot.

    quill deps update ?<name>...?
        Attempts to install all missing dependencies.  Optionally, 
        one or more package names can be specified explicitly.

    quill deps refresh ?<name>...?
        Attempts to remove and re-install all dependencies.  Optionally,
        one or more package names can be specified explicitly.
}

#-------------------------------------------------------------------------
# Namespace Export

namespace eval ::quillapp:: {
    namespace export \
        depstool
} 

#-------------------------------------------------------------------------
# Tool Singleton: depstool

snit::type ::quillapp::depstool {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    # execute argv
    #
    # argv - command line arguments for this tool
    # 
    # Executes the tool given the arguments.

    typemethod execute {argv} {
        # FIRST, check to see whether the teapot is OK.
        if {![teapot ok]} {
            throw FATAL [outdent {
                Quill stores external packages in the local "teapot"
                repository.  The local teapot is in a bad state from
                Quill's point of view.  Run 'quill teapot' for details
                and instructions on how to resolve the problem.
            }]
        }

        if {[llength $argv] == 0} {
            DisplayDepsStatus
            return
        }

        set sub [lshift argv]

        switch -exact -- $sub {
            update {
                UpdateDeps $argv
            }
            refresh {
                RefreshDeps $argv
            }
            default {
                throw FATAL "Unknown subcommand: \"quill deps $sub\""
            }
        }
    }

    # DisplayDepsStatus
    #
    # Displays the current status.

    proc DisplayDepsStatus {} {
        puts "Dependency Status:"

        set count 0

        foreach pkg [project require names] {
            set ver [project require version $pkg]

            if {[teacup installed $pkg $ver]} {
                set status "(OK)"
            } else {
                incr count
                set status "(Not installed)"
            }

            DisplayPackage $pkg $ver $status
        }

        if {$count > 0} {
            puts ""
            puts "$count required package(s) must be installed."
            puts "Use 'quill deps update' to install them."
        }
    }


    # DisplayPackage pkg ver text
    #
    # pkg   - A package name
    # ver   - A version string
    # text  - A text string
    #
    # Displays the information in three left justified columns

    proc DisplayPackage {pkg ver text} {
        puts [format "  %-28s %s" "$pkg $ver" $text]
    }

    # UpdateDeps pkgnames
    #
    # Updates dependencies that are missing.

    proc UpdateDeps {pkgnames} {
        puts "Updating required dependencies..."
        set count 0

        if {[llength $pkgnames] == 0} {
            set pkgnames [project require names]
        }

        foreach pkg $pkgnames {
            if {$pkg ni [project require names -all]} {
                throw FATAL "The project doesn't require any package called \"$pkg\"."
            }

            if {$pkg in {Tcl Tk}} {
                puts "Warning: $pkg cannot be updated this way."
                continue
            }

            set ver [project require version $pkg]

            if {![teacup installed $pkg $ver]} {
                puts "Installing $pkg $ver"
                teacup install $pkg $ver
                incr count
            }
        }

        if {$count > 0} {
            puts ""
            puts "Updated $count package(s)."
        } else {
            puts "No packages were obviously out-of-date."
        }
    }

    # RefreshDeps pkgnames
    #
    # Refreshes dependencies.

    proc RefreshDeps {pkgnames} {
        puts "Refreshing required dependencies..."
        set count 0

        if {[llength $pkgnames] == 0} {
            set pkgnames [project require names]
        }

        foreach pkg $pkgnames {
            if {$pkg ni [project require names -all]} {
                throw FATAL "The project doesn't require any package called \"$pkg\"."
            }

            set ver [project require version $pkg]

            if {$pkg in {Tcl Tk}} {
                puts "Warning: $pkg cannot be updated this way."
                continue
            }



            if {[teacup installed $pkg $ver]} {
                puts "Removing $pkg $ver"
                teacup remove $pkg $ver
            }

            puts "Installing $pkg $ver"
            teacup install $pkg $ver
            incr count
        }

        puts ""
        puts "Refreshed $count package(s)."
    }

}

