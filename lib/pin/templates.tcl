#-------------------------------------------------------------------------
# TITLE: 
#    templates.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Pinion: Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    This module contains code for generating files from templates.
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Namespace Exports

namespace eval ::pin:: {
	namespace export \
		writefile
}

#-------------------------------------------------------------------------
# Public Commands

# writefile filename text 
#
# filename - The filename
# text     - The file's contents
#
# Writes the text to the file, only if the content of the file has 
# changed.

proc ::pin::writefile {filename text} {
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
