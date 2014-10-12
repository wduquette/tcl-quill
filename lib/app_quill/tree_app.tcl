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
    gentree README.md        [projectREADME] \
            docs/index.html  [projectDocsIndex]
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

# projectREADME
#
# Default README.md file for a Quill project.

maptemplate ::app_quill::projectREADME {} {
    set project [project name]
} {
    # %project

    A description of your new project.
}

# projectDocsIndex
#
# Default index.html file for the project documentation.

maptemplate ::app_quill::projectDocsIndex {} {
    set project     [project name]
    set description [project description]
} {
    <html>
    <head>
    <title>%project Documentation</title>
    <style>
    <!--
        /* Links should be displayed with no underline */
        :link {
            text-decoration: none;
        }

        :visited {
            text-decoration: none;
        }

        /* Body is black on white, and indented. */
        body {
            color: black;
            background-color: white;
            margin-left: 0.5in;
            margin-right: 0.5in;
        }

        /* For the page header */
        h1.header {
            position: relative;
            left: -0.4in;
            background-color: red;
            color: black;
        }

        /* The title and section headers are outdented. */
        h1 {
            position: relative;
            left: -0.4in;
        }

        h2 {
            position: relative;
            left: -0.4in;
        }

        /* Preformatted text has a special background */
        pre {
            border: 1px solid blue;
            background-color: #FFFF66;
            padding: 2px;
        }

        /* Use for indenting */
        .indent0 { }
        .indent1 {
            position: relative;
            left: 0.4in
        }
        .indent2 {
            position: relative;
            left: 0.8in
        }
        .indent3 {
            position: relative;
            left: 1.2in
        }
        .indent4 {
            position: relative;
            left: 1.6in
        }
        .indent5 {
            position: relative;
            left: 2.0in
        }
        .indent6 {
            position: relative;
            left: 2.4in
        }
        .indent7 {
            position: relative;
            left: 2.8in
        }
        .indent8 {
            position: relative;
            left: 3.2in
        }
        .indent9 {
            position: relative;
            left: 3.6in
        }

        /* Outdent to margin */
        .outdent {
            position: relative;
            left: -0.4in;
        }
    -->
    </style>
    </head>
    <body>
    <h1 class="header">%project Documentation</h1>

    <h1>General Documents</h1>

    TBD<p>

    <h1>Man Pages</h1>

    <ul>
    <li><a href="man1/index.html">Section (1): Applications</a>
    <li><a href="man5/index.html">Section (5): File Formats</a>
    <li><a href="mann/index.html">Section (n): Tcl Packages</a>
    <li><a href="mani/index.html">Section (i): Tcl Interfaces</a>
    </ul><p>

    </body>
    </html>

}