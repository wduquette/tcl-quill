#-------------------------------------------------------------------------
# TITLE: 
#    teapot.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    Module for interacting with "teacup" and managing the location
#    and status of the local "teapot" repository.
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Namespace Export

namespace eval ::quillapp:: {
	namespace export \
		teapot
} 

#-------------------------------------------------------------------------
# Tool Singleton: teapot

snit::type ::quillapp::teapot {
	# Make it a singleton
	pragma -hasinstances no -hastypedestroy no

	#---------------------------------------------------------------------
	# Type Variables

	#---------------------------------------------------------------------
	# Queries

	# quillpath
	#
	# Returns the path to Quill's own teapot.  This teapot might or might
	# not exist at present.

	typemethod quillpath {} {
		return [file normalize [file join ~ .quill teapot]]
	}

	# writable
	#
	# Returns 1 if the default teapot is writable, and 0 otherwise.

	typemethod writable {} {
		return [file writable [plat pathof teapot]]
	}

	# islinked teapot2shell
	#
	# Returns 1 if the teapot knows that it is linked to the default
	# tclsh.

	typemethod {islinked teapot2shell} {} {
		set tclsh  [plat pathto tclsh]
		set teacup [plat pathto teacup]
		set teapot [plat pathof teapot]

		foreach {code path} [exec $teacup link info $teapot] {
			if {[file normalize $path] eq $tclsh} {
				return 1
			}
		}

		return 0
	}

	# islinked shell2teapot
	#
	# Returns 1 if the shell knows that it is linked to the teapot.

	typemethod {islinked shell2teapot} {} {
		set tclsh  [plat pathto tclsh]
		set teacup [plat pathto teacup]
		set teapot [plat pathof teapot]

		foreach {code path} [exec $teacup link info $tclsh] {
			if {[file normalize $path] eq $teapot} {
				return 1
			}
		}

		return 0
	}
}

