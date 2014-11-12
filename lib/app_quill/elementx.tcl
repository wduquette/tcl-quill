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
    # branches           - List of names of branch elements.
    # 
    # ensemble-$name     - The element's ensemble command.
    # description-$name  - The element's one-line description
    # tree-$name         - 1 if this is a full project tree, and 0 if it
    #                      just a branch.
    # help-$name         - The help text for the element.
    # argspec-$name      - The element's argspec: {min max usage}

    typevariable info -array {
        names {}
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
    # Defines the element.  The meta should define the description and
    # tree values.  The body should define the "expand" typemethod.

    typemethod define {name meta helptext body} {
        # FIRST, get the ensemble name
        set name     [string tolower $name]
        set ensemble ::app_quill::elementx::[string toupper $name]

        # NEXT, save the body.
        set preamble {
            pragma -hasinstances no -hastypedestroy yes

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
            ladd info(branches) $name
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

    # branches
    #
    # Returns the names of the currently defined elements that define
    # project subtrees (branches).

    typemethod branches {} {
        return [lsort $info(branches)]
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

    # isbranch name
    #
    # name   - The name of an element
    # 
    # Returns 1 if it is a branch element, and 0 otherwise.

    typemethod isbranch {name} {
        if {$name in $info(branches)} {
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
        # FIRST, do we have such a tree?
        if {![$type istree $name]} {
            throw FATAL \
                "Quill has no project tree template called \"$name\"."
        }

        # NEXT, is the project name valid?
        # TBD: validate project name

        # NEXT, get the -force flag, if present.
        set force [GetForceOption args]

        # NEXT, ensure we are not in a project tree (or -force)
        if {[project intree]} {
            if {!$force} {
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
            if {!$force} {
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
    #
    # TODO: Recast this like newtree, above.

    typemethod add {name args} {
        # FIRST, get the -force flag, if present.

        # NEXT, ensure that we are in a project tree.

        # NEXT, retrieve the element's files, and verify that none of
        # them exists (or -force). 
        #
        # TBD: Make sure that a good FATAL message is produced if the
        # argument list is wrong.

        # NEXT, save the element's files.

        # NEXT, update the project metadata and save it to the 
        # project file.
    }

    #---------------------------------------------------------------------
    # Helpers

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
}

