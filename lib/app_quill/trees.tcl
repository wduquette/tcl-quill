#-------------------------------------------------------------------------
# TITLE: 
#    trees.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project build system for Tcl/TK
#
# DESCRIPTION:
#    Standard Project Tree elements
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Application Project Skeleton

::app_quill::element deftree app {
    description "Application Project Skeleton"
    argspec     {1 1 <app>}
} {
    The "app" tree type creates a project tree skeleton for a Tcl
    application given a project name and an application name.

    The project name is used as the directory name for the root of the 
    project tree.  The application name is used as the name of the
    application loader file and the application package,

       <project>/bin/<app>.tcl
       <project>/lib/app_<app>/...
       <project>/test/app_<app>/... 
} {
    # TODO: other application options, to pass through to project.quill.
    typemethod add {project app} {
        prepare app -required -file

        # FIRST, begin to set up the project.quill content.
        gentree project.quill [::qfile::project.quill $project]
        project loadinfo

        metadata homepage http://home.page.url

        # NEXT, add the application skeleton
        fileset app $app

        # NEXT, add boilerplate.
        write README.md              [::qfile::README.md]
        write LICENSE                [::qfile::LICENSE]
        write docs/index.quilldoc    [::qfile::index.quilldoc]
        write docs/release.md        [::qfile::release.md]
        write docs/man1/$app.manpage [::qfile::man1.manpage $app]
        write lib/quillinfo/pkgIndex.tcl   [::qfile::quillinfoPkgIndex]
        write lib/quillinfo/pkgModules.tcl [::qfile::quillinfoPkgModules]
        write lib/quillinfo/quillinfo.tcl  [::qfile::quillinfo.tcl]

        # NEXT, complete the project.quill content.
        set tclVersion [env versionof tclsh]

        if {$tclVersion eq ""} {
            set tclVersion $::tcl_version
        }

        metadata require Tcl $tclVersion
        metadata dist install \
{
    %apps
    docs/*.html
    docs/man*/*.html
    README.md
    LICENSE
}
    }
}

#-------------------------------------------------------------------------
# Library Project Skeleton

::app_quill::element deftree lib {
    description "Library Project Skeleton"
    argspec     {1 1 <lib>}
} {
    The "lib" tree type creates a project tree skeleton for a Tcl
    library package given a project name and a library name.

    The project name is used as the directory name for the root of the 
    project tree.  The library name is used as the name of the
    the library package,

       <project>/lib/<lib>/...
       <project>/test/<lib>/... 
} {
    typemethod add {project lib} {
        prepare lib -required -file

        # FIRST, begin to set up the project.quill content.
        gentree project.quill [::qfile::project.quill $project]
        project loadinfo

        metadata homepage http://home.page.url

        # NEXT, add the liblication skeleton
        fileset package $lib

        # NEXT, add boilerplate.
        write README.md              [::qfile::README.md]
        write LICENSE                [::qfile::LICENSE]
        write docs/index.quilldoc    [::qfile::index.quilldoc]
        write docs/release.md        [::qfile::release.md]
        write docs/mann/$lib.manpage [::qfile::mann.manpage $lib]

        # NEXT, complete the project.quill content.
        set tclVersion [env versionof tclsh]

        if {$tclVersion eq ""} {
            set tclVersion $::tcl_version
        }

        metadata require Tcl $tclVersion
        metadata dist install \
{
    %libs
    docs/*.html
    docs/man*/*.html
    README.md
    LICENSE
}
    }
}

