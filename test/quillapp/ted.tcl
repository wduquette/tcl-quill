#-------------------------------------------------------------------------
# TITLE:
#    ted.tcl
#
# AUTHOR:
#    Will Duquette
#
# DESCRIPTION:
#    Test Execution Deputy: Quill app test harness
#
# TODO: This isn't even close to being right yet.

snit::type ted {
    pragma -hasinstances no -hastypedestroy no

    #---------------------------------------------------------------------
    # Type Variables

    # info - Info array
    #
    # pwd - The test directory

    typevariable info -array {
        pwd ""
    }

    #---------------------------------------------------------------------
    # Type Methods

    # init
    #
    # Prepares to support a set of tests.

    typemethod init {} {
        set info(pwd) [pwd]
    }

    # root args...
    #
    # Returns the test directory with components added.

    typemethod root {args} {
        return [file join $info(pwd) myproj {*}$args]
    }

    # makeproj ?tbd...?
    #
    # Makes a new project within the test directory, for tests to run in.

    typemethod makeproj {} {
        project testinit
        ::quillapp::appTree myproj myapp
    }

    typemethod cleanup {} {
        cd $info(pwd)
        tcltest::removeDirectory myproj
    }
}