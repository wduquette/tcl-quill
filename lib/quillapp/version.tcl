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

namespace eval ::quillapp {
    namespace export \
        version
}

#-------------------------------------------------------------------------
# Singleton

snit::type version {
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
}