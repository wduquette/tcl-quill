#-------------------------------------------------------------------------
# TITLE: 
#    manpage.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl
#
# DESCRIPTION:
#    manpage(n): manpage processor built on macro(n).
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Namespace Exports

namespace eval ::quill:: {
    namespace export \
        manpage
}

#-------------------------------------------------------------------------
# manpage singleton

snit::type ::quill::manpage {
    #---------------------------------------------------------------------
    # Type Constructor

    typeconstructor {
        snit::type manref {
            pragma -hasinstances no

            # snit::type for validating manpage references.
            typecomponent validator

            # Regular Expression for parsing manpage references
            typevariable re {^(\w+)\(([15ni])\)$}

            typeconstructor {
                set validator [snit::stringtype %AUTO% -regexp $re]
            }

            delegate typemethod validate to validator

            typemethod parse {ref basenameVar mansecVar} {
                upvar $basenameVar basename
                upvar $mansecVar mansec

                return [regexp $re $ref dummy basename mansec]
            }
        }
    }

    #---------------------------------------------------------------------
    # Lookup Tables

    typevariable manpageCSS {
        /* Links should be displayed with no underline */
        :link {
            text-decoration: none;
        }

        :visited {
            text-decoration: none;
        }

        /* Body is black on white, and indented. */
        body {
            color: black;
            background-color: white;
            margin-left: 0.5in;
            margin-right: 0.5in;
        }

        /* For the page header */
        h1.header {
            position: relative;
            left: -0.4in;
            background-color: red;
            color: black;
        }

        /* The title and section headers are outdented. */
        h1 {
            position: relative;
            left: -0.4in;
        }

        h2 {
            position: relative;
            left: -0.4in;
        }

        /* Preformatted text has a special background */
        pre {
            border: 1px solid blue;
            background-color: #FFFF66;
            padding: 2px;
        }

        /* Use for indenting */
        .indent0 { }
        .indent1 {
            position: relative;
            left: 0.4in
        }
        .indent2 {
            position: relative;
            left: 0.8in
        }
        .indent3 {
            position: relative;
            left: 1.2in
        }
        .indent4 {
            position: relative;
            left: 1.6in
        }
        .indent5 {
            position: relative;
            left: 2.0in
        }
        .indent6 {
            position: relative;
            left: 2.4in
        }
        .indent7 {
            position: relative;
            left: 2.8in
        }
        .indent8 {
            position: relative;
            left: 3.2in
        }
        .indent9 {
            position: relative;
            left: 3.6in
        }

        /* Outdent to margin */
        .outdent {
            position: relative;
            left: -0.4in;
        }
    }

    #---------------------------------------------------------------------
    # Components

    component macro  ;# The macro(n) object


    #---------------------------------------------------------------------
    # Type Variables

    # trans array: Transient data
    #
    # Information for directory index:
    #
    #   header          - Header string for all manpages.
    #   docroot         - Root directory for output docs (i.e., parent
    #                     of "man$sec" directories).
    #   manpages        - List of toplevel manpage names processed in this 
    #                     directory.
    #   children-$name  - List of child manpages for manpage $name.
    #
    # Information for the current manpage.
    #
    #   filename        - The current manpage's filename.
    #   manpage         - The manref of the current manpage.

    variable trans -array {
    }

    #---------------------------------------------------------------------
    # Options

    # TBD

    #---------------------------------------------------------------------
    # Constructor

    constructor {} {
        # FIRST, create the components
        install macro using macro ${selfns}::macro \
            -brackets {< >}

        # NEXT, define the macros initially.
        $self ResetMacros
    }

    #---------------------------------------------------------------------
    # Delegated Methods

    delegate method expand to macro
    delegate method eval   to macro
    delegate method lb     to macro
    delegate method rb     to macro

    #---------------------------------------------------------------------
    # Other Public Methods

    # format indir ?options...?
    #
    # indir    - The input manpage directory
    #
    # Options:
    #    -header  - Header text for all manpages
    #    -outdir  - Output directory; defaults to input directory.
    #
    # Processes all *.manpage files in the current directory,
    # which is assumed to be called "man$suffix", e.g., "mann".

    method format {indir args} {
        # FIRST, get the options
        set trans(header) "Software Man Page"
        set outdir $indir

        while {[llength $args] > 0} {
            set opt [lshift args]
            switch -exact -- $opt {
                -header { set trans(header) [lshift args]  }
                -outdir { set outdir [lshift args]         }
                default { error "Unknown option: \"$opt\"" }
            }
        }

        # NEXT, set up transient data that spans multiple manpages
        set pagesec [$self GetManSection $indir]
        set trans(docroot)  [file dirname $outdir]
        set trans(manpages) [list]
        
        # FIRST, set up the transient data.
        set trans(manpages) [list]
        set trans(manpage)  ""

        # NEXT, process the files
        foreach filename [glob -nocomplain [file join $indir *.manpage]] {
            # FIRST, reset the macro processor for each file.
            $self ResetMacros

            # NEXT, process this file.
            set trans(filename) [file tail $filename]
            set pagename [file rootname $trans(filename)]
            set outpath \
                [file join $trans(docroot) man$pagesec $pagename.html]

            puts "Writing $outpath"
            writefile $outpath [$macro expandfile $filename]
        }

        # TBD: Write the index
    }

    # GetManSection indir
    #
    # indir   - The input directory
    #
    # Gets the input manpage section code from the input directory name.

    method GetManSection {indir} {
        set dir [file tail $indir]

        if {[string match man* $dir]} {
            return [string range $dir 3 end]
        } else {
            return n
        }
    }

    # ResetMacros
    #
    # Resets the macro processor's interpreter.

    method ResetMacros {} {
        # FIRST, reset it.
        $macro reset

        # NEXT, define our own macros.
        $self DefineLocalMacros
    }

    # DefineLocalMacros
    #
    # Defines the default manpage set, which is quite small.

    method DefineLocalMacros {} {
        # FIRST, define some standard HTML tags
        foreach tag {
            b i code tt pre em strong 
        } {
            $self StyleTag $tag
        }

        $self Identity p
        $self Identity /p

        # NEXT, define brackets
        $macro proc lb {} { return "&lt;"}
        $macro proc rb {} { return "&gt;"}

        # NEXT, manpage-specific macros
        $macro smartalias manpage {name title ?parent?} 2 3 \
            [mymethod Manpage]

        $macro smartalias /manpage {} 0 0 \
            [mymethod /Manpage]
    }

    #---------------------------------------------------------------------
    # Manpage Macros

    method Manpage {name title {parent ""}} {
        # Pass 1: Catalog the page and return.
        if {[$macro pass] == 1} {
            # FIRST, have we already set the page's name?
            if {$trans(manpage) ne ""} {
                error "encountered two <manpage> macros in this file"
            }

            # NEXT, Save the manpage name
            set trans(manpage) $name

            # NEXT, Validate the name and the parent manpage name
            manref validate $name

            if {$parent ne ""} {
                manref validate $parent
            }
            
            # NEXT, have we seen this page name before?
            if {$name in $trans(manpages)} {
                error "encountered two manpage(5) files with the same name."
            }

            # NEXT, save the index info
            if {$parent eq ""} {
                ladd trans(manpages) $name
            } else {
                if {![info exists trans(children-$parent)]} {
                    set trans(children-$parent) [list]
                }

                ladd trans(children-$parent) $name
            }

            return
        }

        # Pass 2: Format the Output
        # FIXME: Allow user to specify project name
        append result                        \
            "<html>\n"                       \
            "<head>\n"                       \
            "<title>$name: $title</title>\n" \
            "<style>\n"                      \
            "<!--\n"                         \
            $manpageCSS                      \
            "-->\n"                          \
            "</style>\n"                     \
            "</head>\n"                      \
            "<body>\n"                       \
            "<h1 class=\"header\">$trans(header)</h1>\n"

        if {$parent ne ""} {
            append result \
                "<h1>$name: $title -- [$self Xref $parent]</h1>\n"
        } else {
            append result \
                "<h1>$name: $title</h1>\n"
        }

        append result  \
            "\n"       \
            [$self Contents] \
            "\n"

        return $result
    }

    method Contents {} {
        return
    }

    method /Manpage {} {
        # Pass 1: Make sure we've got a <<manpage>>.
        if {[$macro pass] == 1} {
            # FIRST, have we set the page's name?
            if {$trans(manpage) eq ""} {
                error "encountered </manpage> before <manpage> in this file"
            }

            return
        }

        # Pass 2: Format the Output
        set ts [clock format [clock seconds]]
        set fname [file tail $trans(filename)]

        append result \
            "<hr class=\"outdent\">\n"                \
            "<span class=\"outdent\">\n"              \
            "<i>Generated from $fname on $ts</i>\n"   \
            "</span>\n"                               \
            "</body>\n"                               \
            "</html>\n"

        return $result
    }

    method Xref {args} {
        return
    }

    #---------------------------------------------------------------------
    # Helpers

    # Identity tag
    #
    # Defines a macro that expands to the same named HTML tag.

    method Identity {tag} {
        $macro proc $tag {} [format {
            return "<%s>"
        } $tag]
    }

    # StyleTag tag
    #
    # tag   - A style tag name
    #
    # Defines a tag macros.

    method StyleTag {tag} {
        $macro proc $tag {args} [format {
            if {[llength $args] == 0} {
                return "<%s>"
            } else {
                return "<%s>$args</%s>"
            }
        } $tag $tag $tag]

        $macro proc /$tag {} [format {
            return "</%s>"
        } $tag]
    }
}







