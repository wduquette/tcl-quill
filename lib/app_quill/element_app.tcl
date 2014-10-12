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

::app_quill::element public app {appname} 1 1 \
     ::app_quill::appElement

# appElement appname
#
# appname - The application name
# 
# Saves the app element files.

proc ::app_quill::appElement {appname} {
    gentree bin/$appname.tcl           [appLoader $appname]  \
            docs/man1/$appname.manpage [appManPage $appname]

    os setexecutable [project root bin $appname.tcl]

    element package app_$appname true
}

# appLoader appname
#
# $appname.tcl file for the $appname app..

maptemplate ::app_quill::appLoader {appname} {
    set project     [project name]
    set description [project description]
    set pkgname     app_$appname
    set tclversion  [project require version Tcl]
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

    # -quill-tcl-begin
    package require Tcl %tclversion
    # -quill-tcl-end

    # quillinfo(n) is a generated package containing this project's 
    # metadata.
    package require quillinfo

    # If it's a gui, load Tk.
    if {[quillinfo isgui %appname]} {
    # -quill-tk-begin
        package require Tk %tclversion
    # -quill-tk-end
    }

    # %pkgname(n) is the package containing the bulk of the 
    # %appname code.  In particular, this package defines the
    # "main" procedure.
    package require %pkgname
    namespace import %pkgname::*

    #-------------------------------------------------------------------------
    # Invoke the application

    if {!$tcl_interactive} {
        if {[catch {
            main $argv
        } result eopts]} {
            if {[dict get $eopts -errorcode] eq "FATAL"} {
                # The application has flagged a FATAL error; display it 
                # and halt.
                puts $result
                exit 1
            } else {
                puts "Unexpected error: $result"
                puts "Error Code: ([dict get $eopts -errorcode])\n"
                puts [dict get $eopts -errorinfo]
            }
        }
    }
}

# appManPage appname
#
# $appname.manpage file for the $appname app.

maptemplate ::app_quill::appManPage {appname} {
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
