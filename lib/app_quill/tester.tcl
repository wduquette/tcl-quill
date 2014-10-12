#-------------------------------------------------------------------------
# TITLE: 
#    tester.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    "quill test" tool infrastructure
#
# MODES:
#    * Run all tests, printing verbose results in real time; no status
#    * Run all tests, returning status, printing verbose or minimal results.
#    * Run specific target or module in target, printing verbose results in
#      real time; no status.
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Namespace Export

namespace eval ::app_quill:: {
    namespace export \
        tester
} 

#-------------------------------------------------------------------------
# tester

snit::type ::app_quill::tester {
    pragma -hasinstances no -hastypedestroy no

    #---------------------------------------------------------------------
    # Running All Tests

    # runall mode
    #
    # mode    - realtime, verbose, quiet
    #
    # If mode is realtime, then all tests are run and verbose outputs
    # are written in real time.  No status is returned, because Quill
    # doesn't see it.
    #
    # If mode is verbose or quiet, the results are accumulated by quill,
    # the test status is determined, and verbose or quiet results
    # are written to the console as it becomes convenient.  The status
    # is returned, 1 for no failures and 0 for test failures.

    typemethod runall {mode} {
        switch -exact -- $mode {
            realtime { return [RunAllRealTime] }
            verbose  { return [RunAllStatus 1] }
            quiet    { return [RunAllStatus 0] }
            default  { throw FATAL "Unknown test mode: \"$mode\"" }
        }
    }

    # RunAllRealTime
    #
    # Runs all test targets, displaying results in real time.  

    proc RunAllRealTime {} {
        foreach target [glob -nocomplain [project root test *]] {
            if {[file isdirectory $target]} {
                set fname [project root test $target all_tests.test]

                RunTestRealTime $fname
            }
        }
    }

    # RunAllStatus vflag
    #
    # vflag  - 1 for verbose, 0 for quiet
    #
    # Runs all tests, accumulating the results and determining the 
    # status of the tests.  Verbose or quiet results are output as
    # possible, and the status is returned: 1 for success and 0 otherwise.

    proc RunAllStatus {vflag} {
        set status 1

        foreach target [glob -nocomplain [project root test *]] {
            if {[file isdirectory $target]} {
                set fname [project root test $target all_tests.test]

                set newStatus [RunTestStatus $vflag $fname]

                set status [expr {$status && $newStatus}]
            }
        }

        return $status
    }


    # RunTestStatus vflag testfile
    #
    # vflag    - 1 for verbose output, 0 for quiet output.
    # testfile - test file to run.
    #
    # Runs the given test script, saving the output, filtering it if 
    # desired, and returning the status.

    proc RunTestStatus {vflag testfile} {
        # FIRST, prepare the environment.
        set ::env(TCLLIBPATH) [project libpath]

        # NEXT, run the tests.
        set target [file tail [file dirname $testfile]]
        cd [project root test $target]
        set cmd [list [env pathto tclsh] $testfile]

        try {
            set output [exec {*}$cmd 2>@1]
        } on error {result} {
            puts ""
            throw FATAL [outdent "
                Error running tests for: $target
                --> $result

                Use 'quill -verbose test' or 'quill test $target'
                to see the details.
            "]
        }

        lassign [FilterOutput $target $output] status filtered

        if {$vflag} {
            puts $output
        } else {
            puts $filtered
        }

        return $status
    }

    # FilterOutput target output
    #
    # target   - The test target
    # output   - The output from running the tests.
    #
    # Filters the output, showing only the results, and determines the
    # status along the way.  Returns a list, {$status $results}

    proc FilterOutput {target output} {
        set failures 0

        set filtered [list]

        set lines [split $output \n]
        foreach line $lines {
            if {[string match "Test file error:*" $line]} {
                throw FATAL $line
            }

            if {![string match "all_tests.test:*" $line]} {
                continue
            }

            # Got results line.
            set failures [lindex $line end]

            set leader [format "%-15s" $target:]
            regsub {^all_tests\.test\:} $line $leader line
            lappend filtered $line
        }

        return [list [expr {$failures == 0}] [join $filtered \n]]
    }

    #---------------------------------------------------------------------
    # Running Individual Tests

    # runtest target module ?options...?
    #
    # target   - The test target directory
    # module   - The specific module, or "" for "all_tests"
    # options  - Options to be passed to tcltest(n)
    #
    # Runs the desired test(s), writing the results to the console in 
    # real time.  Returns no status.

    typemethod runtest {target module args} {
        # FIRST, get the module
        if {$module eq ""} {
            set module "all_tests"
        }

        set fname [project root test $target $module.test]

        if {![file isfile $fname]} {
            throw FATAL "Cannot find '$module.test'."
        }

        RunTestRealTime $fname $args
    }

    #---------------------------------------------------------------------
    # Helpers

    # RunTestRealTime testfile ?optlist?
    #
    # testfile - The test file to run
    # optlist  - tcltest(n) option list
    #
    # Runs the desired test file, writing the results to the console in 
    # real time.  Returns no status.

    proc RunTestRealTime {testfile {optlist ""}} {
        # FIRST, prepare the environment.
        set ::env(TCLLIBPATH) [project libpath]

        # NEXT, run the tests.
        cd [project root test [file dirname $testfile]]
        set cmd [list [env pathto tclsh] $testfile {*}$optlist]

        try {
            exec {*}$cmd >@ stdout 2>@ stderr
        } on error {result} {
            throw FATAL "Error running tests: $result"
        }
    }


}

