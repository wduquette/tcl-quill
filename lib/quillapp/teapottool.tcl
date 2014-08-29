#-------------------------------------------------------------------------
# TITLE: 
#    teapottool.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project teapot System for Tcl/Tk
#
# DESCRIPTION:
#    "quill teapot" tool implementation.  This tool manages Quill's
#    connection to the default teapot.
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Register the tool

set ::quillapp::tools(teapot) {
    command     "teapot"
    description "Manages local teapot repository."
    argspec     {0 1 "?<subcommand>?"}
    intree      false
    ensemble    ::quillapp::teapottool
}

set ::quillapp::help(teapot) {
    The local teapot repository is where the require'd packages listed
    in project.quill are installed on the user's machine.

    quill teapot
        Displays the status of the local teapot repository.  If there 
        are problems with the configuration, it will give directions
        on how to fix them.

    quill teapot create
        Creates a local teapot in the user's home directory, as 
        ~/.quill/teapot, and makes it the default teapot.  This is
        necessary only if the default teapot isn't user-writable.

    quill teapot link
        Links the local teapot to the development Tcl shell if it isn't 
        properly linked already.  This operation usually requires "admin" 
        or "root" privilieges; on Linux or OS X, it is generally run 
        using "sudo", as follows:

            $ sudo -E quill teapot link

    quill teapot list
        As a convenience, this lists the contents of the local teapot.
}

#-------------------------------------------------------------------------
# Namespace Export

namespace eval ::quillapp:: {
    namespace export \
        teapottool
} 

#-------------------------------------------------------------------------
# Tool Singleton: teapottool

snit::type ::quillapp::teapottool {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    # execute argv
    #
    # argv - command line arguments for this tool
    # 
    # Executes the tool given the arguments.

    typemethod execute {argv} {
        if {[llength $argv] == 0} {
            DisplayTeapotStatus
            return
        }

        set sub [lshift argv]

        switch -exact -- $sub {
            create {
                CreateQuillTeapot
            }
            link {
                LinkQuillTeapot
            }
            list {
                ListQuillTeapot
            }
            default {
                throw FATAL "Unknown subcommand: \"quill teapot $sub\""
            }
        }
    }

    # DisplayTeapotStatus
    #
    # Displays the current status.

    proc DisplayTeapotStatus {} {
        puts "Teapot Status:"

        # FIRST, get the teapot path.
        set tpath [env pathof teapot]
        DisplayItem "Location:" $tpath

        # NEXT, is the default teapot the ~/.quill teapot?
        set qflag [expr {$tpath eq [teapot quillpath]}]

        # NEXT, is the teapot writable?
        set wflag [teapot writable]
        DisplayItem "Writable?" [expr {$wflag ? "Yes" : "No"}]

        # NEXT, is the teapot linked to the tclsh and vice versa?
        set t2s [teapot islinked teapot2shell]
        set s2t [teapot islinked shell2teapot]
        set lflag [expr {$t2s && $s2t}]
        DisplayItem "Linked?" [expr {$lflag ? "Yes" : "No"}]

        if {!$lflag} {
            if {!$t2s} {
                puts "      The teapot is not linked to the tclsh."
            }
            if {!$s2t} {
                puts "      The tclsh is not linked to the teapot."
            }
        }

        puts ""

        # NEXT, assess the status.

        # Writable and linked: all is well!
        if {$wflag && $lflag} {
            puts [outdent {
                The local teapot is writable, and is properly linked
                to the default Tcl shell.  

                Everything appears to be OK.
            }]

            return
        }

        # Not writable
        if {!$wflag} {
            puts [outdent {
                The local teapot is not writable.  This will need to be fixed.
            }]

            if {$qflag} {
                puts [outdent {
                    You are using a teapot in your home directory;
                    please making it writable.
                }]
            } else {
                puts [outdent {
                    Please create and link a teapot in your home directory:

                    $ quill teapot create
                    $ sudo -E quill teapot link

                    See 'quill help teapot' for more information.
                }]
            }

            return
        }

        # Writable but not linked.
        if {!$lflag} {
            puts [outdent {
                The local teapot is not linked to the default Tcl shell.
                This will need to be fixed:

                $ sudo -E quill teapot link

                See 'quill help teapot' for more information.
            }]
        }
    }


    # DisplayItem label text
    #
    # label   - An item label
    # text    - An item value
    #
    # Displays items in parallel columns.

    proc DisplayItem {label text} {
        puts [format "    %-10s %s" $label $text]
    }

    #---------------------------------------------------------------------
    # Listing Teapot Contents.

    proc ListQuillTeapot {} {
        puts ""

        set table [teacup list --at-default]

        if {[llength $table] == 0} {
            puts "The teapot is empty."
            return
        }

        table puts $table \
            -showheaders \
            -headers {
                entity  "Entity Type" 
                name    "Name" 
                version "Version" 
                platform "Platform"
            }
    }

    #---------------------------------------------------------------------
    # Creating and Linking the Quill Teapot

    # CreateQuillTeapot
    #
    # Creates the writable local teapot.

    proc CreateQuillTeapot {} {
        set qpath [teapot quillpath]

        puts "Creating $qpath..."
        puts [teacup create $qpath]
        puts [teacup default $qpath]
        puts "OK."
    }


    # LinkQuillTeapot
    #
    # Creates the writable local teapot.

    proc LinkQuillTeapot {} {
        set qpath  [teapot quillpath]
        set tclsh  [env pathto tclsh]

        puts "Linking $qpath with $tclsh"

        try {
            puts [teacup link make $qpath $tclsh]
        } on error {result} {
            puts "Error making link: $result"
            puts "Did you run the command using 'sudo'?"
            puts "See 'quill help teapot' for more information."
            return
        }

        # Check it
        set t2s [teapot islinked teapot2shell]
        set s2t [teapot islinked shell2teapot]
        set lflag [expr {$t2s && $s2t}]

        if {!$lflag} {
            puts ""
            puts "The teapot is still not linked."
            puts "See 'quill teapot' for specifics."
        }

    }
}

