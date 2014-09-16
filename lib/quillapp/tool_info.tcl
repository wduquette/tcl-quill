#-------------------------------------------------------------------------
# TITLE: 
#    infotool.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    "quill info" tool implementation.  This tool outputs the project's
#    information to the console.
#
#-------------------------------------------------------------------------

quillapp::tool define info {
    description "Displays the project metadata to the console."
    argspec     {0 0 ""}
    needstree   true
} {
    The "quill info" tool displays the project's metadata to the console 
    in human-readable form.
} {
    # execute argv
    #
    # argv - command line arguments for this tool
    # 
    # Executes the tool given the arguments.

    typemethod execute {argv} {
        puts "[project name] [project version]: [project description]"
        puts ""
        puts "Project Tree:"
        puts "    [project root]"
        puts ""

        if {[got [project app names]]} {
            puts "Applications:"

            set table [list]            
            foreach app [project app names] {
                set row [dict create Name $app]
                if {[project app gui $app]} {
                    dict set row Mode "GUI"
                } else {
                    dict set row Mode "Console"
                }

                dict set row Platforms \
                    [join [project app apptypes $app] {, }]
                lappend table $row
            }

            table puts $table \
                -leader "    " \
                -sep    "  "   \
                -showheaders
            puts ""
        }

        if {[got [project provide names]]} {
            puts "Provided Libraries:"
            foreach lib [project provide names] {
                puts "    ${lib}(n)"
            }
            puts ""
        }

        if {[got [project require names -all]]} {
            puts "Required Packages:"

            set table [list]
            foreach pkg [project require names -all] {
                set ver   [project require version $pkg]
                set local [project require local $pkg]

                if {$local} {
                    set tag " (local)"
                } else {
                    set tag ""
                }

                lappend table [list p $pkg v $ver t $tag]
            }
            table puts $table -leader "    " -sep "  "
            puts ""
        }
    }
}

