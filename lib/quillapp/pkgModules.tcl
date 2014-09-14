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

# -quill-provide-begin DO NOT EDIT BY HAND
package provide quillapp 0.2.1a0
# -quill-provide-end

#-----------------------------------------------------------------------
# Required Packages

# -quill-require-begin INSERT PACKAGE REQUIRES HERE
package require snit 2.3
package require zipfile::encode 0.3
package require quill 0.2.1a0
# -quill-require-end

namespace import quill::*

#-----------------------------------------------------------------------
# Get the library directory

namespace eval ::quillapp:: {
	variable library [file dirname [info script]]
}

# Application Infrastructure
source [file join $::quillapp::library misc.tcl             ]
source [file join $::quillapp::library env.tcl              ]
source [file join $::quillapp::library config.tcl           ]
source [file join $::quillapp::library teacup.tcl           ]
source [file join $::quillapp::library teapot.tcl           ]
source [file join $::quillapp::library version.tcl          ]
source [file join $::quillapp::library project.tcl          ]

# Project Trees and Elements
source [file join $::quillapp::library element.tcl          ]
source [file join $::quillapp::library element_app.tcl      ]
source [file join $::quillapp::library element_package.tcl  ]
source [file join $::quillapp::library element_quillinfo.tcl]
source [file join $::quillapp::library tree.tcl             ]
source [file join $::quillapp::library tree_app.tcl         ]

# Tools
source [file join $::quillapp::library envtool.tcl          ]
source [file join $::quillapp::library infotool.tcl         ]
source [file join $::quillapp::library installtool.tcl      ]
source [file join $::quillapp::library newtool.tcl          ]
source [file join $::quillapp::library replacetool.tcl      ]
source [file join $::quillapp::library runtool.tcl          ]
source [file join $::quillapp::library teapottool.tcl       ]

source [file join $::quillapp::library tool.tcl             ]
source [file join $::quillapp::library tool_build.tcl       ]
source [file join $::quillapp::library tool_config.tcl      ]
source [file join $::quillapp::library tool_deps.tcl        ]
source [file join $::quillapp::library tool_dist.tcl        ]
source [file join $::quillapp::library tool_docs.tcl        ]
source [file join $::quillapp::library tool_help.tcl        ]
source [file join $::quillapp::library tool_shell.tcl       ]
source [file join $::quillapp::library tool_test.tcl        ]
source [file join $::quillapp::library tool_version.tcl     ]

# Main
source [file join $::quillapp::library main.tcl             ]

