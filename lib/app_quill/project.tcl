#-------------------------------------------------------------------------
# TITLE: 
#    project.tcl
#
# AUTHOR:
#    Will Duquette
#
# PROJECT:
#    Quill: Project Build System for Tcl
#
# DESCRIPTION:
#    Project file parser and metadata object
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Namespace Exports

namespace eval ::app_quill:: {
    namespace export \
        project
}

#-------------------------------------------------------------------------
# project ensemble

snit::type ::app_quill::project {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #---------------------------------------------------------------------
    # Constants

    typevariable projectFile "project.quill"

    #---------------------------------------------------------------------
    # Type Variables

    # info - Package data, other than project metadata
    #
    # intree - 1 if we're in a project tree, 0 if not.  Set by
    #          [project findroot]
    # root   - The project tree's root directory
    # gottcl - 1 if we have a valid tclsh, and 0 otherwise.

    typevariable info -array {
        intree ""
        root   ""
        gottcl 0
    }

    # meta - Project metadata array for the project being managed.
    #
    # Data includes:
    #
    # project       - The project name
    # version       - The project version number
    # description   - The project description
    # homepage      - URL of the project home page.
    #
    # apps          - List of application names
    # exetype-$app  - Kind of executable to build for app $app: kit 
    #                 (a starkit) or exe (a starpack).
    # gui-$app      - Flag, 0 or 1: does package require Tk?
    #
    # requires      - List of required package names
    # version-$req  - The required version
    # local-$req    - Flag, 0 or 1: is package local?
    #
    # provides      - List of names of exported library packages.
    # dists         - List of distribution names
    #
    # distpat-$dist - List of file patterns for dist $dist


    typevariable meta -array {
        project     ""
        version     ""
        description ""
        url         "http://my.home.page"
        apps        {}
        provides    {}
        requires    {Tcl}
        version-Tcl 8.6
        dists       {}
    }

    #---------------------------------------------------------------------
    # Public Methods: Initialization

    # findroot
    #
    # Looks for the project's root directory by looking for project.quill
    # in the current directory and on up the chain.

    typemethod findroot {} {
        # FIRST, it's safe to call this multiple times.
        if {$info(intree) ne ""} {
            return $info(intree)
        }

        # NEXT, find the project file
        set info(intree) 0
        set here ""
        set next [pwd]

        while {$next ne $here} {
            set here $next

            if {[file exists [file join $here $projectFile]]} {
                set info(root)   $here
                set info(intree) 1
                break
            }

            set next [file dirname $here]
        }

        return $info(intree)
    }

    # intree
    #
    # Returns 1 if we're in a project tree, and 0 otherwise.

    typemethod intree {} {
        return $info(intree)
    }

    # newroot rootdir
    #
    # rootdir - Project root directory name
    #
    # Creates a new project root directory, and positions Quill within
    # it as though findroot had succeeded.  This is for use in bootstrapping
    # new projects.

    typemethod newroot {rootdir} {
        set info(root) $rootdir
        file mkdir $info(root)
        cd $info(root)
        set info(intree) 1
    }

    #---------------------------------------------------------------------
    # Queries

    # root path...
    #
    # path... - One or more path components
    #
    # Joins the path components to the project root, and returns the
    # the result.  If no path components are given, just returns the
    # project root.

    typemethod root {args} {
        assert {$info(root) ne ""}
        return [file normalize [file join $info(root) {*}$args]]
    }

    # glob pattern...
    #
    # pattern... - One or more pattern components
    #
    # The pattern components are [file join]'d to the 
    # [project root] and passed to [glob].  The result is returned.

    typemethod glob {args} {
        set pattern [project root {*}$args]

        set result [list]
        foreach fname [glob -nocomplain $pattern] {
            lappend result [file normalize $fname]
        }
        return $result
    } 

    # globfiles pattern...
    #
    # pattern... - One or more pattern components
    #
    # The pattern components are [file join]'d to the 
    # [project root] and passed to [glob].  All normal files
    # from the result are returned.

    typemethod globfiles {args} {
        set result [list]
        foreach fname [project glob {*}$args] {
            if {[file isfile $fname]} {
                lappend result $fname
            }
        }
        return $result
    } 

    # globdirs pattern...
    #
    # pattern... - One or more pattern components
    #
    # The pattern components are [file join]'d to the 
    # [project root] and passed to [glob].  All directory names
    # from the result are returned.

    typemethod globdirs {args} {
        set result [list]
        foreach fname [project glob {*}$args] {
            if {[file isdirectory $fname]} {
                lappend result $fname
            }
        }
        return $result
    } 

    # quilldir ?path...?
    #
    # path  - Path components
    # 
    # Returns a normalized path into the root/.quill/ directory,
    # creating the directory if need be.  The .quill directory is 
    # used for project-specific Quill artifacts, such as log files.

    typemethod quilldir {args} {
        file mkdir [$type root .quill]
        return [project root .quill {*}$args]
    }

    #---------------------------------------------------------------------
    # Metadata Queries

    typemethod metadata        {} { return [array get meta]   }
    typemethod name            {} { return $meta(project)     }
    typemethod version         {} { return $meta(version)     }
    typemethod description     {} { return $meta(description) }
    typemethod {app names}     {} { return $meta(apps)        }
    typemethod {provide names} {} { return $meta(provides)    }
    typemethod {dist names}    {} { return $meta(dists)       }

    # header
    #
    # Returns the project header string.

    typemethod header {} {
        return "$meta(project) $meta(version): $meta(description)"
    }

    # gotinfo
    #
    # Returns 1 if we've loaded the project's info, and 0 otherwise.

    typemethod gotinfo {} {
        expr {$meta(project) ne ""}
    }

    # gotapp
    #
    # Returns 1 if the project defines an application, and 0 otherwise.

    typemethod gotapp {} {
        expr {[llength $meta(apps)] > 0}
    }

    # libpath
    #
    # Returns the full set of library directories for this project.
    # The assumption is that any code needed by the project is either
    # on this path or included in a linked teapot.
    
    typemethod libpath {} {
        lappend result \
            [project root lib]

        return $result
    }

    # app loader app
    #
    # app  - The app name
    #
    # Returns the path to the loader script.

    typemethod {app loader} {app} {
        return [project root bin $app.tcl]
    }

    # app exetype app
    #
    # app  - The app name
    #
    # Returns the executable type for the app: kit or exe.

    typemethod {app exetype} {app} {
        return $meta(exetype-$app)
    }

    # app exename app ?plat?
    #
    # app     - The app name
    # plat    - The platform, tcl (for .kits) or the actual platform.
    #
    # Returns the full name of the built app given the
    # platform.  If plat is missing, uses current platform.

    typemethod {app exename} {app {plat ""}} {
        if {$meta(exetype-$app) eq "kit"} {
            set plat "tcl"
        } elseif {$plat eq ""} {
            set plat [platform::identify]
        }

        set base $app-$meta(version)

        if {$plat eq "tcl"} {
            return "$base.kit"
        } 

        append base "-$plat"

        if {[string match "win32-*" $plat]} {
            append base ".exe"
        }

        return $base
    }


    # app gui app
    #
    # app - The app name
    #
    # Returns 1 if the app is a GUI, and 0 otherwise.

    typemethod {app gui} {app} {
        return $meta(gui-$app)
    }

    # require names ?-all?
    #
    # Returns the names of all required packages EXCEPT Tcl and Tk.
    # If -all is given, they are included if present.

    typemethod {require names} {{opt ""}} {
        set names $meta(requires)

        if {$opt ne "-all"} {
            ldelete names Tcl
            ldelete names Tk
        }

        return $names
    }

    # require version pkg
    #
    # pkg - The package name
    #
    # Returns the required version of the package.

    typemethod {require version} {pkg} {
        return $meta(version-$pkg)
    }

    # require local pkg
    #
    # pkg - The package name
    #
    # Returns 1 if the required package is locally developed, and
    # 0 otherwise.

    typemethod {require local} {pkg} {
        return $meta(local-$pkg)
    }

    # provide zipfile lib
    #
    # lib     - A provided library name
    #
    # Returns the full name of the library's zip file.

    typemethod {provide zipfile} {lib} {
        return "package-$lib-[project version]-tcl.zip"
    }

    # dist expand name ?plat?
    #
    # name  - A distribution name
    # plat  - The platform.
    #
    # Expands replaceable tokens in the distribution name.

    typemethod {dist expand} {name {plat ""}} {
        if {$plat eq ""} {
            set plat [platform::identify]
        }

        return [string map [list %platform $plat] $name]
    }

    # dist patterns name
    #
    # name - A distribution name
    #
    # Returns the list of patterns associated with $name.

    typemethod {dist patterns} {name} {
        return $meta(distpat-$name)
    }

    #---------------------------------------------------------------------
    # Sanity Check

    # check
    #
    # Does checks of the environment vs. project.quill.
    # Sets the following info() variables:
    #
    #    gottcl

    typemethod check {} {
        set info(gottcl) 0

        # FIRST, do we have a tclsh?
        if {[env pathto tclsh] eq ""} {
            puts [outdent {
                WARNING: Quill cannot find the platform tclsh; it isn't
                on the PATH.  Please install ActiveTcl, or identify the
                correct tclsh using 'quill config helper.tclsh'.
            }]

            puts ""

            return
        }

        set ver    [env versionof tclsh]
        set reqver [project require version Tcl]

        if {$ver eq ""} {
            puts [outdent {
                WARNING: Quill cannot identify the version of the 
                current tclsh.  This implies that Quill cannot execute
                it.  Please verify that the tclsh is working properly.
            }]

            puts ""

            return
        } 

        if {![package vsatisfies $ver $reqver]} {
            puts [outdent "
                WARNING: Your project requires Tcl $reqver, but the current
                tclsh is for Tcl $ver.  Please change your requirement,
                or install the desired version of Tcl.
            "]

            puts ""

            return
        }

        set info(gottcl) 1

        return 
    }

    #---------------------------------------------------------------------
    # Loading the Project file

    # loadinfo
    #
    # Attempts to load the project metadata from the project file into
    # the meta() array.

    typemethod loadinfo {} {
        assert {$info(intree)}

        # FIRST, set up the slave interpreter to parse this.
        set interp [smartinterp %AUTO% -commands none]

        $interp smartalias project {project version description} 3 3 \
            [myproc ProjectCmd]

        $interp smartalias homepage {url} 1 1 \
            [myproc HomepageCmd]

        $interp smartalias app {name ?options...?} 1 - \
            [myproc AppCmd]

        $interp smartalias provide {name} 1 1 \
            [myproc ProvideCmd]

        $interp smartalias require {name version ?options?} 2 - \
            [myproc RequireCmd]

        $interp smartalias dist {name patterns} 2 2 \
            [myproc DistCmd]

        # NEXT, try to parse the file.  The commands will throw
        # SYNTAX errors if they detect a problem.

        try {
            $interp eval [readfile [project root $projectFile]]
        } trap INVALID {result} {
            throw FATAL "Error in $projectFile: $result"
        } trap SYNTAX {result} {
            throw FATAL "Error in $projectFile: $result"
        } trap {TCL LOOKUP COMMAND} {result} {
            throw FATAL "Error in $projectFile: $result"
        } trap {TCL WRONGARGS} {result} {
            throw FATAL "Error in $projectFile: $result"
        }

        # NEXT, if no project is specified that's an error.
        if {$meta(project) eq ""} {
            throw FATAL [outdent {
                The project.quill file doesn't define a project.
                Please add a \"project\" statement.
            }]
        }

        $interp destroy

        # NEXT, check status

        project check
    }



    # ProjectCmd project version description
    # 
    # project     - The project project
    # version     - The project version
    # description - The project description
    # 
    # Defines the project's identity.  The version must be a valid
    # [package provide] version string.

    proc ProjectCmd {project version description} {
        if {$meta(project) ne ""} {
            throw SYNTAX "Multiple \"project\" statements in file"
        }

        prepare project      -required -file
        prepare version      -type ::app_quill::version
        prepare description  -required -tighten

        set meta(project)     $project
        set meta(version)     $version
        set meta(description) $description
    }

    # HomepageCmd url
    #
    # url - The project home page url.
    #
    # Specifies that this project's home page is at the given URL.

    proc HomepageCmd {url} {
        prepare url
        set meta(homepage) $url
    }

    # AppCmd name ?options...?
    #
    # name - The application name.
    #
    # -gui                - The application should be a GUI
    # -exetype exetype    - kit or exe.
    #
    # Specifies that this project builds an application called $name.

    proc AppCmd {name args} {
        # FIRST, get the option values
        set gui      0
        set exetype  kit

        foroption opt args -all {
            -gui {
                set gui 1
            }

            -exetype {
                set exetype [lshift args]
                prepare exetype -oneof {kit exe}
            }
        }

        prepare name -required -file

        ladd meta(apps)           $name
        set  meta(exetype-$name)  $exetype
        set  meta(gui-$name)      $gui
    }

    # ProvideCmd name
    #
    # name - The library package name.
    #
    # Specifies that this project provides a package called $name.

    proc ProvideCmd {name} {
        prepare name -required -file
        ladd meta(provides) $name
    }

    # RequireCmd name version ?options?
    #
    # name    - The package name.
    # version - The package's version number
    # options - Requirement options
    #
    #    -local  - The package is locally developed.  Do not try to
    #              retrieve it from ActiveState's teapot.
    #
    # Specifies that this project requires the named package.

    proc RequireCmd {name version args} {
        # FIRST, options
        set local 0

        foroption opt args -all {
            -local { set local 1}
        }

        # NEXT, validate data
        prepare name -required
        prepare version -type {::app_quill::version rqmt}

        # NEXT, save the data
        ladd meta(requires)      $name
        set  meta(version-$name) $version
        set  meta(local-$name)   $local
    }

    # DistCmd name patterns
    #
    # name     - The distribution name.
    # patterns - A list of file patterns for distribution
    #
    # Specifies that this project creates a distribution .zip file
    # with the given name.

    proc DistCmd {name patterns} {
        # Substitute %platform, if present.
        prepare name -required
        set testname [project dist expand $name]

        prepare testname -file

        if {$name in [project dist names]} {
            throw SYNTAX "Duplicate distribution: \"$name\""
        }

        ladd meta(dists) $name
        set  meta(distpat-$name) $patterns
    }


    #---------------------------------------------------------------------
    # Saving project metadata
    #
    # For projects with an "app", Quill saves the project metadata into
    # a package called "quillinfo", thus giving the application access
    # to the information.
    #
    # In addition, Quill updates lib/<package> files with the 
    # project version.

    # quillinfo save
    #
    # Saves project metadata as appropriate.

    typemethod {quillinfo save} {} {
        assert {[$type gotinfo]}

        # FIRST, save the info to quillinfo.
        set root [project root lib/quillinfo]
        if {[$type gotapp]} {
            writefile [project root lib/quillinfo/pkgIndex.tcl]   \
                [::qfile::quillinfoPkgIndex]
            writefile [project root lib/quillinfo/pkgModules.tcl] \
                [::qfile::quillinfoPkgModules]
            writefile [project root lib/quillinfo/quillinfo.tcl]  \
                [::qfile::quillinfo.tcl]
        }

        # NEXT, update Tcl/Tk versions in apploader scripts.
        foreach app [project app names] {
            UpdateAppTclTk $app
        }

        # NEXT, update each lib.
        foreach libdir [project globdirs lib *] {
            UpdatePkgIfneeded $libdir
            UpdatePkgProvide $libdir
            UpdatePkgRequire $libdir
        }
    }

    # UpdateAppTclTk app
    #
    # app    - A project application name
    #
    # Updates the Tcl/Tk package requires in the app's loader script
    # to the version required by the project.

    proc UpdateAppTclTk {app} {
        # FIRST, get the file to update
        set fname [project app loader $app]

        # NEXT, if there isn't one, we don't need to update it.
        if {![file isfile $fname]} {
            return
        }

        # NEXT, get its content and update it.
        set text [readfile $fname]
        set tclText "package require Tcl [project require version Tcl]"
        set tkText  "package require Tk [project require version Tcl]"

        set text [tagreplace tcl $text $tclText]
        set text [tagreplace tk  $text $tkText]

        writefile $fname $text
    }

    # UpdatePkgIfneeded libdir
    #
    # libdir    - A project lib directory
    #
    # Looks for the pkgIndex file and updates the 
    # "package ifneeded" line.

    proc UpdatePkgIfneeded {libdir} {
        # FIRST, get the file to update
        set package [file tail $libdir]
        set pkgIndex [file join $libdir pkgIndex.tcl]

        # NEXT, if there isn't one, we don't need to update this package.
        if {![file isfile $pkgIndex]} {
            return
        }

        # NEXT, get the text and split it on the tag.
        set text [readfile $pkgIndex]
        set pieces [tagsplit ifneeded $text]

        # NEXT, if the tag isn't present, we don't need to update this
        # package.
        if {[llength $pieces] == 0} {
            return
        }

        # NEXT, update the ifneeded block.
        lassign $pieces before block after
        lappend nblock [format [tighten {
            package ifneeded %s %s 
            [list source [file join $dir pkgModules.tcl]]
        }] $package [project version]]

        # NEXT, output the updated file if the text has changed.
        writefile $pkgIndex [join [concat $before $nblock $after] \n]
    }

    # UpdatePkgProvide libdir
    #
    # libdir    - A project lib directory
    #
    # Looks for the pkgModules file and updates the 
    # "package provide" line.

    proc UpdatePkgProvide {libdir} {
        # FIRST, get the file to update
        set package [file tail $libdir]
        set pkgModules [file join $libdir pkgModules.tcl]

        # NEXT, if there isn't one, we don't need to update this package.
        if {![file isfile $pkgModules]} {
            return
        }

        # NEXT, get the text and split it on the tag.
        set text [readfile $pkgModules]
        set pieces [tagsplit provide $text]

        # NEXT, if the tag isn't present, we don't need to update this
        # package.
        if {[llength $pieces] == 0} {
            return
        }

        # NEXT, update the provide block.
        lassign $pieces before block after
        lappend nblock [format {package provide %s %s} \
            $package [project version]]

        # NEXT, output the updated file if the text has changed.
        writefile $pkgModules [join [concat $before $nblock $after] \n]
    }

    # UpdatePkgRequire libdir
    #
    # libdir    - A project lib directory
    #
    # Looks for the pkgModules file and updates the 
    # "package require" block.  Versions are set to the required version
    # for packages "require"'d in project.quill, and to the project version
    # for packages "provide"'d in project.quill. 

    proc UpdatePkgRequire {libdir} {
        # FIRST, get the file to update
        set package [file tail $libdir]
        set pkgModules [file join $libdir pkgModules.tcl]

        # NEXT, if there isn't one, we don't need to update this package.
        if {![file isfile $pkgModules]} {
            return
        }

        # NEXT, get the text and split it on the tag.
        set text [readfile $pkgModules]
        set pieces [tagsplit require $text]

        # NEXT, if the tag isn't present, we don't need to update this
        # package.
        if {[llength $pieces] == 0} {
            return
        }

        # NEXT, update the require block.
        lassign $pieces before block after

        set nblock [list]
        foreach line $block {
            if {[string match "package require *" [tighten $line]]} {
                set package [lindex $line 2]

                if {$package in [project require names -all]} {
                    set ver [project require version $package]
                    lappend nblock "package require $package $ver"
                } elseif {[file isdirectory [project root lib $package]]} {
                    lappend nblock "package require $package [project version]"
                } else {
                    puts [outdent "
                        Warning: $pkgModules 
                        requires package \"$package\", but \"$package\" is
                        not required in project.quill.
                    "]
                    puts ""
                    lappend nblock $line
                }

            } else {
                lappend nblock $line
            }
        }
        # NEXT, output the updated file if the text has changed.
        writefile $pkgModules [join [concat $before $nblock $after] \n]
    }
}