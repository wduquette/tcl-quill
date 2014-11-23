#-------------------------------------------------------------------------
# TITLE: 
#    qfiles.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project build system for Tcl/TK
#
# DESCRIPTION:
#    Quill File Templates
#
#    A file template is a maptemplate that returns a file's contents
#    given parameters.  This module defines the file templates used by 
#    Quill's built in file set templates.
#
#-------------------------------------------------------------------------

namespace eval ::qfile {}

# pkgIndex.tcl package
#
# package - A package name
#
# pkgIndex.tcl file for the $package package.

maptemplate ::qfile::pkgIndex.tcl {package} {
    set project     [project name]
    set description [project description]
    set version     [project version]
} {
    #-------------------------------------------------------------------------
    # TITLE: 
    #    pkgIndex.tcl
    #
    # PROJECT:
    #    %project: %description
    #
    # DESCRIPTION:
    #    %package(n): pkgIndex file
    #
    #    Generated by Quill
    #
    #-------------------------------------------------------------------------

    # -quill-ifneeded-begin DO NOT EDIT BY HAND
    package ifneeded %package %version [list source [file join $dir pkgModules.tcl]]
    # -quill-ifneeded-end
}

# pkgModules.tcl package ?module?
#
# package   - A package name
# module    - A module name, defaulting to $package
#
# pkgModules.tcl file for the $package(n) package.

maptemplate ::qfile::pkgModules.tcl {package {module ""}} {
    set project     [project name]
    set description [project description]
    set version     [project version]

    if {$module eq ""} {
        set module $package
    }
} {
    #-------------------------------------------------------------------------
    # TITLE: 
    #    pkgModules.tcl
    #
    # PROJECT:
    #    %project: %description
    #
    # DESCRIPTION:
    #    %package(n): Package Loader
    #
    #    Generated by Quill
    #
    #-------------------------------------------------------------------------

    #-------------------------------------------------------------------------
    # Provide Package

    # -quill-provide-begin DO NOT EDIT BY HAND
    package provide %package %version
    # -quill-provide-end

    #-------------------------------------------------------------------------
    # Require Packages

    # -quill-require-begin INSERT PACKAGE REQUIRES HERE
    # -quill-require-end

    #-------------------------------------------------------------------------
    # Get the library directory

    namespace eval ::%package:: {
        variable library [file dirname [info script]]
    }

    source [file join $::%package::library %module.tcl]
}

# module.tcl package ?module?
#
# package  - The package name
# module   - The module name; defaults to $package.
#
# A Tcl module in a particular package.

maptemplate ::qfile::module.tcl {package {module ""}} {
    set project     [project name]
    set description [project description]

    if {$module eq ""} {
        set module $package
    }
} {
    #-------------------------------------------------------------------------
    # TITLE: 
    #    %module.tcl
    #
    # PROJECT:
    #    %project: %description
    #
    # DESCRIPTION:
    #    %package(n): Implementation File
    #
    #-------------------------------------------------------------------------

    #-------------------------------------------------------------------------
    # Exported Commands

    namespace eval ::%package {
        namespace export \\
            hello
    }

    #-------------------------------------------------------------------------
    # Commands

    # hello args
    #
    # Dummy procedure

    proc ::%package::hello {arglist} {
        puts "Hello, world!"
        puts "Args: <$arglist>"
    }
}

# main.tcl package
#
# package - Name of an application implementation package.
#
# main.tcl file for application implementation package $package(n).

maptemplate ::qfile::main.tcl {package} {
    set project     [project name]
    set description [project description]
} {
    #-------------------------------------------------------------------------
    # TITLE: 
    #    main.tcl
    #
    # PROJECT:
    #    %project: %description
    #
    # DESCRIPTION:
    #    %package(n): main procedure
    #
    #-------------------------------------------------------------------------

    #-------------------------------------------------------------------------
    # Exported Commands

    namespace eval ::%package {
        namespace export \\
            main
    }

    #-------------------------------------------------------------------------
    # Commands

    # main argv
    #
    # Dummy procedure

    proc ::%package::main {argv} {
        puts "[quillinfo project] [quillinfo version]"
        puts ""
        puts "Args: <$argv>"
    }
}

# all_tests.test target
#
# target  - The name of a test/<target>/ directory.
#
# all_tests.test file for test target $target.

maptemplate ::qfile::all_tests.test {target} {
    set project     [project name]
    set description [project description]
} {
    #-------------------------------------------------------------------------
    # TITLE:
    #    all_tests.test
    #
    # PROJECT:
    #    %project: %description
    #
    # DESCRIPTION:
    #    %target: Test Suite
    #-------------------------------------------------------------------------

    #-------------------------------------------------------------------------
    # Load the tcltest package

    if {[lsearch [namespace children] ::tcltest] == -1} {
        package require tcltest 2.3
        eval ::tcltest::configure $argv
    }

    ::tcltest::configure \
        -testdir [file dirname [file normalize [info script]]] \
        -notfile all_tests.test

    ::tcltest::runAllTests
}


# testfile.test package
#
# package  - A package name
#
# $module.test file for the $package package.

