#-------------------------------------------------------------------------
# TITLE: 
#    teapot.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    Module for managing the local teapot for all Quill projects.
#    Uses teacup.tcl to access teacup.exe.
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Namespace Export

namespace eval ::app_quill:: {
    namespace export \
        teapot
} 

#-------------------------------------------------------------------------
# Tool Singleton: teapot

snit::type ::app_quill::teapot {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #---------------------------------------------------------------------
    # Teapot Queries

    # quillpath
    #
    # Returns the path to Quill's own teapot.  This teapot might or might
    # not exist at present.

    typemethod quillpath {} {
        return [file normalize [env appdata teapot]]
    }

    # ok
    #
    # Returns 1 if the teapot configuration is OK, and 0 otherwise.
    # The configuration is OK if the default teapot is writable and the 
    # teapot and shell are linked to each other.

    typemethod ok {} {
        expr {
            [teapot writable]              && 
            [teapot islinked teapot2shell] &&
            [teapot islinked shell2teapot]
        }
    }

    # writable
    #
    # Returns 1 if the default teapot is writable, and 0 otherwise.

    typemethod writable {} {
        return [file writable [env pathof teapot]]
    }

    # islinked teapot2shell
    #
    # Returns 1 if the teapot knows that it is linked to the default
    # tclsh.

    typemethod {islinked teapot2shell} {} {
        set tclsh  [env pathto tclsh]
        set teapot [env pathof teapot]

        foreach line [split [teacup link info $teapot] \n] {
            if {[regexp {^Shell\s+(.+)$} $line dummy path] &&
                [os pathequal $path $tclsh]
            } {
                return 1
            }
        }

        return 0
    }

    # islinked shell2teapot
    #
    # Returns 1 if the shell knows that it is linked to the teapot.

    typemethod {islinked shell2teapot} {} {
        set tclsh  [env pathto tclsh]
        set teapot [env pathof teapot]

        foreach line [split [teacup link info $tclsh] \n] {
            if {[regexp {^Repository\s+(.+)$} $line dummy path] &&
                [os pathequal $path $teapot]
            } {
                return 1
            }
        }

        return 0
    }
}

