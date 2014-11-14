#-------------------------------------------------------------------------
# TITLE: 
#    tree_app.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project build system for Tcl/TK
#
# DESCRIPTION:
#    Project Tree: "app" project
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Quillinfo Templates

::app_quill::tree register app {project appname} 2 2 ::app_quill::appTree {
    The "app" tree type creates a project tree skeleton for a Tcl
    application given a project name and an application name.

    The project name is used as the directory name for the root of the 
    project tree.  The application name is used as the name of the
    application loader file and the application package,

       <project>/bin/<appname>.tcl
       <project>/lib/app_<appname>/...
       <project>/test/app_<appname>/... 
}

# appTree project appname
#
# Saves the creates the "app" project tree
#
# TODO: Should save project.quill, cd to project directory, loadinfo,
# and then use default project.quill contents for everything that follows.
# That way, elements can rely on [project *] as well as arguments.

proc ::app_quill::appTree {project appname} {
    set proot [file join [pwd] $project]

    puts "Creating an \"app\" tree at $proot/..."

    # FIRST, bootstrap the project file.
    project newroot $proot
    gentree project.quill [projectQuill $project $appname]
    project loadinfo

    # NEXT, create files and elements.
    gentree README.md           [::qfile::README.md]     \
            docs/index.quilldoc [::qfile::index.quilldoc]
    element quillinfo
    element app $appname
}

# projectQuill
#
# Default project.quill file for an "app" project.
# TODO: for -exetype exe, the dist should be "install-%platform".

maptemplate ::app_quill::projectQuill {project appname} {
    set tclversion [env versionof tclsh]

    if {$tclversion eq ""} {
        set tclversion $::tcl_version
    }
} {
    project %project 0.0a0 "Your project description"
    homepage http://home.page.url
    app %appname
    require Tcl %tclversion

    dist install {
        %apps
        docs/*.html
        docs/man*/*.html
        README.md
        LICENSE
    }
}

