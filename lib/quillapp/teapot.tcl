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

	# goodbuild  - Versions prior to 298288 are known to have caused
	#              problems for Quill.
	
	typevariable goodbuild 298288

	#---------------------------------------------------------------------
	# Teapot Queries

	# quillpath
	#
	# Returns the path to Quill's own teapot.  This teapot might or might
	# not exist at present.

	typemethod quillpath {} {
		return [file normalize [file join ~ .quill teapot]]
	}

	# ok
	#
	# Returns 1 if the teapot configuration is OK, and 0 otherwise.
	# The configuration is OK if the default teapot is writable and the 
	# teapot and shell are linked to each other.

	typemethod ok {} {
		expr {
			[teapot writable]              && 
			[teapot islinked teapot2shell] &&
			[teapot islinked shell2teapot]
		}
	}

	# writable
	#
	# Returns 1 if the default teapot is writable, and 0 otherwise.

	typemethod writable {} {
		return [file writable [env pathof teapot]]
	}

	# islinked teapot2shell
	#
	# Returns 1 if the teapot knows that it is linked to the default
	# tclsh.

	typemethod {islinked teapot2shell} {} {
		set tclsh  [env pathto tclsh]
		set teacup [env pathto teacup]
		set teapot [env pathof teapot]

		foreach line [split [exec $teacup link info $teapot] \n] {
			if {[regexp {^Shell\s+(.+)$} $line dummy path] &&
				[file normalize $path] eq $tclsh
			} {
				return 1
			}
		}

		return 0
	}

	# islinked shell2teapot
	#
	# Returns 1 if the shell knows that it is linked to the teapot.

	typemethod {islinked shell2teapot} {} {
		set tclsh  [env pathto tclsh]
		set teacup [env pathto teacup]
		set teapot [env pathof teapot]

		foreach line [split [exec $teacup link info $tclsh] \n] {
			if {[regexp {^Repository\s+(.+)$} $line dummy path] &&
				[file normalize $path] eq $teapot
			} {
				return 1
			}
		}

		return 0
	}

	# checkbuild
	#
	# Checks the build number of the selected teacup executable.

	typemethod checkbuild {} {
		set teacup [env pathto teacup]

		if {$teacup eq ""} {
			return ""
		}

		set verstring [string trim [exec $teacup version]]
		set buildnum [lindex [split $verstring .] end]

		if {$buildnum < $goodbuild} {
			puts [outdent "
				WARNING: You may be using an out-of-date 'teacup'.
				You should update it by executing 'teacup update-self'
				at the command line.  (You might need to use sudo).
			"]
		}
	}

	# installed pkg ver
	#
	# pkg   - A package name
	# ver   - A version string
	#
	# Returns 1 if the named package is installed in the local
	# repository, and 0 otherwise.

	typemethod installed {pkg ver} {
		set items [teapot list --at-default --is package $pkg]

		foreach item $items {
			set p [dict get $item name]
			set v [dict get $item version]

			if {$pkg eq $p && [package vsatisfies $v $ver]} {
				return 1
			}
		}

		return 0
	}

	# list args...
	#
	# Calls "teacup list --as csv" with the other arguments, and
	# converts the result into a list of dictionaries.

	typemethod list {args} {
		set teacup [env pathto teacup -require]

		set output [exec $teacup list --as csv {*}$args]

		# Get the column headers
		set lines [split $output \n]
		set headers [split [lshift lines] ,]

		set result [list]

		foreach line $lines {
			set values [split $line ,]
			lappend result [interleave $headers [split $line ,]]
		}

		return $result
	}

	#---------------------------------------------------------------------
	# Low-level Tools

	# install pkg ver
	#
	# pkg    - a package name
	# ver    - A version number
	#
	# Removes the specified package from the default teapot.

	typemethod install {pkg ver} {
		set teacup [env pathto teacup -require]

		puts [exec $teacup install $pkg $ver]
	}

	# remove pkg ver
	#
	# pkg    - a package name
	# ver    - A version number
	#
	# Removes the specified package from the default teapot.

	typemethod remove {pkg ver} {
		set teacup [env pathto teacup -require]

		foreach item [teapot list --at-default --is package $pkg] {
			set p [dict get $item name]
			set v [dict get $item version]

			if {$p eq $pkg && [package vsatisfies $v $ver]} {
				puts [exec $teacup remove --is package $p $v]
			}
		}
	}

}

