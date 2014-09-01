#-------------------------------------------------------------------------
# TITLE: 
#    quilldoc.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl
#
# DESCRIPTION:
#    quilldoc(n): document processor built on macro(n).
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Namespace Exports

namespace eval ::quill:: {
    namespace export \
        quilldoc
}

#-------------------------------------------------------------------------
# quilldoc singleton

snit::type ::quill::quilldoc {
    #---------------------------------------------------------------------
    # Lookup Tables

    # TODO: Devise an HTML-base on top of macro(n)?
    typevariable quilldocCSS {
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

        h3 {
            position: relative;
            left: -0.2in;
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
    # Instance Variables

    # trans array: Transient data
    #
    # infile   - The input file name.
    # header   - Header for the page
    # version  - Project version
    # manroot  - Root directory for manpage references

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

    # format infile ?options...?
    #
    # infile    - The input .quilldoc file
    #
    # Options:
    #    -outfile - Output file name.
    #    -header  - Header text for banner
    #    -version - Project version string for packages.
    #    -manroot - Root directory for man page xrefs.
    #
    # Processes the infile, producing the outfile, which defaults to
    # the same name with an extension of ".html".

    method format {infile args} {
        # FIRST, get the options
        set trans(infile) $infile
        set outfile       [file rootname $infile].html
        set trans(header) "Project Documentation"
        set trans(version) 0.0.0
        set trans(manroot) ""

        foroption opt args -all {
            -outfile { set trans(outfile) [lshift args]}
            -header  { set trans(header)  [lshift args]  }
            -version { set trans(version) [lshift args] }
            -manroot { set trans(manroot) [lshift args] }
        }
        
        # NEXT, process the file
        $self ResetMacros

        writefile $outfile [$macro expandfile $infile]
    }

    #---------------------------------------------------------------------
    # Macro Management

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
    # Defines the default macro set.
    #
    # TODO: Factor out common manpage(5)/quilldoc(5) macros.

    method DefineLocalMacros {} {
        # FIRST, document structure macros.
        $macro smartalias document {title} 1 1 \
            [mymethod macro document]

        $macro smartalias contents {} 0 0 \
            [mymethod macro contents]

        $macro smartalias preface {id title} 2 2 \
            [mymethod macro preface]

        $macro smartalias section {id title} 2 2 \
            [mymethod macro section]

        $macro smartalias appendix {id title} 2 2 \
            [mymethod macro appendix]

        $macro smartalias /document {} 0 0 \
            [mymethod macro /document]

        # NEXT, cross-references.
        $macro smartalias xref {pageref ?text?} 1 2 \
            [mymethod macro xref]

        $macro proc link {url {text ""}} {
            if {$text eq ""} {
                set text $url
            }

            return "<a href=\"$url\">$text</a>"
        }


        # NEXT, standard HTML tags

        foreach tag {
            b i code tt pre em strong 
        } {
            $self StyleTag $tag
        }

        foreach tag {
            p ul ol li
        } {
            $self Identity $tag
            $self Identity /$tag
        }


        # NEXT, definition list tags.
        $macro smartalias deflist {?args...?} 0 - \
            [mymethod macro deflist]

        $macro smartalias def {text} 1 1 \
            [mymethod def]

        $macro smartalias /deflist {} 0 0 \
            [mymethod /deflist]


        # NEXT, other macros
        $macro proc lb {} { return "&lt;"}
        $macro proc rb {} { return "&gt;"}

        $macro smartalias version {} 0 0 \
            [mymethod version]
    }

    #---------------------------------------------------------------------
    # Document Macros

    # document title
    #
    # title  - The document title
    #
    # Begins a document.

    method {macro document} {title} {
        # Pass 1: Catalog the page and return.
        if {[$macro pass] == 1} {
            return
        }

        # Pass 2: Format the Output
        # FIXME: Allow user to specify project name
        append result                        \
            "<html>\n"                       \
            "<head>\n"                       \
            "<title>$title</title>\n"        \
            "<style>\n"                      \
            "<!--\n"                         \
            $quilldocCSS                     \
            "-->\n"                          \
            "</style>\n"                     \
            "</head>\n"                      \
            "<body>\n"                       \
            "<h1 class=\"header\">$trans(header)</h1>\n"

        append result \
            "<h1>[$macro expandonce $title]</h1>\n"

        return $result
    }

    # /document
    #
    # Terminates a document, and provides the footer.

    method {macro /document} {} {
        if {[$macro pass] == 1} {
            return
        }

        # Pass 2: Format the Output
        set ts [clock format [clock seconds]]
        set fname [file tail $trans(infile)]

        append result \
            "<hr class=\"outdent\">\n"                \
            "<span class=\"outdent\">\n"              \
            "<i>Generated from $fname on $ts</i>\n"   \
            "</span>\n"                               \
            "</body>\n"                               \
            "</html>\n"

        return $result
    }

    #---------------------------------------------------------------------
    # Man Page Sections and Subsections

    # section id title
    #
    # id      - The section ID
    # title   - The section title
    #
    # Produces the section header, and provides for cross-references

    method {macro section} {id title} {
        # Pass 1: Catalog this section.
        if {[$macro pass] == 1} {
            # TBD
            return
        }

        # Pass 2: Produce the section header and anchor
        set title [$macro expandonce $title]
        return "<h2><a name=\"$id\">$title</a></h2>\n"
    }


    # Contents
    #
    # Formats the section/subsection table of contents.  This is
    # used automatically by Manpage.

    method Contents {} {
        # Pass 1: do nothing
        if {[$macro pass] == 1} {
            return
        }

        # Pass 2: Format the section table of contents
        set result ""

        foreach item $trans(sections) {
            lassign $item depth title

            if {$depth == 0} {
                append result "[$self Xref #$title]<br>\n"
            } else {
                append result \
                "<span class=\"indent1\">[$self Xref #$title]</span><br>\n" 
            }
        }

        append result "<p>"

        return $result
    }

    #---------------------------------------------------------------------
    # Definition Lists

    # deflist args...
    #
    # args   - Arbitrary text identifying the deflist.
    #
    # Begins a definition list.  The args are ignored,
    # but are convenient for matching up the deflist with
    # its /deflist.

    method deflist {args} {
        return "<dl>\n"
    }

    # def text
    #
    # text   - The text to define.
    #
    # Begins documentation for the definition item.

    method def {text} {
        # pass 1: do nothing for now.
        if {[$macro pass] == 1} {
            return
        }
        
        # pass 2: Format the item.
        set text [$macro expandonce $text]
        return "<dt><b>$text</b><dd>\n"
    }


    # /deflist args...
    #
    # args  - Arbitrary text identifying the deflist.
    #
    # Ends a definition list.  The args are ignored,
    # but are convenient for matching up the deflist with
    # its /deflist, especially when deflists are nested.

    method /deflist {args} {
        return "</dl>\n"
    }


    #---------------------------------------------------------------------
    # Cross-References

    # xref ref ?text?
    #
    # ref     - A string that names an external page in some way
    # text    - The link text.
    #
    # Creates a cross-reference link based on the ref.  If ?text?
    # is given, it's used as the link text; otherwise, the link text
    # is determined from the ref as described below.
    #
    # Refs may take the following forms:
    #
    #   sectionID      - A preface, section, or appendix ID.  Links to the
    #                    section.  The default link text is as follows:
    #     
    #                    preface  - The section title
    #                    section  - Section <num>
    #                    appendix - Appendix <num>
    #
    #   <name>(<sec>)  - Links to $manroot/man$sec/$name.html.  The 
    #                    default link text is the manpage name.  The
    #                    ref may include an "#anchor".
    #
    #   http...        - Links to the URL.  The default link text is the
    #                    URL.  The ref may includ an "#anchor".
    #

    # FIXME
    method xref {pageref {text ""}} {
        # Pass 1: Do nothing
        if {[$macro pass] == 1} {
            return
        }

        # Pass 2: Parse the pageref, and format the link.
        set pageref [split  $pageref "#"]
        lassign $pageref pageId anchor

        if {[llength $pageref] > 2 || $pageId eq "" && $anchor eq ""} {
            error "Invalid pageref: \"$pageref\""
        }

        # Set the link text, if not set.
        if {$text eq ""} {
            if {$anchor ne ""} {
                set text $anchor
            } else {
                set text $pageId
            }
        }

        # Next, determine the URL
        if {$pageId eq ""} {
            set url ""
        } elseif {[string match "http*" $pageId]} {
            set url $pageId
        } elseif {[manref parse $pageId name num]} {
            set url "../man$num/$name.html"
        } else {
            error "Unrecognized pageId: \"$pageId\""
        }

        # Next, make sure we know the anchor
        if {$pageId eq ""} {
            if {![$self AnchorExists $anchor]} {
                puts "Warning: unknown anchor, \"$anchor\""
            }
        }

        if {$anchor ne ""} {
            return "<a href=\"$url#$anchor\">$text</a>"
        } else {
            return "<a href=\"$url\">$text</a>"
        }
    }

    #---------------------------------------------------------------------
    # Other Macros

    # version
    #
    # Returns the project version number, as given by the -version
    # option.

    method version {} {
        return $trans(version)
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
    # Defines style tag macros.

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







