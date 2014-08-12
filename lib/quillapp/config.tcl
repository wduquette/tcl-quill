#-------------------------------------------------------------------------
# TITLE: 
#    config.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    quill.config parmset(n) module.
#
#-------------------------------------------------------------------------


#-------------------------------------------------------------------------
# Namespace Export

namespace eval ::quillapp:: {
	namespace export \
		config
} 

#-------------------------------------------------------------------------
# config

snit::type ::quillapp::config {
	# Make it a singleton
	pragma -hasinstances no -hastypedestroy no

	#---------------------------------------------------------------------
	# Type Variables

	# name of the configuration file
	typevariable configFile ""

	#---------------------------------------------------------------------
	# Type Components

	typecomponent ps ;# The parmset

	#---------------------------------------------------------------------
	# Public Methods

	delegate typemethod * to ps

	# init
	#
	# Initializes the parm set, and attempts to load the configuration
	# file.

	typemethod init {} {
		# FIRST, create and populate the parmset.
		set ps [parmset ${type}::ps]

		# Helper Commands
		$ps define helper.tclsh  ::quillapp::exefile ""
		$ps define helper.teacup ::quillapp::exefile ""
		$ps define helper.tkcon  ::quillapp::tclfile ""

		# Load the config file.
		set configFile [file join ~ .quill quill.config]

		if {[file isfile $configFile]} {
			$ps load $configFile -forgiving
		}
	}
}

