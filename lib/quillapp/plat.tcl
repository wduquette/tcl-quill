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
            linux {
                set path [exec which tkcon]
            }
            osx {
                set path [exec which tkcon]
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
}