#-------------------------------------------------------------------------
# TITLE: 
#    tool_dist.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    "quill dist" tool implementation.  This tool builds distribution
#    files.
#
#-------------------------------------------------------------------------

app_quill::tool define dist {
    description "Build distribution .zip files"
    argspec     {0 1 "?<name>?"}
    needstree   true
} {
    The "quill dist" tool builds distribution .zip files based on the
    distributions defined in the project's project.quill file.  See
    quill(5) for the details on how to define a distribution.

    quill dist ?<name>?
        By default, builds all of the distribution files.  Optionally,
        builds the named distribution.
} {
    # execute argv
    #
    # argv - command line arguments for this tool
    # 
    # Executes the tool given the arguments.

    typemethod execute {argv} {
        if {!$::got(zipfile::encode)} {
            throw FATAL [outdent {
                Cannot build distributions; zipfile::encode is not
                available locally.  Please check dependencies, and
                make sure your teapot is configured properly.
            }]
        }

        if {[llength $argv] == 1} {
            set dists [list [lindex $argv 0]]
        } else {
            set dists [project dist names]
        }

        foreach dist $dists {
            if {$dist ni [project dist names]} {
                throw FATAL "Unknown distribution: \"$dist\""
            }

            dist make $dist
        }
    }
}

