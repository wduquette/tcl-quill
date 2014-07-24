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
        tclsh  ""
        tkcon  ""
        teacup ""
        tclapp ""
    }

    # pathof - Array of normalized paths to important directories
    typevariable pathof -array {
        teapot ""
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

    # pathto tool ?-force?
    #
    # tool   - Name of a tool we need, e.g., teacup.
    #
    # Returns the normalized path to the tool's executable.  If the path
    # is unknown, or -force is given, finds the executable first, and
    # caches the result.  Returns "" if the tool cannot be found.

    typemethod pathto {tool {flag ""}} {
        if {$flag eq "-force"} {
            set pathto($tool) ""
        }

        if {$pathto($tool) eq ""} {
            set pathto($tool) [$type GetPathTo $tool]
        }

        return $pathto($tool)
    }

    # GetPathTo tclsh
    #
    # Returns the path to the tclsh.

    typemethod {GetPathTo tclsh} {} {
        return [file normalize [info nameofexecutable]]
    }

    # GetPathTo tkcon
    #
    # Returns the path to the tkcon executable.

    typemethod {GetPathTo tkcon} {} {
        set shelldir [file dirname [info nameofexecutable]]

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
        set shelldir [file dirname [info nameofexecutable]]
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
        return [file normalize [exec $teacup default]]
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