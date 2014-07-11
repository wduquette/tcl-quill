#-------------------------------------------------------------------------
# TITLE: 
#    fileutils.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl
#
# DESCRIPTION:
#    fileutils(n): File Utilities
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Namespace Exports

namespace eval ::quill:: {
	namespace export \
		readfile     \
        writefile
}

#-------------------------------------------------------------------------
# Command Definitions

# readfile filename
#
# filename  - A filename
#
# Opens the named file and reads it into memory.

proc ::quill::readfile {filename} {
	set f [open $filename r]

	try {
		return [read $f]		
	} finally {
		close $f
	}
}

# writefile filename text 
#
# filename - The filename
# text     - The file's contents
#
# Writes the text to the file, only if the content of the file has 
# changed.

proc ::quill::writefile {filename text} {
    # FIRST, see if there's already a file with the same content.
    if {[file exists $filename]} {
        set oldtext [readfile $filename]

        if {$text eq $oldtext} {
            return
        }
    }

    # NEXT, create the directory if necessary.
    file mkdir [file dirname $filename]

    # NEXT, save the file.
    set f [open $filename w]

    try {
        puts -nonewline $f $text
    } finally {
        close $f
    }
}




