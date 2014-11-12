#-------------------------------------------------------------------------
# TITLE: 
#    elementx_testtarget.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project build system for Tcl/TK
#
# DESCRIPTION:
#    Project Element: test target directory
#
# TODO:
#    During validation, we retrieve the file paths and their contents,
#    which derive from the element args.  We can then check whether we 
#    are overwriting anything.  If we are not, or if -force is given,
#    then the parent module can save the files.  But there may be
#    project metadata changes.  How do we avoid parsing the element 
#    parameters twice?
#
#-------------------------------------------------------------------------

::app_quill::elementx define testtarget {
    description "Test target directory"
    tree        0
    argspec     {1 1 target}
} {
This element creates a single test target directory called <target>.
It will contain two files, all_tests.test and <target>.test.
} {
    # expand target
    # 
    # target   - The test target directory name
    #
    # Returns the expanded element as a dictionary with this structure:
    #
    #   files => specifications of file paths and contents
    #         -> $filepath => A file path
    #                      -> $content => The text to go in the file
    #   metadata => specification of metadata changes
    #            -> $list => list of [project add] commands.

    typemethod expand {target} {
        set result [dict create files {} metadata {}]

        into result test/$target/all_tests.test [AllTests $target]
        into result test/$target/$target.tcl    [TestFile $target]
    }
}

# allTests package
#
# all_tests.test file for the $package(n) package.

maptemplate ::app_quill::elementx::TESTTARGET::AllTests {package} {
    set project     [project name]
    set description [project description]
} {
    #-------------------------------------------------------------------------
    # TITLE:
    #    all_tests.test
    #
    # PROJECT:
    #    %project: %description
    #
    # DESCRIPTION:
    #    %package(n): Test Suite
    #-------------------------------------------------------------------------

    #-------------------------------------------------------------------------
    # Load the tcltest package

    if {[lsearch [namespace children] ::tcltest] == -1} {
        package require tcltest 2.3
        eval ::tcltest::configure $argv
    }

    ::tcltest::configure \
        -testdir [file dirname [file normalize [info script]]] \
        -notfile all_tests.test

    ::tcltest::runAllTests
}

# testFile package
#
# $package.test file for the $package(n) package.

maptemplate ::app_quill::elementx::TESTTARGET::TestFile {package} {
    set project     [project name]
    set description [project description]
} {
    #-------------------------------------------------------------------------
    # TITLE:
    #    %package.test
    #
    # PROJECT:
    #    %project: %description
    #
    # DESCRIPTION:
    #    %package(n): Test Suite
    #-------------------------------------------------------------------------

    #-------------------------------------------------------------------------
    # Load the tcltest package

    if {[lsearch [namespace children] ::tcltest] == -1} {
        package require tcltest 2.3
        eval ::tcltest::configure $argv
    }

    namespace import ::tcltest::test

    #-------------------------------------------------------------------------
    # Load the package to be tested

    source ../../lib/%package/pkgModules.tcl
    namespace import ::%package::*

    #-------------------------------------------------------------------------
    # Setup

    # TBD

    #-------------------------------------------------------------------------
    # dummy

    test dummy-1.1 {dummy test} -body {
        set a false
    } -result {true}

    #-------------------------------------------------------------------------
    # Cleanup

    ::tcltest::cleanupTests
}
