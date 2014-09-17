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
    # testdir  - The test directory
    # root     - The fake project directory

    typevariable info -array {
        testdir ""
        root    ""
    }

    #---------------------------------------------------------------------
    # Type Methods

    # init
    #
    # Prepares to support a set of tests.

    typemethod init {} {
        set info(testdir) [pwd]
        set info(root)    [file join $info(testdir) myproj]

        # set up quillapp::project::info
        set ::quillapp::project::info(intree) 1
        set ::quillapp::project::info(root)   $info(root)
    }

    # root args...
    #
    # Returns the fake project root directory with components added.

    typemethod root {args} {
        return [file join $info(root) {*}$args]
    }

    typemethod makeproj {} {
        tcltest::makeDirectory myproj
    }

    typemethod cleanup {} {
        cd $info(testdir)
        tcltest::removeDirectory myproj
    }
}