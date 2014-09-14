#-------------------------------------------------------------------------
# TITLE: 
#    installtool.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    "quill install" tool implementation.  This tool installs project
#    build targets for use on the local system.
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Register the tool

set ::quillapp::tools(install) {
    command     "install"
    description "Install applications and libraries"
    argspec     {0 - "?app|lib? ?<name>...?"}
    needstree   true
    ensemble    ::quillapp::installtool
}

set ::quillapp::help(install) {
    The "quill install" tool installs the project's applications and 
    provided libraries for use on the local system.  Applications are
    installed into the user's ~/bin directory, and libraries are installed
    into the local teapot repository.

    By default, all applications and libraries listed in project.quill 
    are installed.

    quill install app ?<name>...?
        Install all applications.  Optionally, install the named
        applications.

    quill install lib ?<name>...?
        Install all libraries.  Optionally, install the named libraries.

    "quill install" will output warnings for apps or libs that haven't
    been built.

    NOTE: "quill install" doesn't build anything.  To ensure you're 
    installing the latest code, do a "quill build" first.
}

#-------------------------------------------------------------------------
# Namespace Export

namespace eval ::quillapp:: {
    namespace export \
        installtool
} 

#-------------------------------------------------------------------------
# Tool Singleton: installtool

snit::type ::quillapp::installtool {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    # execute argv
    #
    # argv - command line arguments for this tool
    # 
    # Executes the tool given the arguments.

    typemethod execute {argv} {
        set targetType [lshift argv]
        set names $argv

        # FIRST, install provided libraries
        if {$targetType in {lib ""}} {
            if {[llength $names] == 0} {
                set names [project provide names]
            }
            foreach lib $names {
                InstallTclLib $lib
            }
        }

        # NEXT, install applications
        if {$targetType in {app ""}} {
            if {[llength $names] == 0} {
                set names [project app names]
            }
            foreach app $names {
                InstallTclApp $app
            }
        }
    }

    #---------------------------------------------------------------------
    # Installing Tcl Apps

    # InstallTclApp app
    #
    # app  - The name of the application
    #
    # installs the application to ~/bin.

    proc InstallTclApp {app} {
        if {$app ni [project app names]} {
            throw FATAL \
                "No such application in project.quill: \"$app\""
        }

        set apptypes [project app apptypes $app]
        if {[os flavor] in $apptypes} {
            set apptype [os flavor]
        } elseif {"kit" in $apptypes} {
            set apptype kit
        } else {
            throw FATAL "Application $app is never built for this platform."
        }

        set source [project app target $app $apptype]
        set dest [file normalize [file join ~ bin [os exefile $app]]]
        puts "Installing app [file tail $source] as $dest"
        file copy -force $source $dest
    }

    # InstallTclLib lib
    #
    # lib  - The name of the application
    #
    # installs the application to ~/bin.

    proc InstallTclLib {lib} {
        if {$lib ni [project provide names]} {
            throw FATAL "No such library is provided in project.quill: \"$lib\""
        }

        set ver    [project version]
        set source [project root .quill teapot package-$lib-$ver-tcl.zip]

        if {![file isfile $source]} {
            puts "WARNING: Cannot install lib $lib: teapot package"
            puts $source
            puts "has not been built.\n"
            return
        }

        puts "Installing lib $lib to local teapot..."
        teacup installfile $source
    }

}

