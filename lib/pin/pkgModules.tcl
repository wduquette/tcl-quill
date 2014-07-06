#-------------------------------------------------------------------------
# TITLE: 
#    pkgModules.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Tcl-Pinion: A Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    pin(n) Package Loader
#
#-----------------------------------------------------------------------

# TODO: Need to set this to project version.
package provide pin 1.0

#-----------------------------------------------------------------------
# Required Packages

# TODO: use [pinion require]
package require snit

#-----------------------------------------------------------------------
# Get the library directory

namespace eval ::pin:: {
	variable library [file dirname [info script]]
}

source [file join $::pin::library misc.tcl    ]
source [file join $::pin::library project.tcl ]
source [file join $::pin::library infotool.tcl]


