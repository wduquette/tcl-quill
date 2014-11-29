#-------------------------------------------------------------------------
# TITLE: 
#    element.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    Framework for Quill project elements.
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Namespace Export

namespace eval ::app_quill:: {
    namespace export \
        element
} 

namespace eval ::app_quill::element {
    namespace export \
        fileset      \
        metadata     \
        queue        \
        write
}

#-------------------------------------------------------------------------
# Element Framework Singleton

snit::type ::app_quill::element {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #---------------------------------------------------------------------
    # Type Variables

    # info
    #
    # Array of data about the available elements.
    #
    # counter            - # of defined IDs
    # ids                - List of element IDs (integers).
    # trees              - List of names of project tree elements.
    # filesets           - List of names of non-tree elements.
    # 
    # treeid-$name       - ID of a tree element given its name.
    # fsid-$name         - ID of a file set element given its name.
    # 
    # ensemble-$id       - The element's ensemble command.
    # argspec-$id        - The element's argspec: {min max usage}
    # description-$id    - The element's one-line description
    # tree-$id           - 1 if this is a full project tree, and 0 if it
    #                      just a file set.
    # help-$id           - The help text for the element.

    typevariable info -array {
        counter  0
        names    {}
        trees    {}
        filesets {}
    }

    # trans
    #
    # Transient data used while adding a single element.
    #
    #    force    - 1 if the force flag is set, and 0 otherwise.
    #    files    - Dictionary relpath -> content
    #    metadata - Commands to add to project.quill
    #    queue    - List of Commands to execute
    
    typevariable trans -array {
        force    0
        files    {}
        metadata {}
        queue    {}
    }

    #---------------------------------------------------------------------
    # Element Definition

    # deftree name meta helptext body
    #
    # name         - The element's name
    # meta         - A dictionary of items that define the element.
    # helptext     - The element's help text, which will be outdented 
    #                automatically.
    # body         - The element's body, a snit::type body.
    #
    # Defines the element.  The meta should define:
    # 
    #    description  - A one-line description of the element.
    #    argspec      - The basic argument spec {min max usage}
    #
    # The body must define the "add" typemethod, which takes the
    # project name plus any element-specific arguments.

    typemethod deftree {name meta helptext body} {
        # FIRST, get the ensemble name and id.
        set name     [string tolower $name]
        set ensemble ::app_quill::element::tree[string toupper $name]

        # NEXT, save the body.
        set preamble {
            pragma -hasinstances no -hastypedestroy yes
            typeconstructor {
                # Include the helper procs into the element's namespace.
                namespace import ::app_quill::element::*
            }
        }

        snit::type $ensemble "$preamble\n$body"


        # NEXT, save the metadata
        if {$name in $info(trees)} {
            set id $info(treeid-$name)
        } else {
            set id [incr info(counter)]
            set info(treeid-$name) $id
            lappend info(trees) $name
        }
 
        set info(tree-$id)        1
        set info(ensemble-$id)    $ensemble
        set info(description-$id) [outof $meta description]
        set info(argspec-$id)     [outof $meta argspec]
        set info(help-$id)        $helptext
    }

    # defset name meta helptext body
    #
    # name         - The element's name
    # meta         - A dictionary of items that define the element.
    # helptext     - The element's help text, which will be outdented 
    #                automatically.
    # body         - The element's body, a snit::type body.
    #
    # Defines the element.  The meta should define:
    # 
    #    description  - A one-line description of the element.
    #    argspec      - The basic argument spec {min max usage}
    #
    # The body must define the "add" typemethod, which takes the
    # element-specific arguments.

    typemethod defset {name meta helptext body} {
        # FIRST, get the ensemble name and id.
        set name     [string tolower $name]
        set ensemble ::app_quill::element::fs[string toupper $name]

        # NEXT, save the body.
        set preamble {
            pragma -hasinstances no -hastypedestroy yes
            typeconstructor {
                # Include the helper procs into the element's namespace.
                namespace import ::app_quill::element::*
            }
        }

        snit::type $ensemble "$preamble\n$body"


        # NEXT, save the metadata
        if {$name in $info(filesets)} {
            set id $info(fsid-$name)
        } else {
            set id [incr info(counter)]
            set info(fsid-$name) $id
            lappend info(filesets) $name
        }
 
        set info(tree-$id)        0
        set info(ensemble-$id)    $ensemble
        set info(description-$id) [outof $meta description]
        set info(argspec-$id)     [outof $meta argspec]
        set info(help-$id)        $helptext
    }



    #---------------------------------------------------------------------
    # Tree Queries

    # tree names
    #
    # Returns the names of the currently defined elements that define
    # full project trees.

    typemethod {tree names} {} {
        return [lsort $info(trees)]
    }

    # tree exists name
    #
    # name   - The name of an element
    # 
    # Returns 1 if the tree element exists, and 0 otherwise.

    typemethod {tree exists} {name} {
        if {$name in $info(trees)} {
            return 1
        }

        return 0
    }

    # tree description name
    #
    # name - The name of an element
    # 
    # Returns the tree element's description.

    typemethod {tree description} {name} {
        set id $info(treeid-$name)
        return $info(description-$id)
    }

    # tree usage name
    #
    # name - The name of a tree element
    #
    # Returns the tree element's usage string.

    typemethod {tree usage} {name} {
        set id $info(treeid-$name)
        set arglist [lindex $info(argspec-$id) 2]

        return "quill new $name <project> $arglist"
    }

    # tree help name
    #
    # name - The name of an element
    # 
    # Returns the tree element's help text.

    typemethod {tree help} {name} {
        set id $info(treeid-$name)
        return $info(help-$id)
    }



    # fileset names
    #
    # Returns the names of the currently defined elements that define
    # project subtrees (filesets).

    typemethod {fileset names} {} {
        return [lsort $info(filesets)]
    }

    # fileset exists name
    #
    # name   - The name of an element
    # 
    # Returns 1 if the file set element exists, and 0 otherwise.

    typemethod {fileset exists} {name} {
        if {$name in $info(filesets)} {
            return 1
        }

        return 0
    }

    # fileset description name
    #
    # name - The name of an element
    # 
    # Returns the fileset element's description.

    typemethod {fileset description} {name} {
        set id $info(fsid-$name)
        return $info(description-$id)
    }


    # fileset usage name
    #
    # name - The name of a fileset element
    #
    # Returns the fileset element's usage string.

    typemethod {fileset usage} {name} {
        set id $info(fsid-$name)
        set arglist [lindex $info(argspec-$id) 2]

        return "quill add $name <project> $arglist"
    }

    # fileset help name
    #
    # name - The name of an element
    # 
    # Returns the fileset element's help.

    typemethod {fileset help} {name} {
        set id $info(fsid-$name)
        return $info(help-$id)
    }



    #---------------------------------------------------------------------
    # Actions

    # newtree name project args
    #
    # name    - Name of a tree element
    # project - The new project's name 
    # args    - The element's arguments, plus (optionally) "-force"
    #
    # Creates a new project tree.  By default, we cannot be in an existing
    # tree, and the $project directory must not exist.  If -force is one
    # of the arguments, then the new tree will be created regardless
    # overwriting anything in the way.

    typemethod newtree {name project args} {
        # FIRST, clear transient data
        ClearTrans

        # FIRST, do we have such a tree?
        if {![$type tree exists $name]} {
            throw FATAL \
                "Quill has no project tree template called \"$name\"."
        }

        set id $info(treeid-$name)

        # NEXT, get the -force flag, if present.
        set trans(force) [GetForceOption args]

        # NEXT, ensure we are not in a project tree (or -force)
        if {[project intree]} {
            if {!$trans(force)} {
                throw FATAL [outdent "
                    The current working directory is in an existing
                    project tree.

                    Normally, Quill will not create nested projects.
                    To create a project within an existing project, include
                    the -force option.
                "]
            }
        }

        # NEXT, ensure that the project directory doesn't yet exist
        # (or -force).
        if {[file exists $project]} {
            if {!$trans(force)} {
                throw FATAL [outdent "
                    \"$project\" already exists in the current
                    working directory.  To overwrite an existing project 
                    directory, include the -force option.
                "]
            } else {
                if {[file isfile $project]} {
                    throw FATAL [outdent "
                        \"$project\" already exists in the current working
                        directory, and as it is a regular file Quill cannot
                        overwrite it with a project directory.    
                    "]
                }
            }
        }

        # NEXT, check the argument list.  The element will need to check
        # any options, and can get the project name from [project name].
        checkargs "quill new $name $project" {*}$info(argspec-$id) $args

        # NEXT, create the project directory.
        puts "Creating a new \"$name\" project tree at $project/...\n"
        project newroot [file join [pwd] $project]

        $info(ensemble-$id) add $project {*}$args


        # NEXT, execute the queued actions.
        WriteFiles
        ExecuteQueue
        SaveMetadata
    }

    # newset name args
    #
    # name   - Name of a file set element
    # args   - The element's arguments, plus (optionally) "-force"
    #
    # Adds the element to the current project.  We must be in a 
    # project tree.  By default, the operation will fail if any of
    # the files to be created by the element already exist.  If -force
    # is given, it will overwrite existing files.

    typemethod newset {name args} {
        # FIRST, clear the transient data
        ClearTrans

        # NEXT, do we have such a file set?
        if {![$type fileset exists $name]} {
            throw FATAL \
                "Quill has no file set template called \"$name\"."
        }

        set id $info(fsid-$name)

        # NEXT, get the -force flag, if present.
        set trans(force) [GetForceOption args]

        # NEXT, check the argument list.  The element will need to check
        # any options, and can get the project name from [project name].
        checkargs "quill add $name" {*}$info(argspec-$id) $args

        fileset $name {*}$args

        # NEXT, execute the queued actions.
        WriteFiles
        ExecuteQueue
        SaveMetadata
    }

    # WriteFiles
    #
    # If any of the files already exists, throws FATAL
    # unless the -force flag is set.

    proc WriteFiles {} {
        # FIRST, make sure none of the files exist.
        if {!$trans(force)} {
            set list [list]

            foreach filename [dict keys $trans(files)] {
                set fullname [GetPath $filename]

                if {[file exists $fullname]} {
                    lappend list $fullname
                }
            }

            if {[got $list]} {
                puts "Adding this element would overwrite the following files:"
                puts ""

                foreach file $list {
                    puts "    $file"
                }

                puts ""
                throw FATAL "To add the element anyway, use the -force option."
            }
        }


        # NEXT, write the files.
        dict for {filename content} $trans(files) {
            set fullname [GetPath $filename]
            puts "File: $fullname"
            writefile $fullname $content
        }
    } 

    # ExecuteQueue
    #
    # Executes the commands in the queue.

    proc ExecuteQueue {} {
        if {![got $trans(queue)]} {
            return
        }

        try {
            namespace eval :: [join $trans(queue) \n]
        } on error {result} {
            throw FATAL "Error in element plugin: $result"
        }
    }

    # SaveMetadata
    #
    # Saves accumulated metadata into project.quill.

    proc SaveMetadata {} {
        if {![got $trans(metadata)]} {
            return
        }

        puts ""
        foreach item $trans(metadata) {
            puts "project.quill: $item"
        }

        set f [open [project root project.quill] a]

        puts $f ""
        puts $f [join $trans(metadata) \n]
        puts $f ""

        close $f
    }

    #---------------------------------------------------------------------
    # Commands for use by elements.

    # fileset name args
    #
    # name  - A file set name
    # args  - The arguments for that file set.
    #
    # Includes the file set into the current element.

    proc fileset {name args} {
        set id $info(fsid-$name)
        $info(ensemble-$id) add {*}$args
        return
    }

    # metadata command...
    #
    # command... - A command to append to project.quill.
    #
    # Adds a project(5) command to project.quill.

    proc metadata {args} {
        lappend trans(metadata) $args
        return
    }

    # queue command...
    #
    # command...   - A command to execute at the proper time.
    #
    # Queues up a command to be executed.

    proc queue {args} {
        lappend trans(queue) $args
        return
    }

    # write relpath content
    #
    # relpath    - A path relative to project root, with forward slashes
    # content    - The content to write.
    #
    # Queues up a file to be written.

    proc write {relpath content} {
        into trans(files) $relpath $content
        return
    }


    #---------------------------------------------------------------------
    # Helpers

    # ClearTrans
    #
    # Clears the transient data.

    proc ClearTrans {} {
        set trans(force) 0
        set trans(files) [dict create]
        set trans(queue) [list]
    }

    # GetForceOption listvar
    #
    # listvar   - An argument list
    #
    # Returns 1 if the listvar's value includes "-force", and 0 otherwise.
    # Removes -force from the listvar.

    proc GetForceOption {listvar} {
        upvar 1 $listvar argv

        if {"-force" in $argv} {
            ldelete argv -force
            return 1
        }

        return 0
    }

    # GetPath path
    #
    # path   - A relative path with forward slashes
    #
    # Returns the full path.

    proc GetPath {path} {
        set pathlist [split $path "/"]

        return [project root {*}$pathlist]
    }
}

