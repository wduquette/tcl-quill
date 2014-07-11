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

source [file join $::quill::library misc.tcl     ]
source [file join $::quill::library templates.tcl]
source [file join $::quill::library project.tcl  ]
source [file join $::quill::library helptool.tcl ]
source [file join $::quill::library infotool.tcl ]
source [file join $::quill::library testtool.tcl ]


