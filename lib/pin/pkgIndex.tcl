#-------------------------------------------------------------------------
# TITLE: 
#    pkgIndex.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Tcl-Pinion: A Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    pkgIndex file for pin(n).
#
#-------------------------------------------------------------------------

package ifneeded pin 1.0 [list source [file join $dir pkgModules.tcl]]

