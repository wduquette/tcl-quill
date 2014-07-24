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

    # pathto tclsh
    #
    # Returns the path to the tclsh.

    typemethod {pathto tclsh} {} {
        return [file normalize [info nameofexecutable]]
    }

    # pathto tkcon
    #
    # Returns the path to the tkcon executable.

    typemethod {pathto tkcon} {} {
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

    # pathto teacup
    #
    # Returns the path to the teacup executable.

    typemethod {pathto teacup} {} {
        set shelldir [file dirname [info nameofexecutable]]
        set path [file join $shelldir teacup]

        return [file normalize $path]
    }

    # pathto tclapp
    #
    # Returns the path to the tclapp executable.

    typemethod {pathto tclapp} {} {
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