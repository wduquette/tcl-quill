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
		# TODO: Consider making ::quillapp::filename a snit::type workalike,
		# with options for "-executable" and "-pattern", so that I can
		# define executable-specific types.  Actually, the types could
		# also know how to find them....

		$ps define helper.tclsh       snit::stringtype ""
		$ps define helper.teacup      snit::stringtype ""
		$ps define helper.tkcon       snit::stringtype ""
		$ps define helper.tclapp      snit::stringtype ""
		$ps define helper.basekit.tcl snit::stringtype ""
		$ps define helper.basekit.tk  snit::stringtype ""
		$ps define helper.teapot-pkg  snit::stringtype ""

		# Load the config file.
		set configFile [file join ~ .quill quill.config]

		if {[file isfile $configFile]} {
			$ps load $configFile -forgiving
		}
	}

	# save
	#
	# Saves the configuration parameters to disk.

	typemethod save {} {
		$ps save $configFile
	}
}

