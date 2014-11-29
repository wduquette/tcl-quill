#-------------------------------------------------------------------------
# TITLE: 
#    filesets.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project build system for Tcl/TK
#
# DESCRIPTION:
#    File Set elements
#-------------------------------------------------------------------------

::app_quill::element defset app {
    description "Application Skeleton"
    argspec     {1 1 <app>}
} {
    This element creates a new application skeleton: the loader script,
    the application implementation package, and the implementation
    package's test target.
} {
    # TODO: other application options, to pass through to project.quill.
    typemethod add {app} {
        prepare app -required -file

        fileset package app_$app main

        write bin/$app.tcl           [::qfile::app.tcl $app]
        write docs/man1/$app.manpage [::qfile::man1.manpage $app]

        if {![file exists [project root lib quillinfo]]} {
            write lib/quillinfo/pkgIndex.tcl   [::qfile::quillinfoPkgIndex]
            write lib/quillinfo/pkgModules.tcl [::qfile::quillinfoPkgModules]
            write lib/quillinfo/quillinfo.tcl  [::qfile::quillinfo.tcl]
        }

        queue os setexecutable [project root bin $app.tcl]

        metadata app $app
    }
}

::app_quill::element defset package {
    description "Library Package Skeleton"
    argspec     {1 2 "<package> ?<module>?"}
} {
    This element creates a library package skeleton.
} {
    # TODO: other package options, to pass through to project.quill.

    typemethod add {package {module ""}} {
        prepare package -required -file
        prepare module  -file

        if {$module eq ""} {
            set module $package
        }

        fileset testtarget $package

        write lib/$package/pkgIndex.tcl   [::qfile::pkgIndex.tcl $package]
        write lib/$package/pkgModules.tcl [::qfile::pkgModules.tcl $package $module]

        # TODO: Possibly, this should be two distinct file sets, one for 
        # applications and one for normal library packages.
        if {$module eq "main"} {
            write lib/$package/main.tcl     [::qfile::main.tcl $package]
        } else {
            write lib/$package/$module.tcl [::qfile::module.tcl $module]

            metadata provide $package
        }
    }
}

::app_quill::element defset testtarget {
    description "Test target directory"
    argspec     {1 1 <target>}
} {
    This element creates a single test target directory called <target>.
    It will contain two files, all_tests.test and <target>.test.
} {
    # add target
    # 
    # target   - The test target directory name
    #
    # Tries to add the element to the current project.  
    #
    # TODO: Provide some commands for use in element code.  element::
    # procs imported into the element singleton.
    #
    #     write filepath content
    #          Queues the file to be written.
    #     queue command...
    #          Queues a command to be called after the files are written.

    typemethod add {target} {
        # FIRST, validate the input.
        prepare target -required -file

        # NEXT, create the new element
        write test/$target/all_tests.test [::qfile::all_tests.test $target]
        write test/$target/$target.test   [::qfile::testfile.test $target]

        return
    }
}

