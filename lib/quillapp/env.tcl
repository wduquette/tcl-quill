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
    # Type Variables

    # pathto - Array of normalized paths to tool executables.
    typevariable pathto -array {
        tclsh       ""
        tkcon       ""
        teacup      ""
        tclapp      ""
        basekit.tcl ""
        basekit.tk  ""
        teapot-pkg  ""
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
            set pathto($helper) [$type GetPathTo $helper]
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

    # GetPathTo basekit.tcl
    #
    # Returns the path to the non-GUI basekit for this platform,
    # or "".

    typemethod {GetPathTo basekit.tcl} {} {
        $type GetBaseKit tcl
    }

    # GetPathTo basekit.tk
    #
    # Returns the path to the GUI basekit for this platform,
    # or "".

    typemethod {GetPathTo basekit.tk} {} {
        $type GetBaseKit tk
    }

    # GetBaseKit tcl|tk
    #
    # tcl|tk   - Flavor of basekit desired.
    #
    # Retrieves the path to the basekit, or "" if it can't find it.
    #
    # TODO: Consider getting the basekit from the teapot.

    typemethod GetBaseKit {flavor} {
        # FIRST, get the basekit prefix given the flavor
        set prefix "base-${flavor}[info tclversion]-thread*"

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

        return ""
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

        return [file normalize [exec $teacup default]]
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
        set query [project root .quill query.tcl]
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