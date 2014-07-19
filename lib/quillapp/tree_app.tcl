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

::quillapp::tree register app {project appname} 2 2 ::quillapp::appTree {
    The "app" tree type creates a project tree skeleton for a Tcl
    application given a project name and an application name.

    The project name is used as the directory name for the root of the 
    project tree.  The application name is used as the name of the
    application loader file and the application package,

       <project>/bin/<appname>.tcl
       <project>/lib/<appname>/... 
}

# appTree project appname
#
# Saves the creates the "app" project tree

proc ::quillapp::appTree {project appname} {
    puts "Creating an \"app\" tree at"
    puts "[file join [pwd] $project]/..."

    project newroot $project

    gentree \
        project.quill [projectQuill $project $appname] 

}

# projectQuill
#
# pkgIndex.tcl file for the quillinfo(n) package.

maptemplate ::quillapp::projectQuill {project appname} {
    project %project 0.0a0 "Your project description"
    homepage http://home.page.url
    app %appname
}

