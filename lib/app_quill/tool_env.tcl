#-------------------------------------------------------------------------
# TITLE: 
#    tool_env.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    "quill env" tool implementation.  This tool outputs information
#    about the development environment as Quill sees it.
#
#-------------------------------------------------------------------------

app_quill::tool define env {
    description "Describes the development environment."
    argspec     {0 0 ""}
    needstree   false
} {
    The "quill env" tool displays information about the development
    environment as seen by Quill: the tclsh and other tools it is using,
    whether or not it can find them, and how it found them.
} {
    # execute argv
    #
    # argv - command line arguments for this tool
    # 
    # Executes the tool given the arguments.

    typemethod execute {argv} {
        set os [os name]

        puts "Quill [quillinfo version] thinks it is running on $os."
        puts ""
        puts "Local Teapot: [env pathof teapot]"
        puts "" 
        puts "Helper Tools:"

        set table [list]

        lappend table [DisplayPath tclsh]
        lappend table [DisplayPath tkcon]
        lappend table [DisplayPath teacup ]
        lappend table [DisplayPath tclapp]
        lappend table [DisplayPath basekit.tcl]
        lappend table [DisplayPath basekit.tk]
        lappend table [DisplayPath teapot-pkg]

        dictable puts $table -sep "  "

        puts ""
        puts "!  - Helper tool could not be found on disk."
        puts "+  - Path is configured explicitly."

    }

    # DisplayPath tool
    #
    # tool    - The tool name
    #
    # Returns a dictable dictionary for the path.

    proc DisplayPath {tool} {
        set path [env pathto $tool]
        set ver  [env versionof $tool]

        set taglist [list]

        if {$path eq "" || ![file isfile $path]} {
            set code "!"
        } else {
            set code " "
        }

        if {$path eq ""} {
            set path "(NOT FOUND)"
        }

        if {[config get helper.$tool] ne ""} {
            append code "+"
        } else {
            append code " "
        }


        if {$ver ne ""} {
            append path  " (v$ver)"
        }

        return [dict create code $code tool $tool path $path]
    }
}

