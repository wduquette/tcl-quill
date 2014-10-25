#-------------------------------------------------------------------------
# TITLE: 
#    dist.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    Distribution Set Creation Module
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Namespace Export

namespace eval ::app_quill:: {
    namespace export \
        dist
} 

#-------------------------------------------------------------------------
# teacup proxy

snit::type ::app_quill::dist {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    # make dist ?plat?
    #
    # dist  - A distribution name.
    # plat  - A platform string
    #
    # Builds the zip file for the named distribution.

    typemethod make {dist {plat ""}} {
        # FIRST, get the platform.
        if {$plat eq ""} {
            set plat [platform::identify]
        }


        # NEXT, build the dictionary of files to include.
        set fdict [dict create]

        foreach pattern [project dist patterns $dist] {
            if {$pattern eq "%apps"} {
                set fdict [dict merge $fdict [GetAppFiles $plat]]
            } elseif {$pattern eq "%libs"} {
                set fdict [dict merge $fdict [GetLibZips]]
            } else {
                set fdict [dict merge $fdict [GetGlobFiles $pattern]]
            }
        }

        set xdist [project dist expand $dist $plat]

        set zipfile "[project name]-[project version]-$xdist.zip"
        set ziproot [project name]

        puts "Making $zipfile..."
        MakeZip $zipfile $ziproot $fdict
    }

    # GetAppFiles
    #
    # plat - The platform on which we're working.
    #
    # Retrieves the file names for the provided applications.

    proc GetAppFiles {plat} {
        set result [dict create]

        foreach name [project app names] {
            set base [project app exename $name $plat]
            set zfile "bin/$base"
            set dfile [project root bin $base]

            dict set result $zfile $dfile
        }

        return $result
    }

    # GetLibZips
    #
    # Retrieves the provided library .zip files and puts them in the
    # root.
    #
    # TODO: There should be a query for the libzip directory.

    proc GetLibZips {} {
        set result [dict create]

        foreach name [project provide names] {
            set zipname [project provide zipfile $name]
            set zfile "lib/$zipname"
            set dfile [project root .quill teapot $zipname]

            dict set result $zfile $dfile
        }

        return $result
    }

    # GetGlobFiles pattern
    #
    # Retrieves files in the project tree given the glob pattern.

    proc GetGlobFiles {pattern} {
        set pattern [project root $pattern]
        set prelen [string length [project root]]
        set result [dict create]

        foreach dfile [glob -nocomplain $pattern] {
            if {![file isfile $dfile]} {
                continue
            }

            set zfile [string range $dfile $prelen+1 end]
            dict set result $zfile $dfile
        }

        return $result
    }


    # MakeZip zipfile ziproot filedict
    #
    # zipfile   - The output file name.
    # ziproot   - The root directory in the .zip file, or "" for none.
    # filedict  - A dictionary from zip file names to disk file names
    #
    # Creates a .zip file called $zipfile.  It will contain the files
    # given by the values in the $filedict.  The paths in the zipfile
    # will be the ziproot joined to the keys in the $filedict.

    proc MakeZip {zipfile ziproot filedict} {
        set zipper [zipfile::encode %AUTO%]

        try {
            dict for {zfile dfile} $filedict {
                if {$ziproot ne ""} {
                    set zfile [file join $ziproot $zfile]
                }

                $zipper file: $zfile 0 $dfile
            }

            $zipper write $zipfile
        } finally {
            rename $zipper ""
        }
    
    }    
}

