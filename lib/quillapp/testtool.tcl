#-------------------------------------------------------------------------
# TITLE: 
#    testtool.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    "quill test" tool implementation.  This tool outputs the project's
#    information to the console.
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Register the tool

set ::quillapp::tools(test) {
	command     "test"
	description "Executes the project test suite."
	argspec     {0 - "?target ?module?? ?options...?"}
	intree      true
	ensemble    ::quillapp::testtool
}

set ::quillapp::help(test) {
	The "quill test" tool executes the project Tcltest test suite.  By 
	default, "quill test" runs the test suites for all subdirectories of
	<root>/test.  Given one argument, the "target", it executes the
	test suite for the target subdirectory.  Given two arguments, a 
	"target" and a "module" name, runs the tests for the 
	specific module within the target subdirectory.

	Any options are passed to Tcltest.

	It is assumed that the target subdirectory contains a test script
	called "all_tests.test" that executes all of the other test scripts
	in the subdirectory.  Note that "quill new" and "quill add" create 
	the necessary script whenever a library package is added to the
	project.
}

#-------------------------------------------------------------------------
# Namespace Export

namespace eval ::quillapp:: {
	namespace export \
		testtool
} 

#-------------------------------------------------------------------------
# Tool Singleton: testtool

snit::type ::quillapp::testtool {
	# Make it a singleton
	pragma -hasinstances no -hastypedestroy no

	# execute argv
	#
	# argv - command line arguments for this tool
	# 
	# Executes the tool given the arguments.

	typemethod execute {argv} {
		# FIRST, get the target and the module, leaving any options.
		set target [GetNonOption argv]
		set module [GetNonOption argv]

		# NEXT, one or all
		if {$target eq ""} {
			set count 0
			foreach dir [glob -nocomplain [project root test *]] {
				if {[file isdirectory $dir]} {
					incr count
					RunTest [file tail $dir] "" $argv
				}
			}

			if {$count == 0} {
				throw FATAL \
					"No test targets found in [project root test]."
			}

			return
		} else {
			if {![file isdirectory [project root test $target]]} {
				throw FATAL "'$target' is not a valid test target."
			}
			RunTest $target $module $argv
		}


	}

	# RunTest target module options
	#
	# target   - A subdirectory in $root/test
	# module   - The module name of a module test file in $target.
	#            Defaults to "all_tests".
	# optlist  - Any options from the command line.
	#
	# Runs the given test script.

	proc RunTest {target module optlist} {
		# FIRST, get the module
		if {$module eq ""} {
			set module "all_tests"
		}

		set fname [project root test $target $module.test]

		if {![file isfile $fname]} {
			throw FATAL "Cannot find '$module.test'."
		}

		# NEXT, prepare the environment.
		set ::env(TCLLIBPATH) [project libpath]

		# NEXT, run the tests.
		try {
			cd [project root test $target]
			exec [env pathto tclsh] $fname {*}$optlist \
				>@ stdout 2>@ stderr
		} on error {result} {
			throw FATAL "Error running tests: $result"
		}
	}

	# GetNonOption listvar
	#
	# listvar  - Name of a list variable
	#
	# If the first element of the list doesn't begin with "-", it
	# is extracted and returned.  Otherwise, returns "" and leaves
	# the list alone.

	proc GetNonOption {listvar} {
		upvar 1 $listvar theList

		if {![string match "-*" [lindex $theList 0]]} {
			return [lshift theList]
		} else {
			return ""
		}
	}
}

