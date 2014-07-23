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

# gentree path content...
#
# path    - A path relative to the project root, using "/" as the
#           separator.
# content - Content to write to the path.
#
# The input is a set of path and content pairs.

proc ::quillapp::gentree {args} {
    # NEXT, process the files
    foreach {path content} $args {
        # FIRST get the paths
        set p [project root {*}[split $path /]]

        # NEXT, generate the files.
        writefile $p $content
    }
}


