#-------------------------------------------------------------------------
# TITLE: 
#    project.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Pinion: Project Build System for Tcl
#
# DESCRIPTION:
#    Project file parser and metadata object
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Namespace Exports

namespace eval ::pin:: {
	namespace export \
		project
}

#-------------------------------------------------------------------------
# project ensemble

snit::type ::pin::project {
	# Make it a singleton
	pragma -hasinstances no -hastypedestroy no

	#---------------------------------------------------------------------
	# Constants

	typevariable projectFile "project.pin"

	#---------------------------------------------------------------------
	# Type Variables

	# info - Package data, other than project metadata
	#
	# intree - 1 if we're in a project tree, 0 if not.  Set by
	#          [project findroot]
	# root   - The project tree's root directory

	typevariable info -array {
		intree ""
		root   ""
	}

	# meta - Project metadata array for the project being managed.
	#
	# Data includes:
	#
	# name          - The project name
	# version       - The project version number
	# description   - The project description
	# apps          - List of application names
	#
	# app-$name     - Dictionary of application metadata
	#   TBD

	typevariable meta -array {
		name        ""
		version     ""
		description ""
		apps        {}
	}

	#---------------------------------------------------------------------
	# Public Methods: Initialization

	# findroot
	#
	# Looks for the project's root directory by looking for project.pin
	# in the current directory and on up the chain.

	typemethod findroot {} {
		# FIRST, it's safe to call this multiple times.
		if {$info(intree) ne ""} {
			return $info(intree)
		}

		# NEXT, find the project file
		set info(intree) 0
		set here ""
		set next [pwd]

		while {$next ne $here} {
			set here $next

			if {[file exists [file join $here $projectFile]]} {
				set info(root)   $here
				set info(intree) 1
				break
			}

			set next [file dirname $here]
		}

		return $info(intree)
	}

	# intree
	#
	# Returns 1 if we're in a project tree, and 0 otherwise.

	typemethod intree {} {
		return $info(intree)
	}

	#---------------------------------------------------------------------
	# Queries

	# root path...
	#
	# path... - One or more path components
	#
	# Joins the path components to the project root, and returns the
	# the result.  If no path components are given, just returns the
	# project root.

	typemethod root {args} {
		assert {$info(root) ne ""}
		return [file join $info(root) {*}$args]
	}
}