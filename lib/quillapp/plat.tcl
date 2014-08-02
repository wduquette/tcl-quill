#-------------------------------------------------------------------------
# TITLE: 
#    plat.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    plat(n): Platform abstraction layer for Quill
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Namespace exports

namespace eval ::quillapp:: {
    namespace export plat
}

#-------------------------------------------------------------------------
# plat singleton

snit::type ::quillapp::plat {
    pragma -hasinstances no -hastypedestroy no

    #---------------------------------------------------------------------
    # Type Variables

    # pathto - Array of normalized paths to tool executables.
    typevariable pathto -array {
        tclsh       ""
        tkcon       ""
        teacup      ""
        tclapp      ""
        tcl-basekit ""
        tk-basekit  ""
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

    # id
    #
    # Returns the platform ID.  Quill doesn't care (at present)
    # about the specifics, but about the broad categories:
    # Windows, Linux, OSX.

    typemethod id {} {
        if {$::tcl_platform(os) eq "Darwin"} {
            return osx
        } elseif {$::tcl_platform(os) eq "Windows"} {
            return windows
        } else {
            return linux
        }
    }

    # appfile app
    #
    # app  - The app name, e.g., "quill"
    #
    # Returns the full application file name, i.e., adds a ".exe"
    # on Windows.

    typemethod appfile {app} {
        if {[$type id] eq "windows"} {
            return $app.exe
        } else {
            return $app
        }
    }

    # pathto tool ?-force? ?-require?
    #
    # tool   - Name of a tool we need, e.g., teacup.
    #
    # Returns the normalized path to the tool's executable.  If the path
    # is unknown, or -force is given, finds the executable first, and
    # caches the result.  Returns "" if the tool cannot be found, or
    # if -require is given throws a fatal error.

    typemethod pathto {tool args} {
        set force   0
        set require 0

        while {[llength $args] > 0} {
            set opt [lshift args]
            switch -exact -- $opt {
                -force   { set force 1   }
                -require { set require 1 }
                default  { error "Unknown option: \"$opt\"" }
            }
        }

        if {$force} {
            set pathto($tool) ""
        }

        if {$pathto($tool) eq ""} {
            set pathto($tool) [$type GetPathTo $tool]
        }

        if {$require && $pathto($tool) eq ""} {
            throw FATAL "Cannot locate the \"$tool\" tool."
        }

        return $pathto($tool)
    }

    # GetPathTo tclsh
    #
    # Returns the path to the tclsh.

    typemethod {GetPathTo tclsh} {} {
        return [FindOnPath tclsh]
    }

    # GetPathTo tkcon
    #
    # Returns the path to the tkcon executable.

    typemethod {GetPathTo tkcon} {} {
        set shelldir [file dirname [$type pathto tclsh]]

        switch [$type id] {
            linux -
            osx   {
                set path [FindOnPath tkcon]
            }
            windows {
                set path [file join $shelldir tkcon.tcl]
            }
            default {
                error "unknown platform id: \"[$type id]\""
            }
        }

        return [file normalize $path]
    }

    # GetPathTo teacup
    #
    # Returns the path to the teacup executable.

    typemethod {GetPathTo teacup} {} {
        set shelldir [file dirname [$type pathto tclsh]]
        set path [file join $shelldir teacup]

        return [file normalize $path]
    }

    # GetPathTo tclapp
    #
    # Returns the path to the tclapp executable.

    typemethod {GetPathTo tclapp} {} {
        switch [$type id] {
            linux -
            osx   {
                set path [FindOnPath tclapp]
            }
            windows {
                set path [FindOnPath tclapp.exe]
            }
            default {
                error "unknown platform id: \"[$type id]\""
            }
        }

        return $path
    }

    # GetPathTo teapot-pkg
    #
    # Returns the path to the teapot-pkg executable.

    typemethod {GetPathTo teapot-pkg} {} {
        switch [$type id] {
            linux -
            osx   {
                set path [FindOnPath teapot-pkg]
            }
            windows {
                set path [FindOnPath teapot-pkg.exe]
            }
            default {
                error "unknown platform id: \"[$type id]\""
            }
        }

        return $path
    }

    # GetPathTo tcl-basekit
    #
    # Returns the path to the non-GUI basekit for this platform,
    # or "".

    typemethod {GetPathTo tcl-basekit} {} {
        $type GetBaseKit false
    }

    # GetPathTo tk-basekit
    #
    # Returns the path to the GUI basekit for this platform,
    # or "".

    typemethod {GetPathTo tk-basekit} {} {
        $type GetBaseKit true
    }

    # GetBaseKit tkflag
    #
    # tkflag  - True for Tk basekit, false for non-Tk basekit.
    #
    # Retrieves the path to the basekit, or "" if it can't find it.
    #
    # TODO: Consider getting the basekit from the teapot.

    typemethod GetBaseKit {tkflag} {
        # FIRST, get the basekit prefix given the tkflag
        if {$tkflag} {
            set prefix "base-tk[info tclversion]-thread*"
        } else {
            set prefix "base-tcl[info tclversion]-thread*"
        }

        # NEXT, get the likely location given the platform.
        switch [$type id] {
            osx {
                set basedir "/Library/Tcl/basekits"
                set pattern [file join $basedir $prefix]
            }
            windows {
                set basedir [file dirname [$type tclsh]]
                set pattern [file join $basedir $prefix].exe
            }
            linux   -
            default {
                set basedir [file dirname [$type tclsh]]
                set pattern [file join $basedir $prefix]
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

    # pathof dir ?-force?
    #
    # dir   - Symbolic name of a dir we need, e.g., teapot.
    #
    # Returns the normalized path to the resource directory.  If the path
    # is unknown, or -force is given, finds the directory first, and
    # caches the result.  Returns "" if the directory cannot be found.

    typemethod pathof {dir {flag ""}} {
        if {$flag eq "-force"} {
            set pathof($dir) ""
        }

        if {$pathof($dir) eq ""} {
            set pathof($dir) [$type GetPathOf $dir]
        }

        return $pathof($dir)
    }


    # GetPathOf teapot
    #
    # Returns the path of the local teapot repository.

    typemethod {GetPathOf teapot} {} {
        set teacup [$type pathto teacup]

        if {$teacup eq ""} {
            throw FATAL "Cannot locate \"teacup\" tool."
        }

        return [file normalize [exec $teacup default]]
    }

    #---------------------------------------------------------------------
    # Version Finding for Tools

    # versionof tool ?-force?
    #
    # tool   - Name of a tool we use.
    #
    # Retrieves the tool's version number, build number, or what have you.

    typemethod versionof {tool args} {
        if {$tool ni [array names versionof]} {
            return ""
        }

        set force   0

        while {[llength $args] > 0} {
            set opt [lshift args]
            switch -exact -- $opt {
                -force   { set force 1   }
                default  { error "Unknown option: \"$opt\"" }
            }
        }

        if {$force} {
            set versionof($tool) ""
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

    #---------------------------------------------------------------------
    # Path Finding Tools

    # FindOnPath program
    #
    # program  - The name of a program.
    #
    # Given the name of the program, tries to find it on the
    # PATH.  If it is found, returns the normalized path to the
    # program.

    proc FindOnPath {program} {
        global env

        # FIRST, do we have a PATH?
        if {![info exists env(PATH)]} {
            return ""
        }

        # NEXT, if we're on Windows, try ";" as a PATH separator.
        if {[plat id] eq "windows"} {
            set result [FindWith [split $env(PATH) ";"] $program]

            if {$result ne ""} {
                return $result
            }
        }

        # NEXT, we're on a Unix flavor, or on Windows using a Unix
        # shell, so the path separator is ":".
        return [FindWith [split $env(PATH) ":"] $program]
    }

    # FindWith dirlist program
    #
    # dirlist - A list of directories where executables might be found.
    # program - The executable name.
    #
    # Looks for the executable in the directories, and returns the 
    # normalized path to the first match.  If the program is not found,
    # returns ""

    proc FindWith {dirlist program} {
        foreach dir $dirlist {
            set files [glob -nocomplain [file join $dir $program]]

            if {[llength $files] == 1} {
                return [file normalize [lindex $files 0]]
            }
        }

        return ""
    }
}