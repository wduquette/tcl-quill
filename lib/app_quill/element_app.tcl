#-------------------------------------------------------------------------
# TITLE: 
#    element_app.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project build system for Tcl/TK
#
# DESCRIPTION:
#    Project Element: app element.
#    
#    This element defines the components of an application:
#
#    * Loader Script
#    * Implementation Package
#    * Implementation Package Test Suite
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Apploader Templates

::app_quill::element public app {appname} 1 1 \
     ::app_quill::appElement

# appElement appname
#
# appname - The application name
# 
# Saves the app element files.

proc ::app_quill::appElement {app} {
    gentree bin/$app.tcl           [::qfile::app.tcl $app]  \
            docs/man1/$app.manpage [::qfile::man1.manpage $app]

    os setexecutable [project root bin $app.tcl]

    element package app_$app true
}

