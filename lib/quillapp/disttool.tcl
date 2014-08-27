#-------------------------------------------------------------------------
# TITLE: 
#    disttool.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    "quill dist" tool implementation.  This tool builds distribution
#    files.
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Register the tool

set ::quillapp::tools(dist) {
    command     "dist"
    description "Build distribution .zip files"
    argspec     {0 1 "?<name>?"}
    intree      true
    ensemble    ::quillapp::disttool
}

set ::quillapp::help(dist) {
    The "quill dist" tool builds distribution .zip files based on the
    distributions defined in the project's project.quill file.  See
    quill(5) for the details on how to define a distribution.

    quill dist ?<name>?
        By default, builds all of the distribution files.  Optionally,
        builds the named distribution.
}

#-------------------------------------------------------------------------
# Namespace Export

namespace eval ::quillapp:: {
    namespace export \
        disttool
} 

#-------------------------------------------------------------------------
# Tool Singleton: disttool

snit::type ::quillapp::disttool {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    # execute argv
    #
    # argv - command line arguments for this tool
    # 
    # Executes the tool given the arguments.

    typemethod execute {argv} {
        if {[llength $argv] == 1} {
            set dists [list [lindex $argv 0]]
        } else {
            set dists [project dist names]
        }

        foreach dist $dists {
            if {$dist ni [project dist names]} {
                throw FATAL "Unknown distribution: \"$dist\""
            }

            MakeDist $dist
        }
    }

    # MakeDist dist
    #
    # dist  - A distribution name.
    #
    # Builds the dictionary of distribution files, and makes the zip.

    proc MakeDist {dist} {
        set fdict [dict create]

        foreach pattern [project dist patterns $dist] {
            if {$pattern eq "%libs"} {
                set fdict [dict merge $fdict [GetLibZips]]
            } else {
                set fdict [dict merge $fdict [GetGlobFiles $pattern]]
            }
        }

        set zipfile "[project name]-[project version]-$dist.zip"
        set ziproot [project name]

        puts "Making $zipfile..."
        MakeZip $zipfile $ziproot $fdict
    }

    # GetLibZips
    #
    # Retrieves the provides library .zip files and puts them in the
    # root.
    #
    # TODO: If there aren't project queries for these names and 
    # directories, there should be.

    proc GetLibZips {} {
        set result [dict create]

        foreach name [project provide names] {
            set zfile "package-$name-[project version]-tcl.zip"
            set dfile [project root .quill teapot $zfile]

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

