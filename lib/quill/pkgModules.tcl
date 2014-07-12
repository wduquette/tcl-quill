#-------------------------------------------------------------------------
# TITLE: 
#    pkgModules.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Tcl-quill: A Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    quill(n) Package Loader
#
#-----------------------------------------------------------------------

# TODO: Need to set this to project version.
package provide quill 1.0

#-----------------------------------------------------------------------
# Required Packages

# TODO: use [quill require]
package require snit

#-----------------------------------------------------------------------
# Get the library directory

namespace eval ::quill:: {
	variable library [file dirname [info script]]
}

source [file join $::quill::library code.tcl       ]
source [file join $::quill::library control.tcl    ]
source [file join $::quill::library fileutils.tcl  ]
source [file join $::quill::library listutils.tcl  ]
source [file join $::quill::library stringutils.tcl]


