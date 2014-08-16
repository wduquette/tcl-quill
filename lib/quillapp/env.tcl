#-------------------------------------------------------------------------
# TITLE: 
#    plat.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    env(n): Development environment proxy.
#
#    This module is the one that understands and manages the development
#    environment in which Quill executes.
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Namespace exports

namespace eval ::quillapp:: {
    namespace export env
}

#-------------------------------------------------------------------------
# env singleton

snit::type ::quillapp::env {
    pragma -hasinstances no -hastypedestroy no

    #---------------------------------------------------------------------
    # TBD: We'll move stuff over from plat little by little.  When we've
    # got it divided the way we want, this block will vanish.

    typecomponent plat

    typeconstructor {
        set plat ::quillapp::plat
    }

    #---------------------------------------------------------------------
    # TBD

    # pathto *

}