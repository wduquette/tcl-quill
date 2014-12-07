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
#    app_quill(n) Package Loader
#
#-----------------------------------------------------------------------

# -quill-provide-begin DO NOT EDIT BY HAND
package provide app_quill 0.4.1
# -quill-provide-end

#-----------------------------------------------------------------------
# Required Packages

# -quill-require-begin INSERT PACKAGE REQUIRES HERE
package require snit 2.3

try {
package require zipfile::encode 0.3
    set ::got(zipfile::encode) 1
} on error {result} {
    set ::got(zipfile::encode) 0
}

package require quill 0.4.1

# -quill-require-end

namespace import quill::*

#-----------------------------------------------------------------------
# Get the library directory

namespace eval ::app_quill:: {
	variable library [file dirname [info script]]
}

# Application Infrastructure
source [file join $::app_quill::library misc.tcl               ]
source [file join $::app_quill::library env.tcl                ]
source [file join $::app_quill::library basekit.tcl            ]
source [file join $::app_quill::library config.tcl             ]
source [file join $::app_quill::library dist.tcl               ]
source [file join $::app_quill::library teacup.tcl             ]
source [file join $::app_quill::library teapot.tcl             ]
source [file join $::app_quill::library version.tcl            ]
source [file join $::app_quill::library project.tcl            ]
source [file join $::app_quill::library tester.tcl             ]

# New-style Elements
source [file join $::app_quill::library element.tcl            ]
source [file join $::app_quill::library qfiles.tcl             ]
source [file join $::app_quill::library filesets.tcl           ]
source [file join $::app_quill::library trees.tcl              ]

# Tools
source [file join $::app_quill::library tool.tcl               ]
source [file join $::app_quill::library tool_add.tcl           ]
source [file join $::app_quill::library tool_basekit.tcl       ]
source [file join $::app_quill::library tool_build.tcl         ]
source [file join $::app_quill::library tool_config.tcl        ]
source [file join $::app_quill::library tool_deps.tcl          ]
source [file join $::app_quill::library tool_dist.tcl          ]
source [file join $::app_quill::library tool_docs.tcl          ]
source [file join $::app_quill::library tool_env.tcl           ]
source [file join $::app_quill::library tool_help.tcl          ]
source [file join $::app_quill::library tool_info.tcl          ]
source [file join $::app_quill::library tool_install.tcl       ]
source [file join $::app_quill::library tool_new.tcl           ]
source [file join $::app_quill::library tool_replace.tcl       ]
source [file join $::app_quill::library tool_run.tcl           ]
source [file join $::app_quill::library tool_shell.tcl         ]
source [file join $::app_quill::library tool_teapot.tcl        ]
source [file join $::app_quill::library tool_test.tcl          ]
source [file join $::app_quill::library tool_version.tcl       ]

# Main
source [file join $::app_quill::library main.tcl               ]

