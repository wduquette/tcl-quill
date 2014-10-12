#-------------------------------------------------------------------------
# TITLE: 
#    version.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project build system for Tcl/TK
#
# DESCRIPTION:
#    Version Number tools
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Exported Commands

namespace eval ::app_quill {
    namespace export \
        version
}

#-------------------------------------------------------------------------
# Singleton

snit::type ::app_quill::version {
    pragma -hasinstances no -hastypedestroy no

    # validate version
    #
    # version   - Possibly, a Tcl version string.

    typemethod validate {version} {
        set re {^(\d[.])*\d[.ab]\d$}
        if {[regexp $re $version dummy]} {
            return $version
        }

        throw INVALID "Invalid version string: \"$version\""
    }

    # rqmt validate rqmt
    #
    # rqmt   - A [package require] version requirement.
    #
    # Validates the requirement string.

    typemethod {rqmt validate} {rqmt} {
        # The requirement can have one of three forms, per
        # [package vsatisfies]:
        #
        #    ver
        #    ver-
        #    ver-ver

        set components [split $rqmt -]
        lassign $components min max

        # Case 1
        if {[llength $components] < 2} {
            return [version validate $min]
        } elseif {[llength $components] > 2} {
            throw INVALID "Invalid version requirement: \"$rqmt\""
        } elseif {$max eq ""} {
            return "[version validate $min]-"
        } else {
            return "[version validate $min]-[version validate $max]"
        }
    }
}