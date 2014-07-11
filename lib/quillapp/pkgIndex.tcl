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
#    quillapp(n): pkgIndex file
#
#-------------------------------------------------------------------------

package ifneeded quillapp 1.0 [list source [file join $dir pkgModules.tcl]]

