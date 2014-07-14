#-------------------------------------------------------------------------
# TITLE: 
#    gentree.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project build system for Tcl/TK
#
# DESCRIPTION:
#    Project tree generation tools
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Exported Commands

namespace eval ::quillapp {
    namespace export \
        gentree
}

#-------------------------------------------------------------------------
# Commands

# gentree tree mapping...
#
# tree    - A file tree dictionary: template names and file paths.
# mapping - A [string map] mapping, as one argument or several.
#
# The tree is a dictionary of basenames of files in the ./templates
# and paths relative to the project root, using "/" as the separator.

proc ::quillapp::gentree {tree args} {
    # FIRST, get the mapping.
    if {[llength $args] == 1} {
        set mapping [lindex $args 0]
    } else {
        set mapping $args
    }

    # NEXT, process the files
    foreach {template path} $tree {
        # FIRST get the paths
        set t [file join $::quillapp::library templates $template.template]
        set p [project root {*}[split $path /]]

        # NEXT, generate the files.
        genfile $t $p $mapping
    }
}