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

app_quill::tool define test {
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
            # FIRST, are there any test targets?
            set count 0
            foreach dir [glob -nocomplain [project root test *]] {
                if {[file isdirectory $dir]} {
                    incr count
                }
            }

            if {$count == 0} {
                throw FATAL \
                    "No test targets found in [project root test]."
            }

            # NEXT, we summarize unless -verbose.
            if {[app_quill::verbose]} {
                tester runall realtime
            } else {
                puts [outdent {
                    Summarizing test results.  Use 'quill -verbose test'
                    to see the details.
                }]
                puts ""
                tester runall quiet
            }
            return
        } else {
            if {![file isdirectory [project root test $target]]} {
                throw FATAL "'$target' is not a valid test target."
            }

            tester runtest $target $module {*}$argv
        }
    }

    #---------------------------------------------------------------------
    # Helpers

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

