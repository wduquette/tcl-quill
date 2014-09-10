#-------------------------------------------------------------------------
# TITLE: 
#    os.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    os(n): OS independence layer for Quill.  This module is the
#    one that knows how to do various tasks in an OS-independent
#    way. 
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Namespace exports

namespace eval ::quill:: {
    namespace export os
}

#-------------------------------------------------------------------------
# os singleton

snit::type ::quill::os {
    pragma -hasinstances no -hastypedestroy no


    #---------------------------------------------------------------------
    # OS Identification

    typevariable osNames -array {
        linux   "Linux"  
        osx     "Mac OSX"
        windows "Windows"
    }

    # flavor
    #
    # Returns the OS ID.  Quill doesn't care (at present)
    # about the specifics, but about the broad categories:
    # Windows, Linux, OSX.
    #
    # For now, we will assume that anything that isn't OSX or Windows
    # is sufficiently similar to Linux to make no difference.

    typemethod flavor {} {
        switch -glob -- $::tcl_platform(os) {
            "Darwin"   { return osx     }
            "Windows*" { return windows }
            default    { return linux   }
        }
    }

    # flavors
    #
    # Returns the valid OS flavors.

    typemethod flavors {} {
        return [lsort [array names osNames]]
    }

    # name
    #
    # Returns the OS, pretty printed for output.

    typemethod name {} {
        return $osNames([$type flavor])
    }

    # exefile base
    #
    # base  - The base executable name, e.g., "quill"
    #
    # On Windows, adds ".exe" to the executable.  On other platforms,
    # returns it unchanged.

    typemethod exefile {base} {
        if {[$type flavor] eq "windows"} {
            return $base.exe
        } else {
            return $base
        }
    }

    #---------------------------------------------------------------------
    # User Name

    # username
    #
    # Returns the current user's username, by looking at the environment.

    typemethod username {} {
        set name [GetEnv USER]

        if {$name eq ""} {
            set name [GetEnv USERNAME]
        }

        if {$name eq ""} {
            set name [GetEnv LOGNAME]
        }

        return $name
    }

    #---------------------------------------------------------------------
    # Path Finding Tools

    # pathfind program
    #
    # program  - The name of a program.
    #
    # Given the name of the program, tries to find it on the
    # PATH.  If it is found, returns the normalized path to the
    # program.
    #
    # pathfind makes no OS-specific changes to the name of the program.  
    # If you're on Windows and want an ".exe", ask for it explicitly. 
    #
    # On Windows, we initially assuem that we're using a standard Windows 
    # command shell and that the PATH separator is ";".  If that doesn't
    # work, we try ":".
    #
    # Returns "" if it can't find anything.

    typemethod pathfind {program} {
        global env

        # FIRST, do we have a PATH?  Note that there's no good way
        # to see if PATH is empty on Windows without throwing an error.
        set thePath ""
        catch {set thePath $env(PATH)}
        if {$thePath eq ""} {
            return ""
        }

        # NEXT, split the path using the platform's path separator.
        set dirlist [split $thePath $::tcl_platform(pathSeparator)]

        # NEXT, try to find the file on the path.
        return [FindWith $dirlist $program]
    }

    # FindWith dirlist program
    #
    # dirlist - A list of directories where executables might be found.
    # program - The executable name.
    #
    # Looks for the executable in the directories, and returns the 
    # normalized path to the first match.  If the program is not found,
    # returns ""

    proc FindWith {dirlist program} {
        foreach dir $dirlist {
            set fullname [file join $dir $program]

            if {[file isfile $fullname]} {
                return [file normalize $fullname]
            }
        }

        return ""
    }

    #---------------------------------------------------------------------
    # Path Comparisons

    # pathequal p1 p2
    #
    # p1   - A path, possibly a symlink
    # p2   - A path, possibly a symlink
    #
    # Compares the two paths for equality, returning 1 if equal and
    # 0 otherwise.  If they are not immediately
    # equal, the command follows up to one step of symlinks for each,
    # and tries again.

    typemethod pathequal {p1 p2} {
        if {$p1 eq $p2} {
            return 1
        }

        set p1 [FollowLink $p1]
        set p2 [FollowLink $p2]

        if {$p1 eq $p2} {
            return 1
        } else {
            return 0
        }
    }

    # FollowLink path
    #
    # path   - A path that might be a symlink.
    #
    # If the path is a symlink, follows it back one step and returns
    # the absolute path in normal form.

    proc FollowLink {path} {
        if {![file exists $path]} {
            return [file normalize $path]
        } elseif {[file type $path] ne "link"} {
            return [file normalize $path]
        } else {
            set dir [file dirname $path]
            set link [file link $path]
            return [file normalize [file join $dir $link]]
        }
    }

    #---------------------------------------------------------------------
    # Miscellaneous Operations

    # setexecutable filename
    #
    # filename   - Name of a file that should be executable.
    #
    # Marks the file as executable (or tries to).
    #
    # TODO: Figure out what to do on Windows.  Normally Windows uses
    # the extension, so there might not be anything to do.  But if you're
    # using MinGW or Cygwin, setting the executable flag might make sense.
    
    typemethod setexecutable {filename} {
        if {[$type flavor] ne "windows"} {
            file attributes $filename \
                -permissions u+x
        }
    }

    #---------------------------------------------------------------------
    # Helpers

    # GetEnv var
    #
    # Returns the value of environment variable $var, or "" if it can't
    # be found.

    proc GetEnv {var} {
        set value ""

        # Some environment variables, or at least "PATH", are screwy.
        # This is simplest.
        catch {set value $::env($var)}

        return $value
    }
}