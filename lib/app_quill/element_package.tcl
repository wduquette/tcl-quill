#-------------------------------------------------------------------------
# TITLE: 
#    element_package.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project build system for Tcl/TK
#
# DESCRIPTION:
#    Project Element: package skeleton
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# package Templates

::app_quill::element public package {package} 1 1 \
     ::app_quill::packageElement

# package package mainflag
#
# package - The package name
# mainflag - If true, generate a "main" procedure
# 
# Saves the package element tree.

proc ::app_quill::packageElement {package {mainflag 0}} {
    gentree \
        lib/$package/pkgIndex.tcl    [::qfile::pkgIndex.tcl $package]   \
        test/$package/all_tests.test [::qfile::all_tests.test $package] \
        test/$package/$package.test  [::qfile::testfile.test $package]

    if {$mainflag} {
        gentree \
            lib/$package/pkgModules.tcl [::qfile::pkgModules.tcl $package main]  \
            lib/$package/main.tcl       [::qfile::main.tcl $package]
    } else {
        gentree \
            lib/$package/pkgModules.tcl [::qfile::pkgModules.tcl $package]  \
            lib/$package/$package.tcl   [::qfile::module.tcl $package]
    }
}

