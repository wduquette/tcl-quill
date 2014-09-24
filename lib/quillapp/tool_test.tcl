#-------------------------------------------------------------------------
# TITLE: 
#    tool_test.tcl
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

quillapp::tool define test {
    description "Executes the project test suite."
    argspec     {0 - "?<target> ?<module>?? ?<options>...?"}
    needstree   true
} {
    The "quill test" tool executes the project Tcltest test suite.  By 
    default, "quill test" runs the test suites for all subdirectories of
    <root>/test.  

    quill test
        Runs all test subdirectories, summarizing the results.  To see
        the full output, use 'quill -verbose test'

    quill test <target> ?<options...>?
        Runs the test suite for the <target> subdirectory.

    quill test <target> <module> ?<options...>?
        Runs the tests for the specific <module> within the <target>
        subdirectory.

    Any options are passed to tcltest(n).

    It is assumed that the target subdirectory contains a test script
    called "all_tests.test" that executes all of the other test scripts
    in the subdirectory.  Note that "quill new" and "quill add" create 
    the necessary script whenever a library package is added to the
    project.
} {
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
            # FIRST, we summarize unless -verbose.
            if {[quillapp::verbose]} {
                set mode verbose
            } else {
                set mode summary
                puts [outdent {
                    Summarizing test results.  Use 'quill -verbose test'
                    to see the details.
                }]
                puts ""
            }

            set count 0
            foreach dir [glob -nocomplain [project root test *]] {
                if {[file isdirectory $dir]} {
                    incr count
                    RunTest $mode [file tail $dir] "" $argv
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
            RunTest verbose $target $module $argv
        }
    }

    # RunTest mode target module options
    #
    # mode     - Output mode, verbose or summary
    # target   - A subdirectory in $root/test
    # module   - The module name of a module test file in $target.
    #            Defaults to "all_tests".
    # optlist  - Any options from the command line.
    #
    # Runs the given test script.

    proc RunTest {mode target module optlist} {
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
        cd [project root test $target]
        set cmd [list [env pathto tclsh] $fname {*}$optlist]

        if {$mode eq "verbose"} {
            try {
                exec {*}$cmd >@ stdout 2>@ stderr
            } on error {result} {
                throw FATAL "Error running tests: $result"
            }
        } else {
            try {
                set output [exec {*}$cmd 2>@1]
                FilterOutput $target $output
            } on error {result} {
                puts ""
                throw FATAL [outdent "
                    Error running tests for: $target
                    --> $result

                    Use 'quill -verbose test' or 'quill test $target'
                    to see the details.
                "]
            }
        }
    }

    # FilterOutput target output
    #
    # target   - The test target
    # output   - The output from running the tests.
    #
    # Filters the output, showing only the results.

    proc FilterOutput {target output} {
        set lines [split $output \n]
        foreach line $lines {
            if {[string match "Test file error:*" $line]} {
                throw FATAL $line
            }

            if {![string match "all_tests.test:*" $line]} {
                continue
            }

            set leader [format "%-15s" $target:]
            regsub {^all_tests\.test\:} $line $leader line
            puts $line
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

