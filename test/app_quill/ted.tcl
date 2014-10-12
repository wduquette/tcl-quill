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

        # set up environment variables for testing.
        set ::env(QUILL_APP_DATA) [file join $info(testdir) appdata]

        # set up app_quill::project::info
        set ::app_quill::project::info(intree) 1
        set ::app_quill::project::info(root)   $info(root)
    }

    # root args...
    #
    # Returns the fake project root directory with components added.

    typemethod root {args} {
        return [file join $info(root) {*}$args]
    }

    # makeproj
    #
    # Makes an empty project tree
    typemethod makeproj {} {
        tcltest::makeDirectory myproj
    }

    # config script
    #
    # Creates a quill.config file in the appdata directory given
    # the script.

    typemethod config {script} {
        tcltest::makeFile $script \
            [file join appdata quill.config]
    }

    # makeappdata
    #
    # Makes an empty appdata directory
    typemethod makeappdata {} {
        tcltest::makeDirectory appdata
    }

    # cleanup
    #
    # Cleanup after all test fixtures.

    typemethod cleanup {} {
        # Test Variables
        cd $info(testdir)

        # Modules
        config cleanup

        # Test Directories
        tcltest::removeDirectory myproj
        tcltest::removeDirectory appdata
    }
}