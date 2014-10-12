#-------------------------------------------------------------------------
# TITLE: 
#    tool_teapot.tcl
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

app_quill::tool define teapot {
    description "Manages local teapot repository."
    argspec     {0 1 "?<subcommand>?"}
    needstree   false
} {
    The local teapot repository is where the require'd packages listed
    in project.quill are installed on the user's machine.

    quill teapot
        Displays the status of the local teapot repository.  If there 
        are problems with the configuration, it will give directions
        on how to fix them.

    quill teapot fix
        Creates a local teapot in the user's home directory, as 
        ~/.quill/teapot, and gives you a script to run to make it the
        default teapot.  This script usually requires "admin" 
        or "root" privilieges; on Linux or OS X, it is generally run 
        using "sudo".

    quill teapot list
        As a convenience, this lists the contents of the local teapot.
} {
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
            fix {
                FixQuillTeapot
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
                The local teapot is not writable.
            }]

            if {$qflag} {
                puts [outdent {
                    You are using a teapot in your home directory;
                    you will need to make it writable.
                }]
            } else {
                puts [outdent {
                    You need to create and link a teapot in your home
                    directory.
                }]
            }
        }

        # Writable but not linked.
        if {$wflag && !$lflag} {
            puts [outdent {
                The local teapot is not linked to the default Tcl shell.
            }]
        }

        puts [outdent {
            These problems need to be fixed.  Please execute 
            'quill teapot fix'; it will tell you precisely what you
            need to do.
        }]
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

        dictable puts $table \
            -showheaders \
            -headers {
                entity  "Entity Type" 
                name    "Name" 
                version "Version" 
                platform "Platform"
            }
    }

    #---------------------------------------------------------------------
    # Fixing the Quill Teapot

    # FixQuillTeapot
    #
    # Quill fixes what it can, and emits a script the user can execute
    # to fix the rest.

    proc FixQuillTeapot {} {
        # FIRST, if everything's OK there's nothing to do.
        if {[teapot ok]} {
            puts "Everything appears to be OK already."
            return
        }

        # NEXT, create the local teapot, if it doesn't exist.
        set qpath [teapot quillpath]

        if {![file isdirectory $qpath]} {
            puts "Creating $qpath..."
            puts [teacup create $qpath]
            puts "OK."
        }

        # NEXT, output the script.
        if {[os flavor] eq "windows"} {
            EmitBatchFile
        } else {
            EmitBashScript
        }
    }

    # EmitBatchFile
    #
    # Outputs the script for Windows users.

    proc EmitBatchFile {} {
        set filename [file join [env appdata] fixteapot.bat]

        puts [outdent "
            Quill has created a teapot repository in your home directory.
            It needs to be linked to the tclsh you are using; and it 
            appears that this will require admin privileges.  Quill is
            about to write a batch file that you (or someone who has
            admin privileges) can use to take care of this.

            The script is here:
                $filename

            Run it, and then run 'quill teapot' to check the results.
        "]

        writefile $filename [::app_quill::FixTeapotBat]
    }

    # EmitBashScript
    #
    # Outputs the script for Windows users.

    proc EmitBashScript {} {
        set filename [file join [env appdata] fixteapot]

        if {[os username] eq ""} {
            throw FATAL [outdent "
                Quill cannot determined your user name; none of the usual
                environment variables are set.  Please set USER to your
                user name, and try again.
            "]
        }

        puts [outdent "
            Quill has created a teapot repository in your home directory.
            It needs to be linked to the tclsh you are using; and it 
            appears that this will require superuser privileges.  Quill is
            about to write a bash script that you (or someone who has
            superuser privileges) can use to take care of this.

            The script is here:
                $filename

            Run it, and then run 'quill teapot' to check the results.
        "]

        writefile $filename [::app_quill::FixTeapotBash]
    }

}

#---------------------------------------------------------------------
# Templates

maptemplate ::app_quill::FixTeapotBat {} {
    set teacup    [env pathto teacup]
    set quillpath [teapot quillpath]
    set tclsh     [env pathto tclsh]
} {
    %teacup default %quillpath
    %teacup link make %quillpath %tclsh
}


# TODO: add code to env to get the user name in a safe way.
maptemplate ::app_quill::FixTeapotBash {} {
    set teacup     [env pathto teacup]
    set quillpath  [teapot quillpath]
    set tclsh      [env pathto tclsh]
    set indexcache [env pathof indexcache]
    set user       [os username]
} {
    %teacup default %quillpath
    %teacup link make %quillpath %tclsh
    chown -R %user %indexcache
    chown -R %user %quillpath
}

