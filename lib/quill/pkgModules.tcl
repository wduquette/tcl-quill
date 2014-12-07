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

# -quill-provide-begin DO NOT EDIT BY HAND
package provide quill 0.4.1
# -quill-provide-end


#-----------------------------------------------------------------------
# Required Packages

# -quill-require-begin INSERT PACKAGE REQUIRES HERE
package require snit 2.3
package require textutil::expander 1.3.1
# -quill-require-end


#-----------------------------------------------------------------------
# Get the library directory

namespace eval ::quill:: {
	variable library [file dirname [info script]]
}

source [file join $::quill::library code.tcl         ]
source [file join $::quill::library control.tcl      ]
source [file join $::quill::library dictable.tcl     ]
source [file join $::quill::library fileutils.tcl    ]
source [file join $::quill::library listutils.tcl    ]
source [file join $::quill::library stringutils.tcl  ]
source [file join $::quill::library smartinterp.tcl  ]
source [file join $::quill::library macro.tcl        ]
source [file join $::quill::library macroset_html.tcl]
source [file join $::quill::library manpage.tcl      ]
source [file join $::quill::library template.tcl     ]
source [file join $::quill::library maptemplate.tcl  ]
source [file join $::quill::library parmset.tcl      ]
source [file join $::quill::library os.tcl           ]
source [file join $::quill::library quilldoc.tcl     ]



