#-------------------------------------------------------------------------
# TITLE: 
#    project.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl
#
# DESCRIPTION:
#    Project file parser and metadata object
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Namespace Exports

namespace eval ::quillapp:: {
	namespace export \
		project
}

#-------------------------------------------------------------------------
# project ensemble

snit::type ::quillapp::project {
	# Make it a singleton
	pragma -hasinstances no -hastypedestroy no

	#---------------------------------------------------------------------
	# Constants

	typevariable projectFile "project.quill"

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
	# project       - The project name
	# version       - The project version number
	# description   - The project description
	# homepage      - URL of the project home page.
	# apps          - List of application names
	#
	# app-$name     - Dictionary of application metadata
	#   TBD

	typevariable meta -array {
		project     ""
		version     ""
		description ""
		url         "http://my.home.page"
		apps        {}
	}

	#---------------------------------------------------------------------
	# Public Methods: Initialization

	# findroot
	#
	# Looks for the project's root directory by looking for project.quill
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
		return [file normalize [file join $info(root) {*}$args]]
	}

	# glob pattern...
	#
	# pattern... - One or more pattern components
	#
	# The pattern components are [file join]'d to the 
	# [project root] and passed to [glob].  The result is returned.

	typemethod glob {args} {
		set pattern [project root {*}$args]

		set result [list]
		foreach fname [glob -nocomplain $pattern] {
			lappend result [file normalize $fname]
		}
		return $result
	} 

	# globfiles pattern...
	#
	# pattern... - One or more pattern components
	#
	# The pattern components are [file join]'d to the 
	# [project root] and passed to [glob].  All normal files
	# from the result are returned.

	typemethod globfiles {args} {
		set result [list]
		foreach fname [project glob {*}$args] {
			if {[file isfile $fname]} {
				lappend result $fname
			}
		}
		return $result
	} 

	# globdirs pattern...
	#
	# pattern... - One or more pattern components
	#
	# The pattern components are [file join]'d to the 
	# [project root] and passed to [glob].  All directory names
	# from the result are returned.

	typemethod globdirs {args} {
		set result [list]
		foreach fname [project glob {*}$args] {
			if {[file isdirectory $fname]} {
				lappend result $fname
			}
		}
		return $result
	} 

	#---------------------------------------------------------------------
	# Metadata Queries

	typemethod name        {} { return $meta(project)     }
	typemethod version     {} { return $meta(version)     }
	typemethod description {} { return $meta(description) }
	typemethod {app names} {} { return $meta(apps)        }

	# header
	#
	# Returns the project header string.

	typemethod header {} {
		return "$meta(project) $meta(version): $meta(description)"
	}

	# gotinfo
	#
	# Returns 1 if we've loaded the project's info, and 0 otherwise.

	typemethod gotinfo {} {
		expr {$meta(project) ne ""}
	}

	# gotapp
	#
	# Returns 1 if the project defines an application, and 0 otherwise.

	typemethod gotapp {} {
		expr {[llength $meta(apps)] > 0}
	}

	# libpath
	#
	# Returns the full set of library directories for this project.
	# The assumption is that any code needed by the project is either
	# on this path or included in a linked teapot.
	
	typemethod libpath {} {
		lappend result \
			[project root lib]

		return $result
	}

	# app loader app
	#
	# app  - The app name
	#
	# Returns the path to the loader script.

	typemethod {app loader} {app} {
		return [project root bin $app.tcl]
	}


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

		$interp alias project  [myproc ProjectCmd]
		$interp alias homepage [myproc HomepageCmd]
		$interp alias app      [myproc AppCmd]
		$interp alias require  [myproc RequireCmd]

		# NEXT, try to parse the file.  The commands will throw
		# SYNTAX errors if they detect a problem.

		try {
			$interp eval [readfile [project root $projectFile]]
		} trap SYNTAX {result} {
			throw FATAL "Error in $projectFile: $result"
		} trap {TCL WRONGARGS} {result} {
			throw FATAL "Error in $projectFile: $result"
		}

		# NEXT, if no project is specified that's an error.
		if {$meta(project) eq ""} {
			throw FATAL [outdent {
				The project.quill file doesn't define a project.
				Please add a \"project\" statement.
			}]
		}
	}



	# ProjectCmd project version description
	# 
	# project     - The project project
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

	proc ProjectCmd {project version description} {
		if {$meta(project) ne ""} {
			throw SYNTAX "Multiple \"project\" statements in file"
		}

		set meta(project)     $project
		set meta(version)     $version
		set meta(description) [tighten $description]
	}

	# HomepageCmd url
	#
	# url - The project home page url.
	#
	# Specifies that this project's home page is at the given URL.

	proc HomepageCmd {url} {
		set meta(homepage) $url
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

	#---------------------------------------------------------------------
	# Saving project metadata
	#
	# For projects with an "app", Quill saves the project metadata into
	# a package called "quillinfo", thus giving the application access
	# to the information.

	# quillinfo save
	#
	# Saves project metadata as appropriate.

	typemethod {quillinfo save} {} {
		assert {[$type gotinfo]}

		# FIRST, save the info to quillinfo.
		if {[$type gotapp]} {
			element quillinfo [array get meta]
		}
	}
}