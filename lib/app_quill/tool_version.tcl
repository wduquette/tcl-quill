#-------------------------------------------------------------------------
# TITLE: 
#    tool_version.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    "quill version" tool implementation.  This tool outputs the Quill
#    version information to the console.
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# ::app_quill::tool::VERSION

app_quill::tool define version {
    description "Displays the Quill tool's version to the console."
    argspec     {0 0 ""}
    needstree   false
} {
    The "quill version" tool displays the Quill application's version
    to the console in human-readable form.
} {
    # execute argv
    #
    # argv - command line arguments for this tool
    # 
    # Executes the tool given the arguments.

    typemethod execute {argv} {
        puts "Quill [quillinfo version]: [quillinfo description]"
        puts ""
        puts "Home Page: [quillinfo homepage]"
        puts ""
        puts "Please submit bug reports to the issue tracker at the home page."
    }
}

