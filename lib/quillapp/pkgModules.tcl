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
#    quillapp(n) Package Loader
#
#-----------------------------------------------------------------------

# TODO: Need to set this to project version.
package provide quillapp 1.0

#-----------------------------------------------------------------------
# Required Packages

# TODO: use [quill require]
package require snit
package require quill

#-----------------------------------------------------------------------
# Get the library directory

namespace eval ::quillapp:: {
	variable library [file dirname [info script]]
}

source [file join $::quillapp::library plat.tcl       ]
source [file join $::quillapp::library misc.tcl       ]
source [file join $::quillapp::library gentree.tcl    ]
source [file join $::quillapp::library project.tcl    ]
source [file join $::quillapp::library helptool.tcl   ]
source [file join $::quillapp::library infotool.tcl   ]
source [file join $::quillapp::library testtool.tcl   ]
source [file join $::quillapp::library versiontool.tcl]


