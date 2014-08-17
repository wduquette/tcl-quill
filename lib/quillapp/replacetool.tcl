#-------------------------------------------------------------------------
# TITLE: 
#    replacetool.tcl
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

#-------------------------------------------------------------------------
# Register the tool

set ::quillapp::tools(replace) {
	command     "replace"
	description "Global text replacement across files."
	argspec     {3 - "target subtext files..."}
	intree      false
	ensemble    ::quillapp::replacetool
}

set ::quillapp::help(replace) {
	The "quill replace" tool looks for the target text in the named files,
	and replaces it with the substitution text, saving the old content to
	backup files.  E.g.,

	$ quill replace Fred George *.tcl
}

#-------------------------------------------------------------------------
# Namespace Export

namespace eval ::quillapp:: {
	namespace export \
		replacetool
} 

#-------------------------------------------------------------------------
# Tool Singleton: replacetool

snit::type ::quillapp::replacetool {
	# Make it a singleton
	pragma -hasinstances no -hastypedestroy no

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

