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
    array set meta {distpat-osx {
    bin/quill-osx
    docs/*.html
    docs/*/*.html
    docs/*.md
    %libs
    LICENSE
    README.md
} version-zipfile::encode 0.3 gui-quill 0 apptypes-quill {linux osx windows} url http://my.home.page description {Quill Project Build System for Tcl/Tk} provides quill homepage http://github.com/wduquette/tcl-quill requires {Tcl snit textutil::expander zipfile::encode} distpat-windows {
    bin/quill-windows.exe
    docs/*.html
    docs/*/*.html
    docs/*.md
    %libs
    LICENSE
    README.md
} version-textutil::expander 1.3.1 version-snit 2.3 local-Tcl 0 apps quill local-zipfile::encode 0 distpat-linux {
    bin/quill-linux
    docs/*.html
    docs/*/*.html
    docs/*.md
    %libs
    LICENSE
    README.md
} local-textutil::expander 0 local-snit 0 version 0.2.1a0 version-Tcl 8.6 project tcl-quill dists {linux osx windows}}

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
