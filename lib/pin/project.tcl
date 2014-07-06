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

	#---------------------------------------------------------------------
	# Metadata Queries

	typemethod name        {} { return $meta(name)        }
	typemethod version     {} { return $meta(version)     }
	typemethod description {} { return $meta(description) }
	typemethod {app names} {} { return $meta(apps)        }


	#---------------------------------------------------------------------
	# Loading the Project file

	# loadinfo
	#
	# Attempts to load the project metadata from the project file into
	# the meta() array.

	typemethod loadinfo {} {
		assert {$info(intree)}

		# FIRST, set up the slave interpreter to parse this.
		# TODO: Use a smart interpreter
		set interp [interp create -safe]

		$interp alias project [myproc ProjectCmd]
		$interp alias app     [myproc AppCmd]
		$interp alias require [myproc RequireCmd]

		# NEXT, try to parse the file.  The commands will throw
		# SYNTAX errors if they detect a problem.

		try {
			$interp eval [readfile [project root $projectFile]]
		} trap SYNTAX {result} {
			throw FATAL "Syntax error in $projectFile: $result"
		} trap {TCL WRONGARGS} {result} {
			throw FATAL "Syntax error in $projectFile: $result"
		}
	}

	# ProjectCmd name version description
	# 
	# name        - The project name
	# version     - The project version
	# description - The project description
	# 
	# Defines the project's identity.  The version must be a valid
	# [package provide] version string.
	#
	# TODO: Add [prepare] command.
	# TODO: Validate project name.
	# TODO: Validate version string
	# TODO: Validate that there's a description.

	proc ProjectCmd {name version description} {
		set meta(name)        $name
		set meta(version)     $version
		set meta(description) [tighten $description]
	}

	# AppCmd name
	#
	# name - The application name.
	#
	# Specifies that this project builds an application called $name.

	proc AppCmd {name} {
		ladd meta(apps) $name
	}

	# RequireCmd name version
	#
	# name    - The package name.
	# version - The package's version number
	#
	# Specifies that this project requires the named package.

	proc RequireCmd {name version} {
		# TODO: Add relevant code
	}

}