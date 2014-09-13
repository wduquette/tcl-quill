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
# Register the tool

set ::quillapp::tools(version) {
    command     "version"
    description "Displays the Quill tool's version to the console."
    argspec     {0 0 ""}
    intree      false
    ensemble    ::quillapp::versiontool
}

set ::quillapp::help(version) {
    The "quill version" tool displays the Quill application's version
    to the console in human-readable form.
}

#-------------------------------------------------------------------------
# Namespace Export

namespace eval ::quillapp:: {
    namespace export \
        versiontool
} 

#-------------------------------------------------------------------------
# Tool Singleton: versiontool

snit::type ::quillapp::tool {
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
    # intree-$tool       - true if the tool must be executed in a project
    #                      tree, and false otherwise.

    typevariable tools -array {} {
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
    # argspec, and intree values.  The body should define at least the
    # execute typemethod.

    typemethod define {tool tooldict helptext body} {
        # FIRST, get the ensemble name
        set tool     [string tolower $tool]
        set ensemble ::quillapp::tool::[string toupper $tool]

        # NEXT, save the body.
        set preamble {
            pragma -hasinstances no -hastypedestroy yes

        }

        snit::type $ensemble "$preamble\n$body"

        # NEXT, save the help
        set ::quillapp::help($tool) $helptext

        # NEXT, save the metadata
        ladd toolbox(tools) $tool

        set toolbox(ensemble-$tool) $ensemble

        # TODO: better validation before we allow plugins!
        set toolbox(description-$tool) [dict get $tooldict description]
        set toolbox(argspec-$tool)     [dict get $tooldict argspec]
        set toolbox(intree-$tool)      [dict get $tooldict intree]
    }

    #---------------------------------------------------------------------
    # Queries

    # names
    #
    # Returns the names of the 
}

