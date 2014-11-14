#-------------------------------------------------------------------------
# TITLE: 
#    element_quillinfo.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project build system for Tcl/TK
#
# DESCRIPTION:
#    Project Element: quillinfo(n) package
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Quillinfo Templates

::app_quill::element private quillinfo ::app_quill::quillinfoElement

# quillinfo
#
# Saves the quillinfo element tree.

proc ::app_quill::quillinfoElement {} {
    gentree \
        lib/quillinfo/pkgIndex.tcl   [::qfile::quillinfoPkgIndex]   \
        lib/quillinfo/pkgModules.tcl [::qfile::quillinfoPkgModules] \
        lib/quillinfo/quillinfo.tcl  [::qfile::quillinfo.tcl]
}