maptemplate ::qfile::testfile.test {package} {
    set project     [project name]
    set description [project description]
} {
    #-------------------------------------------------------------------------
    # TITLE:
    #    %package.test
    #
    # PROJECT:
    #    %project: %description
    #
    # DESCRIPTION:
    #    %package: Test Suite
    #-------------------------------------------------------------------------

    #-------------------------------------------------------------------------
    # Load the tcltest package

    if {[lsearch [namespace children] ::tcltest] == -1} {
        package require tcltest 2.3
        eval ::tcltest::configure $argv
    }

    namespace import ::tcltest::test

    #-------------------------------------------------------------------------
    # Load the package to be tested

    source ../../lib/%package/pkgModules.tcl
    namespace import ::%package::*

    #-------------------------------------------------------------------------
    # Setup

    # TBD

    #-------------------------------------------------------------------------
    # dummy

    test dummy-1.1 {dummy test} -body {
        set a false
    } -result {true}

    #-------------------------------------------------------------------------
    # Cleanup

    ::tcltest::cleanupTests
}

# app.tcl app
#
# $app.tcl file for application $app.

maptemplate ::qfile::app.tcl {app} {
    set project     [project name]
    set description [project description]
    set pkgname     app_$app
    set tclversion  [project require version Tcl]
} {
    #!/bin/sh
    # -*-tcl-*-
    # the next line restarts using tclsh\\
    exec tclsh "$0" "$@"

    #-------------------------------------------------------------------------
    # NAME: %app.tcl
    #
    # PROJECT:
    #  %project: %description
    #
    # DESCRIPTION:
    #  Loader script for the %app(1) application.
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
    if {[quillinfo isgui %app]} {
    # -quill-tk-begin
        package require Tk %tclversion
    # -quill-tk-end
    }

    # %pkgname(n) is the package containing the bulk of the 
    # %app code.  In particular, this package defines the
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

# man1.manpage app
#
# app  - An application name.
#
# $app.manpage file for the $app app.

maptemplate ::qfile::man1.manpage {app} {
    set project [project name]
} {
    <manpage %app(1) "%project %app Application">

    <section SYNOPSIS>

    <itemlist>

    <section DESCRIPTION>

    TODO: General description of the %app(1) application

    <section USAGE>

    TODO: Usage information for the %app(1) application.

    <section AUTHOR>

    TBD<p>

    <section "SEE ALSO">

    TBD<p>

    </manpage>
}

# mann.manpage package ?module?
#
# package - Name of a package.
# module  - Name of a module in a package; defaults to the package name.
#
# .manpage file for the module.

maptemplate ::qfile::mann.manpage {package {module ""}} {
    set project [project name]

    if {$module eq ""} {
        set module $package
        set ref "${package}(n)"
    } else {
        set ref "{${package}(n) ${module}(n)}"
    }
} {
    <manpage %ref "%package %module module">

    <section SYNOPSIS>

    <itemlist>

    <section DESCRIPTION>

    TODO: General description of the %module(n) module

    <section COMMANDS>

    TODO: Usage information for the %module(n) module.

    <section AUTHOR>

    TBD<p>

    <section "SEE ALSO">

    TBD<p>

    </manpage>
}

#-------------------------------------------------------------------------
# QuillInfo modules

# quillinfoPkgIndex
#
# pkgIndex.tcl file for the quillinfo(n) package.

maptemplate ::qfile::quillinfoPkgIndex {} {
    set project [project name]
    set description [project description]
} {
    #-------------------------------------------------------------------------
    # TITLE: 
    #    pkgIndex.tcl
    #
    # PROJECT:
    #    %project: %description
    #
    # DESCRIPTION:
    #    %project quillinfo(n): pkgIndex file
    #
    #    Generated by Quill
    #-------------------------------------------------------------------------

    package ifneeded quillinfo 1.0 [list source [file join $dir pkgModules.tcl]]
}

# quillinfoPkgModules
#
# pkgModules.tcl file for the quillinfo(n) package.

maptemplate ::qfile::quillinfoPkgModules {} {
    set project [project name]
    set description [project description]

} {
    #-------------------------------------------------------------------------
    # TITLE: 
    #    pkgModules.tcl
    #
    # PROJECT:
    #    %project: %description
    #
    # DESCRIPTION:
    #    %project: quillinfo(n) Package Loader
    #
    #    Generated by Quill
    #
    #-----------------------------------------------------------------------

    package provide quillinfo 1.0

    #-----------------------------------------------------------------------
    # Get the library directory

    namespace eval ::quillinfo:: {
        variable library [file dirname [info script]]
    }

    source [file join $::quillinfo::library quillinfo.tcl]
}

# quillinfo.tcl
#
# quillinfo.tcl file for the quillinfo(n) package.

maptemplate ::qfile::quillinfo.tcl {} {
    set project     [project name]
    set description [project description]
    set meta        [list [project metadata]]
} {
    #-------------------------------------------------------------------------
    # TITLE: 
    #    quillinfo.tcl
    #
    # PROJECT:
    #    %project: %description
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
        array set meta %meta

        namespace export \\
            project      \\
            description  \\
            version      \\
            homepage     \\
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
}

# LICENSE
#
# Default README.md file for a Quill project.

maptemplate ::qfile::README.md {} {
    set project [project name]
} {
    # %project

    A description of your new project.
}

# LICENSE
#
# Default LICENSE file for a Quill project.

maptemplate ::qfile::LICENSE {} {
    set project [project name]
} {
    # %project

    Your license text.
}

# index.quilldoc
#
# Default index.quilldoc file for the project documentation.

maptemplate ::qfile::index.quilldoc {} {
    set project [project name]
} {
    <document "%project Documentation Tree">

    <preface general "General Documents">

    TBD<p>

    <preface man "Man Pages">

    <ul>
    <li><link "man1/index.html" "Section (1): Applications">
    <li><link "man5/index.html" "Section (5): File Formats">
    <li><link "mann/index.html" "Section (n): Tcl Commands">
    <li><link "mani/index.html" "Section (i): Tcl Interfaces">
    </ul><p>

    </document>
}