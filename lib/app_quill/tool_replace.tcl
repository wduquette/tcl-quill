#-------------------------------------------------------------------------
# TITLE: 
#    tool_replace.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    "quill replace" tool implementation.  This tool does global
#    search and replaces on multiple files.
#
#-------------------------------------------------------------------------

app_quill::tool define replace {
    description "Global text replacement across files."
    argspec     {3 - "<target> <subtext> <file> ?<file>...?"}
    needstree   false
} {
    The "quill replace" tool looks for the target text in the named files,
    and replaces it with the substitution text, saving the old content to
    backup files.  E.g.,

    $ quill replace Fred George *.tcl

    replaces all occurrences of "Fred" with "George" in the .tcl files
    in the current directory.

    NOTE: "quill replace" is not tied to the project tree; it can be used
    with any text files.
} {
    # execute argv
    #
    # argv - command line arguments for the primary app
    # 
    # Executes the app given the arguments.

    typemethod execute {argv} {
        set target    [lshift argv]
        set subtext   [lshift argv]
        set filenames $argv

        foreach name $filenames {
            if {![file isfile $name]} {
                throw FATAL "No such file: $name"
            }
        }

        foreach name $filenames {
            try {
                set text [readfile $name]

                if {[string first $target $text] == -1} {
                    continue
                }

                puts "$name"

                set text [string map [list $target $subtext] $text]

                file copy -force $name $name~

                writefile $name $text
            } on error {result} {
                throw FATAL "Error replacing in \"$name\": $result"
            }
        }
    }
}

