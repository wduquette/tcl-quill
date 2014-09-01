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
        }

        /* For the page header */
        h1.header {
            position: relative;
            background-color: red;
            color: black;
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
    # This array is initialized by [quilldoc format], and used
    # during the formatting process.
    #
    # infile        - The input file name.
    # header        - Header for the page
    # version       - Project version
    # manroot       - Root directory for manpage references
    #
    # ids           - List of section IDs, in the order of definition.
    # stype-$id     - Section type: preface|section|appendix
    # title-$id     - Section title
    # number-$id    - Assigned after pass 1; "" for preface sections
    # linktext-$id  - Assigned after pass 1; default link text.

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
            -passcommand [mymethod PassCmd]        \
            -brackets    {< >}

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
        array unset trans
        set trans(infile) $infile
        set outfile       [file rootname $infile].html
        set trans(header) "Project Documentation"
        set trans(version) 0.0.0
        set trans(manroot) ""
        set trans(ids)     {}

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

    # PassCmd
    #
    # This command assigns all section numbers and computes all link text.

    method PassCmd {} {
        set nums [list 0]

        set pid ""
        set pidx 0
        set ptype  ""
        foreach id $trans(ids) {
            # The idx is the index of the level in $nums.
            set idx [expr {[llength [split $id .]] - 1}]
            set stype $trans(stype-$id)

            if {$stype ne $ptype} {
                set nums [list 0]
            } elseif {$idx > $pidx} {
                lappend nums 0
            } elseif {$idx < $pidx} {
                set nums [lrange $nums 0 $idx]
            }

            set digit [lindex $nums $idx]
            lset nums $idx [expr {$digit + 1}]

            set fullnum [join $nums .]

            if {$idx == 0} {
                append fullnum "."
            }

            switch $trans(stype-$id) {
                preface {
                    set trans(number-$id) ""
                    set trans(linktext-$id) $trans(title-$id)
                }

                section {
                    set trans(number-$id) $fullnum
                    set trans(linktext-$id) "Section $fullnum"
                }

                appendix {
                    set fullnum [AppendixNum $fullnum]
                    set trans(number-$id) $fullnum
                    set trans(linktext-$id) "Appendix $fullnum"
                }

                default {
                    error "Unknown section type: \"$trans(stype-$id)\""
                }
            }

            set pid   $id
            set pidx  $idx
            set ptype $stype
        }
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
        set title [$macro expandonce $title]

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
            "<h1>$title</h1>\n"

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

    # preface id title
    #
    # id      - The section ID
    # title   - The section title
    #
    # Produces the section header, and provides for cross-references

    method {macro preface} {id title} {
        # Pass 1: Catalog this section.
        if {[$macro pass] == 1} {
            # FIRST, validate the id
            $self CheckSyntax $id
            $self CheckUniqueness $id
            $self CheckPrevious $id preface {preface}
            $self CheckLevel $id preface

            # NEXT, save the data.
            lappend trans(ids) $id
            set trans(stype-$id) preface
            set trans(title-$id) $title
            return
        }

        # Pass 2: Produce the section header and anchor
        set title [$macro expandonce $title]
        return [Header $id $title]
    }

    # section id title
    #
    # id      - The section ID
    # title   - The section title
    #
    # Produces the section header, and provides for cross-references

    method {macro section} {id title} {
        # Pass 1: Catalog this section.
        if {[$macro pass] == 1} {
            # FIRST, validate the id
            $self CheckSyntax $id
            $self CheckUniqueness $id
            $self CheckPrevious $id section {preface section}
            try {
                $self CheckLevel $id section
            } on error {result} {
                puts "Error: $result\n$::errorInfo"
            }

            # NEXT, save the data.
            lappend trans(ids) $id
            set trans(stype-$id) section
            set trans(title-$id) $title
            return
        }

        # Pass 2: Produce the section header and anchor
        set title [$macro expandonce $title]
        return [Header $id "$trans(number-$id) $title"]
    }

    # appendix id title
    #
    # id      - The section ID
    # title   - The section title
    #
    # Produces the section header, and provides for cross-references

    method {macro appendix} {id title} {
        # Pass 1: Catalog this section.
        if {[$macro pass] == 1} {
            # FIRST, validate the id
            $self CheckSyntax $id
            $self CheckUniqueness $id
            $self CheckPrevious $id appendix {preface section appendix}
            $self CheckLevel $id appendix

            # NEXT, save the data.
            lappend trans(ids) $id
            set trans(stype-$id) appendix
            set trans(title-$id) $title
            return
        }

        # Pass 2: Produce the section header and anchor
        set title [$macro expandonce $title]
        return [Header $id "$trans(number-$id) $title"]
    }

    # contents
    #
    # Formats the section/subsection table of contents.  This is
    # used automatically by Manpage.

    method contents {} {
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

    # CheckIdSyntax id
    #
    # id    - The ID
    #
    # Throws INVALID if a section ID is syntactically incorrect.

    method CheckSyntax {id} {
        # FIRST, validate the segments
        foreach segment [split $id .] {
            if {![regexp {^[a-z]\w*$} $segment]} {
                throw INVALID "Invalid section ID: \"$id\""
            }
        }
    }

    # CheckUniqueness id
    #
    # Checks whether the ID is already in use.

    method CheckUniqueness {id} {
        if {$id in $trans(ids)} {
            throw INVALID "Duplicate section ID: \"$id\""
        }
    }

    # CheckPrevious id stypes
    #
    # id      - The section ID
    # stype   - This section's stype
    # stypes  - Valid stypes
    #
    # Throws INVALID if the previous section type is non-empty and
    # not one of the listed types.

    method CheckPrevious {id stype stypes} {
        # FIRST, any section type can come first.
        if {![got $trans(ids)]} {
            return
        }

        # NEXT, check previous section's type.
        set prev  [lindex $trans(ids) end]
        set ptype $trans(stype-$prev)

        if {$ptype ni $stypes} {
            set stype [Article $stype]
            set ptype [Article $ptype]
            throw INVALID [outdent "
                $is is $stype, and $stype cannot follow a $ptype.
            "]
        }
    }

    # CheckLevel id stype
    #
    # id      - The section ID
    # stype   - This section's stype
    #
    # Verifies that this ID doesn't break the logical structure
    # of the document.

    method CheckLevel {id stype} {
        # FIRST, analyze the ID
        set segments  [split $id .]
        set level     [llength $segments]

        # NEXT, analyze the previous ID
        set pid [lindex $trans(ids) end]
        
        if {$pid ne ""} {
            set ptype     $trans(stype-$pid)
            set psegments [split $pid .]
            set plevel    [llength $psegments]
        } else {
            set ptype ""
        }

        # NEXT, if it's a preface it can't be a child.
        if {$stype eq "preface" && $level > 1} {
            throw INVALID [outdent "
                Invalid section level: $id is a level $level section ID,
                but preface sections cannot have subsections.
            "]
        }

        # NEXT, if the IDs are of different types, this must be
        # a toplevel ID.
        if {$stype ne $ptype && $level != 1} {
            throw INVALID [outdent "
                Invalid section level: $id is a level $level section ID, but
                as the first $stype in the document it must be a 
                level 1 ID.
            "]
        }

        # NEXT, if this is a toplevel section, we're good.
        if {$level == 1} {
            return
        }

        # NEXT, it's a child.  Is it a valid child of a previous section?
        # All segments but the last must match the segments of the previous
        # section.

        set i 0
        foreach segment [lrange $segments 0 end-1] {
            set psegment [lindex $psegments $i]
            if {$segment ne $psegment} {
                throw INVALID [outdent "
                    Section ID $id cannot logically follow section $prev.
                "] 
            }

            incr i
        }

        return
    }

    # Header id title
    #
    # id     - A section ID
    # title  - A section title
    #
    # Outputs returns an HTML header appropriate for the section level.

    proc Header {id title} {
        set level [llength [split $id .]]

        if {$level == 1} {
            return "<h2><a name=\"$id\">$title</a></h2>\n"
        } else {
            return "<h3><a name=\"$id\">$title</a></h3>\n"
        }
    }

    # Article thing
    #
    # Adds "a" or "an" to the thing.

    proc Article {thing} {
        if {[string index $thing 0] in {a e i o u}} {
            return "an $thing"
        } else {
            return "a $thing"
        }
    }

    # AppendixNum num
    #
    # num   - A numeric section number.
    #
    # Replaces the first digit with a letter.

    proc AppendixNum {num} {
        set map "ABCEDFGHIJKLMNOPQRSTUVWXYZ"
        set len [string length $map]

        set nums [split $num .]
        set first [expr {[lindex $nums 0] - 1}]

        set letter ""

        while {$first >= 0} {
            set idx [expr {$first % $len}]
            append letter [string index $map $idx]
            incr first -$len
        }

        lset nums 0 $letter

        return [join $nums .]


    }
}







