#-------------------------------------------------------------------------
# TITLE: 
#    element_app.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project build system for Tcl/TK
#
# DESCRIPTION:
#    Project Element: app element.
#    
#    This element defines the components of an application:
#
#    * Loader Script
#    * Implementation Package
#    * Implementation Package Test Suite
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Apploader Templates

::quillapp::element public app {appname} 1 1 \
     ::quillapp::appElement

# appElement appname
#
# appname - The application name
# 
# Saves the app element files.

proc ::quillapp::appElement {appname} {
    gentree bin/$appname.tcl           [appLoader $appname]  \
            docs/man1/$appname.manpage [appManPage $appname]

    file attributes [project root bin $appname.tcl] \
        -permissions u+x

    element package ${appname}app true
}

# appLoader appname
#
# $appname.tcl file for the $appname app..

maptemplate ::quillapp::appLoader {appname} {
    set project     [project name]
    set description [project description]
    set pkgname     ${appname}app
    set tclversion  [set ::tcl_version]
} {
    #!/bin/sh
    # -*-tcl-*-
    # the next line restarts using tclsh\\
    exec tclsh "$0" "$@"

    #-------------------------------------------------------------------------
    # NAME: %appname.tcl
    #
    # PROJECT:
    #  %project: %description
    #
    # DESCRIPTION:
    #  Loader script for the %appname(1) tool.
    #
    #-------------------------------------------------------------------------

    #-------------------------------------------------------------------------
    # Prepare to load application

    set bindir [file dirname [info script]]
    set libdir [file normalize [file join $bindir .. lib]]

    set auto_path [linsert $auto_path 0 $libdir]

    package require Tcl %tclversion

    # quillinfo(n) is a generated package containing this project's 
    # metadata.
    package require quillinfo

    # If it's a gui, load Tk.
    if {[quillinfo isgui %appname]} {
        package require Tk %tclversion
    }

    # %pkgname(n) is the package containing the bulk of the 
    # %appname code.  In particular, this package defines the
    # "main" procedure.
    package require %pkgname
    namespace import %pkgname::*

    #-------------------------------------------------------------------------
    # Invoke the application

    try {
        # Skip main if we're running interactively; this allows for 
        # interactive testing.
        if {!$tcl_interactive} {
            main $argv
        }
    } trap FATAL {result} {
        # The application has flagged a FATAL error; display it and halt.
        puts $result
        exit 1
    } on error {result eopt} {
        puts "Unexpected error: $result"
        puts "([dict get $eopt -errorcode])\n"
        puts [dict get $eopt -errorinfo]
    }
}

# appManPage appname
#
# $appname.manpage file for the $appname app.

maptemplate ::quillapp::appManPage {appname} {
    set project [project name]
} {
    <manpage %appname(1) "%project %appname Application">

    <section SYNOPSIS>

    <itemlist>

    <section DESCRIPTION>

    TODO: General description of the %appname(1) application

    <section USAGE>

    TODO: Usage information for the %appname(1) application.

    <section AUTHOR>

    TBD<p>

    <section "SEE ALSO">

    TBD<p>

    </manpage>
}
