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

::app_quill::elementx define app {
    description "Application Skeleton"
    tree        0
    argspec     {1 1 app}
} {
    This element creates a new application skeleton: the loader script,
    the application implementation package, and the implementation
    package's test target.
} {
    typemethod add {app} {
        prepare app -required -file

        fileset package app_$app main

        write bin/$app.tcl           [::qfile::app.tcl $app]
        write docs/man1/$app.manpage [::qfile::man1.manpage $app]

        queue os setexecutable [project root bin $app.tcl]
    }
}

::app_quill::elementx define package {
    description "Library Package Skeleton"
    tree        0
    argspec     {1 2 "package ?module?"}
} {
    This element creates a library package skeleton.
} {
    typemethod add {package {module ""}} {
        prepare package -required -file
        prepare module  -file

        if {$module eq ""} {
            set module $package
        }

        fileset testtarget $package

        write lib/$package/pkgIndex.tcl   [::qfile::pkgIndex.tcl $package]
        write lib/$package/pkgModules.tcl [::qfile::pkgModules.tcl $package $module]

        if {$module eq "main"} {
            write lib/$package/main.tcl     [::qfile::main.tcl $package]
        } else {
            write lib/$package/$package.tcl [::qfile::module.tcl $package]
        }
    }
}

::app_quill::elementx define quillinfo {
    description "quillinfo(n) Library Template"
    tree        0
    argspec     {0 0 ""}
} {
    This element creates a quillinfo library.
} {
    typemethod add {} {
        write lib/quillinfo/pkgIndex.tcl   [::qfile::quillinfoPkgIndex]
        write lib/quillinfo/pkgModules.tcl [::qfile::quillinfoPkgModules]
        write lib/quillinfo/quillinfo.tcl  [::qfile::quillinfo.tcl]
    }
}

::app_quill::elementx define testtarget {
    description "Test target directory"
    tree        0
    argspec     {1 1 target}
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
    # TODO: Provide some commands for use in elementx code.  elementx::
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