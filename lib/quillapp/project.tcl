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
    #
	# apps          - List of application names
	# apptype-$app  - Type of application $name: kit, uberkit, exe
	# gui-$app      - Flag, 0 or 1: does package require Tk?
	#
	# requires      - List of required package names
	# local-$req    - Flag, 0 or 1: is package local?
	#
	# provides      - List of names of exported library packages.


	typevariable meta -array {
		project     ""
		version     ""
		description ""
		url         "http://my.home.page"
		apps        {}
		provides    {}
		requires    {}
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

	# newroot rootdir
	#
	# rootdir - Project root directory name
	#
	# Creates a new project root directory, and positions Quill within
	# it as though findroot had succeeded.  This is for use in bootstrapping
	# new projects.

	typemethod newroot {rootdir} {
		assert {![project intree]}

		set info(root) $rootdir
		file mkdir $info(root)
		cd $info(root)
		set info(intree) 1
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

	typemethod metadata        {} { return [array get meta]   }
	typemethod name            {} { return $meta(project)     }
	typemethod version         {} { return $meta(version)     }
	typemethod description     {} { return $meta(description) }
	typemethod {app names}     {} { return $meta(apps)        }
	typemethod {provide names} {} { return $meta(provides)    }
	typemethod {require names} {} { return $meta(requires)    }

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

	# app apptype app
	#
	# app  - The app name
	#
	# Returns the application type, kit, uberkit, or exe

	typemethod {app apptype} {app} {
		return $meta(apptype-$app)
	}

	# app gui app
	#
	# app - The app name
	#
	# Returns 1 if the app is a GUI, and 0 otherwise.

	typemethod {app gui} {app} {
		return $meta(gui-$app)
	}

	# require version pkg
	#
	# pkg - The package name
	#
	# Returns the required version of the package.

	typemethod {require version} {pkg} {
		return $meta(version-$pkg)
	}

	# require local pkg
	#
	# pkg - The package name
	#
	# Returns 1 if the required package is locally developed, and
	# 0 otherwise.

	typemethod {require local} {pkg} {
		return $meta(local-$pkg)
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
		$interp alias provide  [myproc ProvideCmd]
		$interp alias require  [myproc RequireCmd]

		# NEXT, try to parse the file.  The commands will throw
		# SYNTAX errors if they detect a problem.

		try {
			$interp eval [readfile [project root $projectFile]]
		} trap INVALID {result} {
			throw FATAL "Error in $projectFile: $result"
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

	proc ProjectCmd {project version description} {
		if {$meta(project) ne ""} {
			throw SYNTAX "Multiple \"project\" statements in file"
		}

		prepare project      -required -file
		prepare version      -type ::quillapp::version
		prepare description  -required -tighten

		set meta(project)     $project
		set meta(version)     $version
		set meta(description) $description
	}

	# HomepageCmd url
	#
	# url - The project home page url.
	#
	# Specifies that this project's home page is at the given URL.

	proc HomepageCmd {url} {
		prepare url
		set meta(homepage) $url
	}

	# AppCmd name
	#
	# name - The application name.
	#
	# Specifies that this project builds an application called $name.

	proc AppCmd {name} {
		prepare name -required -file

		ladd meta(apps)          $name
		set  meta(apptype-$name) uberkit
		set  meta(gui-$name)     0
	}

	# ProvideCmd name
	#
	# name - The library package name.
	#
	# Specifies that this project provides a package called $name.

	proc ProvideCmd {name} {
		prepare name -required -file
		ladd meta(provides) $name
	}

	# RequireCmd name version ?options?
	#
	# name    - The package name.
	# version - The package's version number
	# options - Requirement options
	#
	#    -local  - The package is locally developed.  Do not try to
	#              retrieve it from ActiveState's teapot.
	#
	# Specifies that this project requires the named package.

	proc RequireCmd {name version args} {
		# FIRST, options
		set local 0
		while {[llength $args] > 0} {
			set opt [lshift args] 

			switch -exact -- {
				-local  { set local 1}
				default { error "Unknown option: \"$opt\"" }
			}
		}

		# NEXT, validate data
		prepare name -required
		prepare version -type {::quillapp::version rqmt}

		# NEXT, save the data
		ladd meta(requires)      $name
		set  meta(version-$name) $version
		set  meta(local-$name)   $local
	}

	#---------------------------------------------------------------------
	# Saving project metadata
	#
	# For projects with an "app", Quill saves the project metadata into
	# a package called "quillinfo", thus giving the application access
	# to the information.
	#
	# In addition, Quill updates lib/<package> files with the 
	# project version.

	# quillinfo save
	#
	# Saves project metadata as appropriate.

	typemethod {quillinfo save} {} {
		assert {[$type gotinfo]}

		# FIRST, save the info to quillinfo.
		if {[$type gotapp]} {
			element quillinfo
		}

		# NEXT, update each lib.
		foreach libdir [project globdirs lib *] {
			UpdatePkgIfneeded $libdir
			UpdatePkgProvide $libdir
			UpdatePkgRequire $libdir
		}
	}

	# UpdatePkgIfneeded libdir
	#
	# libdir    - A project lib directory
	#
	# Looks for the pkgIndex file and updates the 
	# "package ifneeded" line.

	proc UpdatePkgIfneeded {libdir} {
		# FIRST, get the file to update
		set package [file tail $libdir]
		set pkgIndex [file join $libdir pkgIndex.tcl]

		# NEXT, if there isn't one, we don't need to update this package.
		if {![file isfile $pkgIndex]} {
			return
		}

		# NEXT, get the text and split it on the tag.
		set text [readfile $pkgIndex]
		set pieces [tagsplit ifneeded $text]

		# NEXT, if the tag isn't present, we don't need to update this
		# package.
		if {[llength $pieces] == 0} {
			return
		}

		# NEXT, update the ifneeded block.
		lassign $pieces before block after
		lappend nblock [format [tighten {
		    package ifneeded %s %s 
		    [list source [file join $dir pkgModules.tcl]]
		}] $package [project version]]

		# NEXT, output the updated file if the text has changed.
		writefile $pkgIndex [join [concat $before $nblock $after] \n]
	}

	# UpdatePkgProvide libdir
	#
	# libdir    - A project lib directory
	#
	# Looks for the pkgModules file and updates the 
	# "package provide" line.

	proc UpdatePkgProvide {libdir} {
		# FIRST, get the file to update
		set package [file tail $libdir]
		set pkgModules [file join $libdir pkgModules.tcl]

		# NEXT, if there isn't one, we don't need to update this package.
		if {![file isfile $pkgModules]} {
			return
		}

		# NEXT, get the text and split it on the tag.
		set text [readfile $pkgModules]
		set pieces [tagsplit provide $text]

		# NEXT, if the tag isn't present, we don't need to update this
		# package.
		if {[llength $pieces] == 0} {
			return
		}

		# NEXT, update the provide block.
		lassign $pieces before block after
		lappend nblock [format {package provide %s %s} \
			$package [project version]]

		# NEXT, output the updated file if the text has changed.
		writefile $pkgModules [join [concat $before $nblock $after] \n]
	}

	# UpdatePkgRequire libdir
	#
	# libdir    - A project lib directory
	#
	# Looks for the pkgModules file and updates the 
	# "package require" block.

	proc UpdatePkgRequire {libdir} {
		# FIRST, get the file to update
		set package [file tail $libdir]
		set pkgModules [file join $libdir pkgModules.tcl]

		# NEXT, if there isn't one, we don't need to update this package.
		if {![file isfile $pkgModules]} {
			return
		}

		# NEXT, get the text and split it on the tag.
		set text [readfile $pkgModules]
		set pieces [tagsplit require $text]

		# NEXT, if the tag isn't present, we don't need to update this
		# package.
		if {[llength $pieces] == 0} {
			return
		}

		# NEXT, update the require block.
		lassign $pieces before block after

		set nblock [list]
		foreach line $block {
			if {[string match "package require *" [tighten $line]]} {
				set package [lindex $line 2]

				if {$package in [project require names]} {
					set ver [project require version $package]
					lappend nblock "package require $package $ver"
				} else {
					puts [outdent "
						Warning: $pkgModules 
						requires package \"$package\", but \"$package\" is
						not required in project.quill.
					"]
					puts ""
					lappend nblock $line
				}

			} else {
				lappend nblock line
			}
		}
		# NEXT, output the updated file if the text has changed.
		writefile $pkgModules [join [concat $before $nblock $after] \n]
	}
}