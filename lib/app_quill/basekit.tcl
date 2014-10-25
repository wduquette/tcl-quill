#-------------------------------------------------------------------------
# TITLE: 
#    basekit.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    Basekit manager type, for use by various tools.
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Namespace Export

namespace eval ::app_quill:: {
    namespace export \
        basekit
} 

#-------------------------------------------------------------------------
# teacup proxy

snit::type ::app_quill::basekit {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #---------------------------------------------------------------------
    # Available Basekits

    # table ver ?options...?
    #
    # ver  - Requested Tcl version
    # 
    # Options:
    #    -source src     - "local", "web", or "all".  "all" is default.
    #
    # Returns a table of the available basekits at 
    # teapot.activestate.com. Fields include:
    #
    #    name      - The teapot package name, e.g., "base-tcl-thread"
    #    tcltk     - tcl for non-gui, tk for gui
    #    version   - Full version
    #    platform  - platform string
    #    threaded  - yes or no
    #    appname   - The full application file name.
    #    source    - web | local

    typemethod table {ver args} {
        # FIRST, process the command line.
        set ver [verxy $ver]
        set src all

        foroption opt args -all {
            -source   { set src      [lshift args] }
        }

        # NEXT, get the local basekits.
        if {$src in {local all}} {
            set kits [GetLocalBasekits $ver]
        } else {
            set kits [list]
        }

        # NEXT, add the network basekits if desired, skipping those we
        # have locally.
        if {$src in {web all}} {
            foreach kit [GetTeapotBasekits $ver] {
                if {![GotKit $kits $kit]} {
                    lappend kits $kit
                }
            }
        }

        return $kits
    }

    # GotKit kits kit
    #
    # kits    - Table of basekit records
    # kit     - A basekit record
    #
    # Returns 1 if the basekit named in kit is already present in 
    # kits, and 0 otherwise.

    proc GotKit {kits kit} {
        set appname [dict get $kit appname]

        foreach k $kits {
            if {[dict get $k appname] eq $appname} {
                return 1
            }
        }

        return 0
    }

    # GetLocalBasekits ver
    #
    # ver   - Requested Tcl version as X.Y
    #
    # Returns a table of the basekits available locally.
    # The fields are as listed above.

    proc GetLocalBasekits {ver} {
        set pat "application-*-$ver.*"

        set result [list]

        set regexp {^application-(base-(tcl|tk)(-thread)?)-([0-9.]+)-(.+)$}

        foreach fullname [glob -nocomplain [env appdata basekits $pat]] {
            # FIRST, strip off any .exe
            set appname [file tail $fullname]

            if {[file extension $fullname] eq ".exe"} {
                set basename [file rootname $appname]
            } else {
                set basename $appname
            }

            # NEXT, parse the remainder.
            set flag [regexp $regexp $basename dummy \
                        pkgname tcltk thr version platform]

            if {!$flag} {
                puts [outdent "
                    Warning: found basekit with non-canonical name in 
                    local cache:
                    => $fullname
                "]
                continue
            }

            # Save data
            dict set row name     $pkgname
            dict set row version  $version
            dict set row platform $platform
            dict set row tcltk    $tcltk
            dict set row threaded [Threaded? $pkgname]
            dict set row appname  $appname
            dict set row source   local

            lappend result $row
        }

        return $result
    }


    # GetTeapotBasekits ver
    #
    # ver   - Requested Tcl version as X.Y
    #
    # Returns a table of the available basekits at 
    # teapot.activestate.com.  The fields are as listed
    # above.

    proc GetTeapotBasekits {ver} {
        # FIRST, get the list of possibilities
        set results [list]

        foreach kitname {
            base-tcl-thread
            base-tk-thread
            base-tcl
            base-tk
        } {
            # FIRST, get the matching basekits
            set table [teacup list --is application --all-platforms $kitname]

            # NEXT, filter out the ones for the wrong version, and retain
            # the desired data.
            foreach inrow $table {
                set row [dict create]

                dict with inrow {
                    # Filter by version.
                    if {[verxy $version] ne $ver} {
                        continue
                    }

                    # Save data
                    dict set row name     $name
                    dict set row version  $version
                    dict set row platform $platform
                    dict set row tcltk    [TclOrTk $name]
                    dict set row threaded [Threaded? $name]
                    dict set row appname \
                        [os exefile "application-$name-$version-$platform"]
                    dict set row source   web
                }

                lappend results $row
            }
        }

        return $results
    }


    # TclOrTk basekitname
    #
    # Returns "tcl" or "tk" given the basekit name.

    proc TclOrTk {basekitname} {
        if {[string match "base-tk*" $basekitname]} {
            return "tk"
        } else {
            return "tcl"
        }
    }

    # Threaded? basekitname
    #
    # Returns "yes" or "no".

    proc Threaded? {basekitname} {
        if {[string match "*-thread" $basekitname]} {
            return "yes"
        } else {
            return "no"
        }
    }

    #---------------------------------------------------------------------
    # Acquiring Needed Basekit

    # get kdict
    #
    # kdict - A row from a [basekit table] dictable.
    #
    # Retrieves the basekit if it isn't already local and puts it
    # in the $appdata/basekits directory.  Returns the path to the
    # basekit.

    typemethod get {kdict} {
        dict with kdict {}

        if {$source eq "web"} {
            try {
                teacup getkit $name $version $platform
            } on error {result} {
                throw FATAL "Could not retrieve basekit:\n=> $result"
            }
        }

        set fullpath [env appdata basekits $appname]

        if {![file isfile $fullpath]} {
            throw FATAL "Basekit is not available."
        }

        return $fullpath
    }
}

