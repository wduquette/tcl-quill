#-------------------------------------------------------------------------
# TITLE: 
#    env.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    env(n): Development Environment layer for Quill.  
#
#    This module is responsible for figuring out where different
#    resources are in the user's development environment, possibly
#    with help from the configuration.
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Namespace exports

namespace eval ::quillapp:: {
    namespace export env
}

#-------------------------------------------------------------------------
# env singleton

snit::type ::quillapp::env {
    pragma -hasinstances no -hastypedestroy no

    #---------------------------------------------------------------------
    # Constants

    # teapot basekit patterns, by os flavor

    typevariable basekitPattern -array {
        linux   application-base-%t-thread-%v.*-linux-*-ix86
        osx     application-base-%t-thread-%v.*-macosx*
        windows application-base-%t-thread-%v.*-win32-ix86.exe
    }

    #---------------------------------------------------------------------
    # Type Variables

    # pathto - Array of normalized paths to tool executables.
    typevariable pathto -array {
        tclsh               ""
        tkcon               ""
        teacup              ""
        tclapp              ""
        teapot-pkg          ""
        basekit.tcl.linux   ""
        basekit.tcl.osx     ""
        basekit.tcl.windows ""
        basekit.tk.linux    ""
        basekit.tk.osx      ""
        basekit.tk.windows  ""
    }

    # pathof - Array of normalized paths to important directories
    typevariable pathof -array {
        teapot ""
    }

    # versionof - Array of helper tool version numbers.
    typevariable versionof -array {
        tclsh  ""
        teacup ""
    }


    #---------------------------------------------------------------------
    # Public Typemethods

    # reset
    #
    # Resets all cached info.  This is in case Quill takes some action
    # that will change it, but needs to keep running and use the new
    # environment.

    typemethod reset {} {
        foreach key [array names pathto]    { set pathto($key)    "" }
        foreach key [array names pathof]    { set pathof($key)    "" }
        foreach key [array names versionof] { set versionof($key) "" }
    }

    # appdata name...
    #
    # name... - path components
    #
    # Returns a path within the appdata directory.
    #
    # TODO: Probably there are better locations on OS X and Windows.

    typemethod appdata {args} {
        return [file normalize [file join ~ .quill {*}$args]]
    }

    # pathto helper ?-require?
    #
    # helper   - Name of a helper application, e.g., tclsh or teacup.
    #
    # Returns the normalized path to the helper's executable.  If the path
    # is unknown, finds the executable and caches the result.
    #
    # If the executable cannot be found, either returns "" or, if
    # -require is given, throws a fatal error.

    typemethod pathto {helper args} {
        set require 0

        foroption opt args -all {
            -require { set require 1 }
        }

        # Is there a configuration value?
        if {$pathto($helper) eq ""} {
            set pathto($helper) [config get helper.$helper]
        }

        # If not, try to find it in the environment
        if {$pathto($helper) eq ""} {
            if {[string match "basekit.*" $helper]} {
                lassign [split $helper .] dummy tcltk flavor
                set pathto($helper) [$type GetBaseKit $tcltk $flavor]
            } else {
                set pathto($helper) [$type GetPathTo $helper]
            }
        }

        if {$require && $pathto($helper) eq ""} {
            throw FATAL "Cannot locate the \"$helper\" program."
        }

        return $pathto($helper)
    }

    # GetPathTo tclsh
    #
    # Find tclsh on the path.

    typemethod {GetPathTo tclsh} {} {
        return [os pathfind [os exefile tclsh]]
    }

    # GetPathTo tkcon
    #
    # First, look for it in relation to tclsh.  If not there, find it
    # on the path.  

    typemethod {GetPathTo tkcon} {} {
        # FIRST, add ".tcl" on Windows
        if {[os flavor] eq "windows"} {
            set helper "tkcon.tcl"
        } else {
            set helper "tkcon"
        }

        # NEXT, find it near tclsh.
        set shelldir [file dirname [$type pathto tclsh]]
        set path [file join $shelldir $helper]

        if {[file isfile $path]} {
            return [file normalize $path]
        }

        # NEXT, try to find it on the path.
        return [os pathfind $helper]
    }

    # GetPathTo teacup
    #
    # First, look for it in relation to tclsh.  If not there, find it
    # on the path.

    typemethod {GetPathTo teacup} {} {
        set helper [os exefile teacup]

        # FIRST, find it near tclsh.
        set shelldir [file dirname [$type pathto tclsh]]
        set path [file join $shelldir $helper]

        if {[file isfile $path]} {
            return [file normalize $path]
        }

        # NEXT, try to find it on the path.
        return [os pathfind $helper]
    }

    # GetPathTo tclapp
    #
    # Returns the path to the tclapp executable.

    typemethod {GetPathTo tclapp} {} {
        return [os pathfind [os exefile tclapp]]
    }

    # GetPathTo teapot-pkg
    #
    # Returns the path to the teapot-pkg executable.

    typemethod {GetPathTo teapot-pkg} {} {
        return [os pathfind [os exefile teapot-pkg]]
    }

    # GetBaseKit tcl|tk flavor
    #
    # tcl|tk   - non-gui or gui basekit desired.
    # flavor   - linux|osx|windows, or "" for this platform.
    #
    # Retrieves the path to the basekit, or "" if it can't find it.
    #
    # The following search is used:
    #
    # * First, if the flavor is [os flavor], then we look for it
    #   with the locally installed basekits, and see if there's one
    #   that matches the version number of the tclsh in use.
    #
    # * Next, if it's not there or the flavor is some other platform,
    #   we look in ~/.quill/basekits/, to see if we've cached
    #   one for the same version.

    typemethod GetBaseKit {tcltk flavor} {
        # FIRST, get the flavor.
        if {$flavor eq ""} {
            set flavor [os flavor]
        }

        # NEXT, get the desired version.
        set tclver [shortver [env versionof tclsh]]

        if {$tclver eq ""} {
            return ""
        }

        # NEXT, if the flavor is the flavor of the current platform,
        # look where ActiveState installs basekits with the tclsh.
        if {$flavor eq [os flavor]} {
            # FIRST, get the basekit prefix given the flavor
            set prefix "base-${tcltk}$tclver-thread*"

            # NEXT, get the likely location given the platform.
            # On OSX, we know it's in /Library/Tcl/basekits.  Otherwise,
            # it's usually with the application
            switch [os flavor] {
                osx {
                    set basedir "/Library/Tcl/basekits"
                    set pattern [file join $basedir $prefix]
                }
                default {
                    set basedir [file dirname [$type pathto tclsh]]
                    set pattern [file join $basedir [os exefile $prefix]]
                }
            }

            # NEXT, there are usually library files alongside the
            # executables.  Get all of the files, and discard the
            # libraries.
            foreach fname [glob -nocomplain $pattern] {
                if {[file extension $fname] in {.dll .dylib .so}} {
                    continue
                }

                return [file normalize $fname]
            }
        }

        # NEXT, either it wasn't in the usual place, or we requested
        # the basekit for another platform.  Look in Quill's basekits
        # repository.

        set map [list %t $tcltk %v $tclver]
        set filepattern [string map $map $basekitPattern($flavor)]
        set fullpattern [env appdata basekits $filepattern]

        # Return the most recent that matches the x.y version.
        set choices [lsort -increasing [glob -nocomplain $fullpattern]]
        return [lindex $choices end]
    } 

    # shortver version
    #
    # Returns the x.y from a possibly longer version.

    proc shortver {version} {
        set vlist [split $version .]
        return [join [lrange $vlist 0 1] .]
    }

    #---------------------------------------------------------------------
    # Directory Paths

    # pathof dir
    #
    # dir   - Symbolic name of a dir we need, e.g., teapot.
    #
    # Returns the normalized path to the resource directory.  If the path
    # is unknown, finds the directory first and
    # caches the result.  Returns "" if the directory cannot be found.

    typemethod pathof {dir} {
        if {$pathof($dir) eq ""} {
            set pathof($dir) [$type GetPathOf $dir]
        }

        return $pathof($dir)
    }


    # GetPathOf teapot
    #
    # Returns the path of the local teapot repository.
    #
    # TODO: Probably we don't want to have to make ~/.quill/teapot
    # the default teapot; we just want it linked, and we want to
    # use it explicitly.

    typemethod {GetPathOf teapot} {} {
        set teacup [$type pathto teacup -require]

        try {
            return [file normalize [exec $teacup default]]

        } on error {} {
            return ""
        }
    }

    #---------------------------------------------------------------------
    # Version Finding for Tools

    # versionof tool
    #
    # tool   - Name of a tool we use.
    #
    # Retrieves the tool's version number, build number, or what have you.

    typemethod versionof {tool} {
        if {$tool ni [array names versionof]} {
            return ""
        }

        if {$versionof($tool) eq ""} {
            set versionof($tool) [$type GetVersionOf $tool]
        }

        return $versionof($tool)
    }

    # GetVersionOf tclsh
    #
    # Retrieves the tclsh version (e.g., info patchlevel).

    typemethod {GetVersionOf tclsh} {} {
        # FIRST, get the tclsh
        set tclsh [$type pathto tclsh]

        if {$tclsh eq ""} {
            return ""
        }

        # NEXT, create a script to query it.
        set query [env appdata temp query.tcl]
        
        writefile $query [outdent {
            puts [info patchlevel]
        }]

        # NEXT, query the shell.
        try {
            set result [string trim [exec $tclsh $query]]
        } on error {result} {
            set result ""
        }

        return $result
    }

    # GetVersionOf teacup
    #
    # Retrieves the teacup version.

    typemethod {GetVersionOf teacup} {} {
        # FIRST, get the teacup
        set teacup [$type pathto teacup]

        if {$teacup eq ""} {
            return ""
        }

        # NEXT, query the teacup.
        try {
            set result [string trim [exec $teacup version]]
        } on error {result} {
            set result ""
        }

        return $result
    }


}