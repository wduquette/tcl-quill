#-------------------------------------------------------------------------
# TITLE: 
#    tool_docs.tcl
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

app_quill::tool define docs {
    description "Formats project documentation."
    argspec     {0 1 "?<target>?"}
    needstree   true
} {
    The "quill docs" tool formats the project's quilldoc(5) and 
    manpage(5) documentation.

    By default, the tool formats all *.quilldoc documents found in 
    <root>/docs/ and it subdirectories, and all *.manpage documents
    in <root>/man*/.  If <target> is given, it may be one of the following:

    * A man page directory name, e.g., "mann", to format all man pages
      in the directory.

    * "docs", to format all *.quilldoc documents found in <root>/docs.

    * The name of a subdirectory of "docs", e.g., "mysubdir", to format
      all *.quilldoc documents found in <root>/docs/mysubdir.

    * The name of a quilldoc(5) file.

    Quill supports four man page sections out of the box:

    man1   - Section (1): Applications
    man5   - Section (5): File Formats
    mann   - Section (n): Tcl Packages
    mani   - Section (i): Tcl Interfaces

    Additional sections can be defined "TBD".
} {
    # execute argv
    #
    # argv - command line arguments for this tool
    # 
    # Executes the tool given the arguments.

    typemethod execute {argv} {
        # FIRST, determine the target.
        set target [lshift argv]

        # If no target is given, format all.
        if {$target eq ""} {
            FormatAllQuillDocs
            FormatAllManPages 
            return
        }

        # If it's a file, format it as a quilldoc(5) document.
        if {[file isfile $target]} {
            FormatQuillDocs [list [file normalize $target]]
            return
        }

        # If it's a man page directory, format the man pages in it.
        if {[string match "man*" $target]} {
            set mandir [project root docs $target]
            if {![file isdirectory $mandir]} {
                throw FATAL "There is no man page directory called \"$target\"".
            }

            FormatManDirs [list $mandir]
            return
        }

        # If it's "docs" format all quilldoc(5) files in docs/.
        if {$target eq "docs"} {
            FormatQuillDocDir [project root docs]
            return
        }

        # If it's a subdirectory of docs, format all quilldoc(5) files
        # in it.
        set dir [project root docs $target]
        if {[file isdirectory $dir]} {
            FormatQuillDocDir $dir
            return
        }

        throw FATAL "Unrecognized document target: \"$target\""
    }

    #---------------------------------------------------------------------
    # Quill Docs

    # FormatAllQuillDocs
    #
    # Formats all Quill documents found in docs/ and its subdirectories.

    proc FormatAllQuillDocs {} {
        set docdir docs 

        set doclist [GetQuillDocs docs]

        if {[got $doclist]} {
            FormatQuillDocs $doclist
        }
    }

    # GetQuillDocs dir
    #
    # dir   - A directory relative to the project root
    #
    # Finds all *.quilldoc files in the directory and its subdirectories.

    proc GetQuillDocs {dir} {
        # FIRST, get the quilldoc(5) files in this directory.
        set doclist [project globfiles $dir *.quilldoc]

        # NEXT, look in subdirectories
        foreach subdir [project globdirs $dir/*] {
            lappend doclist {*}[GetQuillDocs $subdir]
        }

        return $doclist
    }

    # FormatQuillDocDir dirname
    #
    # Formats all Quill documents found in the directory.

    proc FormatQuillDocDir {dirname} {
        set doclist [glob -nocomplain [file join $dirname *.quilldoc]]
        if {[got $doclist]} {
            FormatQuillDocs $doclist
        } else {
            puts "Warning: no documents to format in $dirname"
        }
    }

    # FormatQuillDocs doclist
    #
    # doclist - List of full paths to the documents to format.
    #
    # Formats the named quilldoc(5) documents in place.

    proc FormatQuillDocs {doclist} {
        foreach doc $doclist {
            puts "Writing [file rootname $doc].html"
            set header \
                "[project name] [project version] -- [project description]"

            try {
                quilldoc format $doc \
                    -header  $header \
                    -version [project version] \
                    -manroot [GetManRoot $doc]
            } trap SYNTAX {result} {
                throw FATAL $result
            } on error {result eopts} {
                # Rethrow other errors
                return {*}$eopts $result
            }

        }
    }

    # GetManRoot docfile
    #
    # Gets the relative path from this doc file to the docs/ directory.

    proc GetManRoot {docfile} {
        set docdir [file normalize [file dirname $docfile]]
        set docroot [project root docs]

        if {$docdir eq $docroot} {
            return "."
        }

        if {![string match "$docroot/*" $docdir} {
            throw FATAL "Document file \"$docfile\" is not in the project document tree."
        }

        set manroot [list]
        while {$docdir ne $docroot} {
            lappend manroot ".."
            set docdir [file dirname $docdir] 
        }

        return [file join $manroot]
    }


    #---------------------------------------------------------------------
    # Man Pages

    # FormatAllManPages
    #
    # Formats all man pages in all man page directories (if any)

    proc FormatAllManPages {} {
        set dirnames [project globdirs docs man*]

        if {[got $dirnames]} {
            FormatManDirs $dirnames
        }
    }

    # FormatManDirs dirlist
    #
    # dirlist   - A list of full pathts to thedirectories to format.
    #
    # Formats all man pages in the directories.

    proc FormatManDirs {dirlist} {
        foreach dir $dirlist {
            try {
                manpage format $dir \
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

