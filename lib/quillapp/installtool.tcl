#-------------------------------------------------------------------------
# TITLE: 
#    installtool.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    "quill install" tool implementation.  This tool installs project
#    build targets for use on the local system.
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Register the tool

set ::quillapp::tools(install) {
	command     "install"
	description "Install applications and libraries"
	argspec     {0 - "?app|lib? ?names..."}
	intree      true
	ensemble    ::quillapp::installtool
}

set ::quillapp::help(install) {
	The "quill install" tool installs the project's applications and 
	provided libraries for use on the local system.  By default, all
	applications and libraries listed in project.quill are installed.

	To install only the apps:

	    $ quill install app

	To install specific apps:

	    $ quill install app myfirstapp mysecondapp ...

	To install only the provided libraries:

	    $ quill install lib

	To install specific libraries:

	    $ quill install lib myfirstlib mysecondlib ...

	"quill install" will output warnings for apps or libs that haven't
	been built.

	NOTE: "quill install" doesn't build anything.  To ensure you're 
	installing the latest code, do a "quill build" first.
}

#-------------------------------------------------------------------------
# Namespace Export

namespace eval ::quillapp:: {
	namespace export \
		installtool
} 

#-------------------------------------------------------------------------
# Tool Singleton: installtool

snit::type ::quillapp::installtool {
	# Make it a singleton
	pragma -hasinstances no -hastypedestroy no

	# execute argv
	#
	# argv - command line arguments for this tool
	# 
	# Executes the tool given the arguments.

	typemethod execute {argv} {
		set targetType [lshift argv]
		set names $argv

		# FIRST, install provided libraries
		if {$targetType in {lib ""}} {
			if {[llength $names] == 0} {
				set names [project provide names]
			}
			foreach lib $names {
				InstallTclLib $lib
			}
		}

		# NEXT, install applications
		if {$targetType in {app ""}} {
			if {[llength $names] == 0} {
				set names [project app names]
			}
			foreach app $names {
				InstallTclApp $app
			}
		}
	}

	#---------------------------------------------------------------------
	# Installing Tcl Apps

	# InstallTclApp app
	#
	# app  - The name of the application
	#
	# installs the application to ~/bin.

	proc InstallTclApp {app} {
		if {$app ni [project app names]} {
			throw FATAL \
				"No such application in project.quill: \"$app\""
		}

		set source [project app target $app]
		set dest [file normalize [file join ~ bin $app]]
		puts "Installing app $app as $dest"
		file copy -force $source $dest
	}

	# InstallTclLib lib
	#
	# lib  - The name of the application
	#
	# installs the application to ~/bin.

	proc InstallTclLib {lib} {
		if {$lib ni [project provide names]} {
			throw FATAL "No such library is provided in project.quill: \"$lib\""
		}

		set ver    [project version]
		set source [project root .quill teapot package-$lib-$ver-tcl.zip]

		if {![file isfile $source]} {
			puts "WARNING: Cannot install lib $lib: teapot package"
			puts $source
			puts "has not been built.\n"
			return
		}

		set command ""
		lappend command [plat pathto teacup] install \
			$source

		puts "Installing lib $lib to local teapot..."
		puts [eval exec $command]
	}

}

