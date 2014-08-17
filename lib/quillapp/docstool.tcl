#-------------------------------------------------------------------------
# TITLE: 
#    docstool.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    "quill docs" tool implementation.  This tool formats project man
#    pages, and may ultimately do other things as well.
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Register the tool

set ::quillapp::tools(docs) {
    command     "docs"
    description "Formats project documentation."
    argspec     {0 1 "?<mandir>?"}
    intree      true
    ensemble    ::quillapp::docstool
}

set ::quillapp::help(docs) {
    The "quill docs" tool formats the project's manpage(5) documentation.

    By default, the tool formats all man pages.  If <mandir> is given,
    it needs to be the name of one of the man page directories 
    under <root>/docs, e.g., "mann".

    Quill supports four man page sections out of the box:

    man1   - Section (1): Applications
    man5   - Section (5): File Formats
    mann   - Section (n): Tcl Packages
    mani   - Section (i): Tcl Interfaces

    Additional sections can be defined "TBD".
}

#-------------------------------------------------------------------------
# Namespace Export

namespace eval ::quillapp:: {
    namespace export \
        docstool
} 

#-------------------------------------------------------------------------
# Tool Singleton: docstool

snit::type ::quillapp::docstool {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    # execute argv
    #
    # argv - command line arguments for this tool
    # 
    # Executes the tool given the arguments.
    #
    # TODO: Some of this code needs to be available to 
    # buildtool when buildtool exists.

    typemethod execute {argv} {
        # FIRST, get the directories to process.
        if {[llength $argv] > 0} {
            set mandir [lindex $argv 0]

            set fulldir [project root docs $mandir]
            if {![file isdirectory $fulldir]} {

                throw FATAL [outdent "
                    There is no manpage directory called \"$fulldir\".
                "]
            }

            set dirnames [list $fulldir]
        } else {
            set dirnames [project globdirs docs man*]
        }

        if {[llength $dirnames] == 0} {
            throw FATAL [outdent {
                There are no manpage directories to process.  See
                "quill help docs" for information.
            }]
        }

        # NEXT, set up the manpage processor
        set mp [manpage %AUTO%]

        foreach dir $dirnames {
            try {
                $mp format $dir \
                    -header  [project header]  \
                    -version [project version]
            } trap SYNTAX {result} {
                throw FATAL $result
            } on error {result eopts} {
                # Rethrow other errors
                return {*}$eopts $result
            }
        }

    }
}

