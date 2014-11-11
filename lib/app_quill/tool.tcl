#-------------------------------------------------------------------------
# TITLE: 
#    tool.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl/Tk
#
# DESCRIPTION:
#    Tool framework for Quill tools.  This may eventually be the basis
#    for a plugin architecture.
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Namespace Export

namespace eval ::app_quill:: {
    namespace export \
        tool
} 

#-------------------------------------------------------------------------
# Tool Singleton

snit::type ::app_quill::tool {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #---------------------------------------------------------------------
    # Type Variables

    # toolbox
    #
    # Array of data about the available tools.
    #
    # tools              - List of subcommands for the available tools.
    # 
    # ensemble-$tool     - The tool's ensemble command.
    # description-$tool  - The tool's one-line description
    # argspec-$tool      - {min max usage}
    # needstree-$tool    - true if the tool must be executed in a project
    #                      tree, and false otherwise.

    typevariable toolbox -array {
        tools {}
    }

    #---------------------------------------------------------------------
    # Tool Definition

    # define tool tooldict helptext body
    #
    # tool         - The tool's subcommand
    # tooldict     - A dictionary of items that define the tool.
    # helptext     - The tool's help text, which will be outdented 
    #                automatically.
    # body         - The tool's body, a snit::type body.
    #
    # Defines the tool.  The tooldict should define the description,
    # argspec, and needstree values.  The body should define at least the
    # execute typemethod.

    typemethod define {tool tooldict helptext body} {
        # FIRST, get the ensemble name
        set tool     [string tolower $tool]
        set ensemble ::app_quill::tool::[string toupper $tool]

        # NEXT, save the body.
        set preamble {
            pragma -hasinstances no -hastypedestroy yes

        }

        snit::type $ensemble "$preamble\n$body"

        # NEXT, save the help
        set ::app_quill::help($tool) $helptext

        # NEXT, save the metadata
        ladd toolbox(tools) $tool

        set toolbox(ensemble-$tool) $ensemble

        # TODO: better validation before we allow plugins!
        set toolbox(description-$tool) [dict get $tooldict description]
        set toolbox(argspec-$tool)     [dict get $tooldict argspec]
        set toolbox(needstree-$tool)   [dict get $tooldict needstree]
    }

    #---------------------------------------------------------------------
    # Queries

    # names
    #
    # Returns the names of the currently defined tools.

    typemethod names {} {
        return [lsort $toolbox(tools)]
    }

    # exists tool
    #
    # tool   - The name of a tool
    # 
    # Returns 1 if the tool exists, and 0 otherwise.

    typemethod exists {tool} {
        if {$tool in $toolbox(tools)} {
            return 1
        }

        return 0
    }

    # needstree tool
    #
    # tool - The name of a tool
    # 
    # Returns 1 if the tool needs a project tree, and 0 otherwise.

    typemethod needstree {tool} {
        return $toolbox(needstree-$tool)
    }

    # description tool
    #
    # tool - The name of a tool
    # 
    # Returns the tool's description.

    typemethod description {tool} {
        return $toolbox(description-$tool)
    }

    # usage tool
    #
    # tool - The name of a tool.
    #
    # Returns the usage string.

    typemethod usage {tool} {
        set usage [lindex $toolbox(argspec-$tool) end]
        return "quill $tool $usage"
    }

    # use tool argv
    #
    # tool   - A tool to use
    # argv   - The tool's arguments
    #
    # Executes the tool, first checking the number of arguments.

    typemethod use {tool argv} {
        if {$tool ni $toolbox(tools)} {
            throw FATAL [outdent "
                Quill has no tool called \"$tool\".  Please see
                \"quill help\" for a list of available tools.
            "]
        }

        checkargs "quill $tool" {*}$toolbox(argspec-$tool) $argv

        $toolbox(ensemble-$tool) execute $argv
    }
}

