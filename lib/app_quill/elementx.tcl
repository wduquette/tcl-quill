#-------------------------------------------------------------------------
# TITLE: 
#    elementx.tcl
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
# TBD:
#    At present this is elementx.  When complete, the old element.tcl
#    and tree.tcl modules will go away, and this will become element.tcl.
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Namespace Export

namespace eval ::app_quill:: {
    namespace export \
        elementx
} 

namespace eval ::app_quill::elementx {
    namespace export \
        write        \
        queue
}

#-------------------------------------------------------------------------
# Element Framework Singleton

snit::type ::app_quill::elementx {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #---------------------------------------------------------------------
    # Type Variables

    # info
    #
    # Array of data about the available elements.
    #
    # names              - List of element names (names).
    # trees              - List of names of project tree elements.
    # filesets           - List of names of non-tree elements.
    # 
    # ensemble-$name     - The element's ensemble command.
    # description-$name  - The element's one-line description
    # tree-$name         - 1 if this is a full project tree, and 0 if it
    #                      just an element.
    # help-$name         - The help text for the element.
    # argspec-$name      - The element's argspec: {min max usage}

    typevariable info -array {
        names    {}
        trees    {}
        filesets {}
    }

    # trans
    #
    # Transient data used while adding a single element.
    #
    #    force   - 1 if the force flag is set, and 0 otherwise.
    #    files   - Dictionary relpath -> content
    #    queue   - List of Commands to execute
    
    typevariable trans -array {
        force 0
        files {}
        queue {}
    }

    #---------------------------------------------------------------------
    # Element Definition

    # define name meta helptext body
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
    #    tree         - 1 if this is a full tree, and 0 otherwise.
    #    argspec      - The basic argument spec {min max usage}
    #
    # The body must define the "add" typemethod.

    typemethod define {name meta helptext body} {
        # FIRST, get the ensemble name
        set name     [string tolower $name]
        set ensemble ::app_quill::elementx::[string toupper $name]

        # NEXT, save the body.
        set preamble {
            pragma -hasinstances no -hastypedestroy yes
            typeconstructor {
                # Include the helper procs into the element's namespace.
                namespace import ::app_quill::elementx::*
            }
        }

        snit::type $ensemble "$preamble\n$body"


        # NEXT, save the metadata
        ladd info(names) $name

        set info(ensemble-$name) $ensemble

        # TODO: better validation before we allow plugins!
        set info(description-$name) [outof $meta description]
        set info(tree-$name)        [outof $meta tree]
        set info(argspec-$name)     [outof $meta argspec]
        set info(help-$name)        $helptext

        if {$info(tree-$name)} {
            ladd info(trees) $name
        } else {
            ladd info(filesets) $name
        }
    }

    #---------------------------------------------------------------------
    # Queries

    # names
    #
    # Returns the names of the currently defined elements.

    typemethod names {} {
        return [lsort $info(names)]
    }

    # trees
    #
    # Returns the names of the currently defined elements that define
    # full project trees.

    typemethod trees {} {
        return [lsort $info(trees)]
    }

    # filesets
    #
    # Returns the names of the currently defined elements that define
    # project subtrees (filesets).

    typemethod filesets {} {
        return [lsort $info(filesets)]
    }

    # exists name
    #
    # name   - The name of an element
    # 
    # Returns 1 if the element exists, and 0 otherwise.

    typemethod exists {name} {
        if {$name in $info(names)} {
            return 1
        }

        return 0
    }

    # istree name
    #
    # name   - The name of an element
    # 
    # Returns 1 if it is a tree element, and 0 otherwise.

    typemethod istree {name} {
        if {$name in $info(trees)} {
            return 1
        }

        return 0
    }

    # isfileset name
    #
    # name   - The name of an element
    # 
    # Returns 1 if it is a file set element, and 0 otherwise.

    typemethod isfileset {name} {
        if {$name in $info(filesets)} {
            return 1
        }

        return 0
    }

    # description name
    #
    # name - The name of an element
    # 
    # Returns the element's description.

    typemethod description {tool} {
        return $info(description-$name)
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
        if {![$type istree $name]} {
            throw FATAL \
                "Quill has no project tree template called \"$name\"."
        }

        # NEXT, is the project name valid?
        # TBD: validate project name

        # NEXT, get the -force flag, if present.
        set trans(force) [GetForceOption args]

        # NEXT, ensure we are not in a project tree (or -force)
        if {[project intree]} {
            if {!$trans(force)} {
                throw FATAL [outdent {
                    To create a project within an existing project, include
                    the -force option.
                }]
            }

            # TBD: Be sure we clear and reset the project metadata.
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
        checkargs "quill new $name $project" {*}$info(argspec-$name) $args

        # NEXT, create the project directory, and initialize the project
        # metadata.  (It will be updated by the element.)
        # TBD.

        # NEXT, get and save the element's files, and update the 
        # project metadata.

        # NEXT, save the project metadata to the project file.
        # TBD
    }

    # add name args
    #
    # name   - Name of a branch element
    # args   - The element's arguments, plus (optionally) "-force"
    #
    # Adds the element to the current project.  We must be in a 
    # project tree.  By default, the operation will fail if any of
    # the files to be created by the element already exist.  If -force
    # is given, it will overwrite existing files.

    typemethod add {name args} {
        # FIRST, clear the transient data
        ClearTrans

        # NEXT, do we have such a file set?
        if {![$type isfileset $name]} {
            throw FATAL \
                "Quill has no file set template called \"$name\"."
        }

        # NEXT, get the -force flag, if present.
        set trans(force) [GetForceOption args]

        # NEXT, check the argument list.  The element will need to check
        # any options, and can get the project name from [project name].
        checkargs "quill add $name" {*}$info(argspec-$name) $args

        fileset $name {*}$args

        # NEXT, execute the queued actions.
        WriteFiles
        ExecuteQueue

        # NEXT, save the project metadata to the project file.
        # TBD
    }

    # WriteFiles
    #
    # If any of the files already exists, throws FATAL
    # unless the -force flag is set.

    proc WriteFiles {} {
        # FIRST, make sure none of the files exist.
        if {!$trans(force)} {
            foreach filename [dict keys $trans(files)] {
                set fullname [GetPath $filename]

                if {[file exists $fullname]} {
                    throw FATAL [outdent "
                        This element file already exists:

                            $fullname

                        To overwrite it, use the -force option.
                    "]
                }
            }
        }

        # NEXT, write the files.
        dict for {filename content} $trans(files) {
            set fullname [GetPath $filename]
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

    #---------------------------------------------------------------------
    # Commands for use by elements.

    # fileset name args
    #
    # name  - A file set name
    # args  - The arguments for that file set.
    #
    # Includes the file set into the current element.

    proc fileset {name args} {
        $info(ensemble-$name) add {*}$args
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

    # queue command...
    #
    # command...   - A command to execute at the proper time.
    #
    # Queues up a command to be executed.

    proc queue {args} {
        lappend trans(queue) $args
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

