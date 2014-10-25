#-------------------------------------------------------------------------
# TITLE: 
#    teacup.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    Proxy module for the "teacup" application.  It is intended that other
#    modules call this proxy rather than calling "teacup" directly.
# 
#    Most "teacup" subcommands map closely to "teacup.exe"'s subcommands,
#    while doing clean-up on the data types.
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Namespace Export

namespace eval ::app_quill:: {
    namespace export \
        teacup
} 

#-------------------------------------------------------------------------
# teacup proxy

snit::type ::app_quill::teacup {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #---------------------------------------------------------------------
    # Type Variables

    # goodbuild  - Versions prior to 298288 are known to have caused
    #              problems for Quill.
    
    typevariable goodbuild 298288

    #---------------------------------------------------------------------
    # Teapot Queries


    # checkbuild
    #
    # Checks the build number of the selected teacup executable.

    typemethod checkbuild {} {
        if {[env pathto teacup] eq ""} {
            # We can't have any trouble until we actually have
            # a teacup.
            return
        }

        set verstring [string trim [call version]]
        set buildnum [lindex [split $verstring .] end]

        if {$buildnum < $goodbuild} {
            puts [outdent "
                WARNING: You may be using an out-of-date 'teacup'.
                You should update it by executing 'teacup update-self'
                at the command line.  (You might need to use sudo).
            "]
        }
    }

    # create teapot
    #
    # teapot   - Path to a local teapot.
    #
    # Creates a local teapot at the given location, making sure the
    # parent directory exists.

    typemethod create {teapot} {
        file mkdir [file dirname $teapot]
        call create $teapot
    }

    # default ?teapot?
    #
    # teapot   - Path to the default local teapot.
    #
    # Returns the complete path to the default teapot.  If a new
    # directory is given, makes that the default teapot.

    typemethod default {{teapot ""}} {
        if {$teapot eq ""} {
            return [file normalize [call default]]
        }

        call default $teapot

        return [file normalize $teapot]
    }

    # getkit name version platform
    #
    # name     - basekit package name
    # version  - basekit version
    # platform - basekit platform
    #
    # Retrieves the specified basekit and puts it
    # in the $appdata/basekits directory.

    typemethod getkit {name version platform} {
        puts "Retrieving basekit $name $version $platform from teapot"
        call get --is application --output [env appdata basekits] \
            $name $version $platform
    }

    # ver    - A version number
    #
    # Installs the specified package from the default teapot;
    # logs errors to the console.

    typemethod install {pkg ver} {
        call install $pkg $ver
    }

    # installfile pkgfile
    #
    # pkgfile   - A teapot package file
    #
    # Installs the pkgfile into the local teapot.

    typemethod installfile {pkgfile} {
        call install $pkgfile
    }

    # installed pkg ver
    #
    # pkg   - A package name
    # ver   - A version string
    #
    # Returns 1 if the named package is installed in the local
    # repository, and 0 otherwise.

    typemethod installed {pkg ver} {
        set items [$type list --at-default --is package $pkg]

        foreach item $items {
            set p [dict get $item name]
            set v [dict get $item version]

            if {$pkg eq $p && [package vsatisfies $v $ver]} {
                return 1
            }
        }

        return 0
    }

    # link args...
    #
    # Pass through to 'teacup link'

    typemethod link {args} {
        call link {*}$args
    }

    # list args...
    #
    # Calls "teacup list --as csv" with the other arguments, and
    # converts the result into a list of dictionaries.

    typemethod list {args} {
        set output [call list --as csv {*}$args]

        # Get the column headers
        set lines [split $output \n]
        set headers [split [lshift lines] ,]

        set result [list]

        foreach line $lines {
            set values [split $line ,]
            lappend result [interleave $headers [split $line ,]]
        }

        return $result
    }

    # remove pkg ?ver?
    #
    # pkg    - a package name
    # ?ver?  - A version number
    #
    # Removes the specified package from the default teapot.
    # Logs the removal to the console.

    typemethod remove {pkg {ver ""}} {
        # FIRST, if they want them all gone, remove all of them.
        if {$ver eq ""} {
            call remove --is package $pkg >@ stdout
        }

        # NEXT, if they want all matching a version spec, we need to
        # do more work.  By default, teacup will only remove exact
        # matches.
        foreach item [$type list --at-default --is package $pkg] {
            set p [dict get $item name]
            set v [dict get $item version]

            if {$p eq $pkg && [package vsatisfies $v $ver]} {
                puts [call remove --is package $p $v >@ stdout]
            }
        }
    }

    # repos
    #
    # Returns a list of the teapot repositories linked to the 
    # active tclsh, with the primary repo first.

    typemethod repos {} {
        set repos [list [env pathof teapot]]

        set out [$type link info [env pathto tclsh -require]]

        set len [string length "Repository "]
        foreach line [split $out \n] {
            if {[string match "Repository *" $line]} {
                ladd repos [file normalize [string range $line $len end]]
            }
        }

        return $repos
    }

    #---------------------------------------------------------------------
    # Calling the teacup executable

    # call sub ?args...?
    #
    # sub   - The teacup subcommand
    # args  - The teacup arguments
    #
    # Calls teacup.exe and returns the result.  [exec] redirection
    # options can be included in the args.
    #
    # Throws FATAL if the teacup.exe cannot be found; other errors
    # propagate normally.

    proc call {sub args} {
        set teacup [env pathto teacup -require]
        return [exec $teacup $sub {*}$args]
    }

}

