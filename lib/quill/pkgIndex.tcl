#-------------------------------------------------------------------------
# TITLE: 
#    pkgIndex.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Tcl-quill: A Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    quill(n): pkgIndex file.
#
#-------------------------------------------------------------------------

package ifneeded quill 1.0 [list source [file join $dir pkgModules.tcl]]

