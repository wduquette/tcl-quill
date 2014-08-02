#-------------------------------------------------------------------------
# TITLE: 
#    quillinfo.tcl
#
# PROJECT:
#    tcl-quill: Quill Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    Project Metadata
#
#    Generated by Quill
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Exported Commands

namespace eval ::quillinfo {
    variable meta
    array set meta {gui-quill 0 url http://my.home.page description {Quill Project Build System for Tcl/Tk} provides quill homepage http://github.com/wduquette/tcl-quill apptype-quill exe requires {Tcl snit textutil::expander} version-textutil::expander 1.3.1 version-snit 2.3 local-Tcl 0 apps quill local-textutil::expander 0 local-snit 0 version 0.1.1a0 version-Tcl 8.6 project tcl-quill}

    namespace export \
        project      \
        description  \
        version      \
        homepage     \
        isgui

    namespace ensemble create
}

#-------------------------------------------------------------------------
# Commands

# project
#
# Returns the project name.

proc ::quillinfo::project {} {
    variable meta
    return $meta(project)
}

# description 
#
# Returns the project's description.

proc ::quillinfo::description {} {
    variable meta
    return $meta(description)
}

# version 
#
# Returns the project version number.

proc ::quillinfo::version {} {
    variable meta
    return $meta(version)
}

# homepage 
#
# Returns the project home page URL.

proc ::quillinfo::homepage {} {
    variable meta
    return $meta(homepage)
}

# isgui app
#
# app   - An app name for this project.
#
# Returns true if the app is a GUI and false otherwise.

proc ::quillinfo::isgui {app} {
    variable meta

    if {[info exists meta(gui-$app)]} {
        return $meta(gui-$app)
    } else {
        return 0
    }
}
