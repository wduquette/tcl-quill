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
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #---------------------------------------------------------------------
    # Lookup Tables

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
            background-color: red;
            color: black;
        }

        /* Use for indenting */
        .indent0 { 
            position: relative;
            left: 0.25in
        }
        .indent1 {
            position: relative;
            left: 0.5in
        }
        .indent2 {
            position: relative;
            left: 0.75in
        }
        .indent3 {
            position: relative;
            left: 1.0in
        }
        .indent4 {
            position: relative;
            left: 1.25in
        }
        .indent5 {
            position: relative;
            left: 1.5in
        }
        .indent6 {
            position: relative;
            left: 1.75in
        }
        .indent7 {
            position: relative;
            left: 2.0in
        }
        .indent8 {
            position: relative;
            left: 2.25in
        }
        .indent9 {
            position: relative;
            left: 2.5in
        }

        /* Styles for macroset_html(n) */

        tr.topicrow  { vertical-align: baseline; }
        td.topicname { font-weight: bold;        }

        div.box {
            border: 1px solid blue;
            background-color: #DEF4FA;
            padding: 2px;
        }

        pre.example {
            border: 1px solid blue;
            background-color: #FAF5D2;
            padding: 2px;
        }

        pre.listing {
            border: 1px solid blue;
            background-color: #FAF5D2;
            padding: 2px;
        }

        span.linenum {
            background-color: #DEDC87;
        }

        div.mark {
            font-family: Verdana;
            font-size: 75%;
            border: 1px solid black;
            background-color: black;
            color: white;
            border-radius: 10px;
            padding-left: 2px;
            padding-right: 2px;
            display: inline;
        }

        div.bigmark {
            font-family: Verdana;
            font-size: 100%;
            border: 1px solid black;
            background-color: black;
            color: white;
            border-radius: 10px;
            padding-left: 2px;
            padding-right: 2px;
            display: inline;
        }

    }


    #---------------------------------------------------------------------
    # Type Components

    typevariable macro ""  ;# The macro(n) object


    #---------------------------------------------------------------------
    # Type Variables

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
    # toc           - 1 if we have table of contents, and 0 otherwise.
    # ids           - List of section IDs, in the order of definition.
    # stype-$id     - Section type: preface|section|appendix
    # title-$id     - Section title
    # number-$id    - Assigned after pass 1; "" for preface sections
    # linktext-$id  - Assigned after pass 1; default link text.

    typevariable trans -array {}

    #---------------------------------------------------------------------
    # Delegated Type Methods

    delegate typemethod expand to macro
    delegate typemethod eval   to macro
    delegate typemethod lb     to macro
    delegate typemethod rb     to macro

    #---------------------------------------------------------------------
    # Other Public Type Methods

    # reset
    #
    # Creates and initializes the macro(n) object.

    typemethod reset {} {
        # FIRST, create the macro processor.
        if {$macro eq ""} {
            set macro [macro ${type}::macro \
                        -passcommand [mytypemethod PassCmd] \
                        -brackets    {< >}]
            $macro macroset ::quill::macroset_html
        }

        # NEXT, set up the macros.
        $type ResetMacros
    }

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

    typemethod format {infile args} {
        # FIRST, get the options
        array unset trans
        set trans(infile) $infile
        set outfile       [file rootname $infile].html
        set trans(header) "Project Documentation"
        set trans(version) 0.0.0
        set trans(manroot) "."
        set trans(toc)     0
        set trans(ids)     {}

        foroption opt args -all {
            -outfile { set trans(outfile) [lshift args]}
            -header  { set trans(header)  [lshift args]  }
            -version { set trans(version) [lshift args] }
            -manroot { set trans(manroot) [lshift args] }
        }
        
        # NEXT, Reset the macro processor; this will create it, if
        # needed, and define all macros.
        $type reset

        writefile $outfile [$macro expandfile $infile]
    }

    # PassCmd
    #
    # This command assigns all section numbers and computes all link text.

    typemethod PassCmd {} {
        set nums [list 0]

        set pid ""
        set plevel 0
        set ptype  ""
        foreach id $trans(ids) {
            set level [IdLevel $id]
            set stype $trans(stype-$id)

            if {$stype ne $ptype} {
                set nums [list 0]
            } elseif {$level > $plevel} {
                lappend nums 0
            } elseif {$level < $plevel} {
                set nums [lrange $nums 0 $level]
            }

            set digit [lindex $nums $level]
            lset nums $level [expr {$digit + 1}]

            set fullnum [join $nums .]

            if {$level == 0} {
                append fullnum "."
            }

            switch $trans(stype-$id) {
                preface {
                    set trans(number-$id) ""
                    set trans(linktext-$id) $trans(title-$id)
                }

                section {
                    set trans(number-$id) $fullnum
                    set trans(linktext-$id) [string trimright $fullnum .]
                }

                appendix {
                    set fullnum [AppendixNum $fullnum]
                    set trans(number-$id) $fullnum
                    set trans(linktext-$id) [string trimright $fullnum .]
                }

                default {
                    error "Unknown section type: \"$trans(stype-$id)\""
                }
            }

            set pid    $id
            set plevel $level
            set ptype  $stype
        }
    }

    #---------------------------------------------------------------------
    # Macro Management

    # ResetMacros
    #
    # Resets the macro processor's interpreter.

    typemethod ResetMacros {} {
        # FIRST, reset it.
        $macro reset

        # NEXT, define our own macros.
        $type DefineLocalMacros
    }

    # DefineLocalMacros
    #
    # Defines the default macro set.
    #
    # TODO: Factor out common manpage(5)/quilldoc(5) macros.

    typemethod DefineLocalMacros {} {
        # FIRST, document structure macros.
        $macro smartalias document {title} 1 1 \
            [myproc document]

        $macro smartalias contents {} 0 0 \
            [myproc contents]

        $macro smartalias preface {id title} 2 2 \
            [myproc preface]

        $macro smartalias section {id title} 2 2 \
            [myproc section]

        $macro smartalias appendix {id title} 2 2 \
            [myproc appendix]

        $macro smartalias /document {} 0 0 \
            [myproc /document]

        # NEXT, cross-references.
        $macro smartalias xref {pageref ?text?} 1 2 \
            [myproc xref]

        # NEXT, other macros

        $macro smartalias version {} 0 0 \
            [myproc version]

    }

    #---------------------------------------------------------------------
    # Document Macros

    # document title
    #
    # title  - The document title
    #
    # Begins a document.

    proc document {title} {
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

    proc /document {} {
        if {[$macro pass] == 1} {
            return
        }

        # Pass 2: Format the Output
        set ts [clock format [clock seconds]]
        set fname [file tail $trans(infile)]

        append result \
            "<hr>\n"                \
            "<span>\n"              \
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

    proc preface {id title} {
        # Pass 1: Catalog this section.
        if {[$macro pass] == 1} {
            # FIRST, validate the id

            CheckSyntax $id
            CheckUniqueness $id
            CheckPrevious $id preface {preface}
            CheckLevel $id preface

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

    proc section {id title} {
        # Pass 1: Catalog this section.
        if {[$macro pass] == 1} {
            # FIRST, validate the id
            CheckSyntax $id
            CheckUniqueness $id
            CheckPrevious $id section {preface section}
            CheckLevel $id section

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

    proc appendix {id title} {
        # Pass 1: Catalog this section.
        if {[$macro pass] == 1} {
            # FIRST, validate the id
            CheckSyntax $id
            CheckUniqueness $id
            CheckPrevious $id appendix {preface section appendix}
            CheckLevel $id appendix

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

    # contents ?depth?
    #
    # depth - Max number of levels to include in table.
    #
    # Formats the table of contents.

    proc contents {{depth 4}} {
        # Pass 1: do nothing
        if {[$macro pass] == 1} {
            set trans(toc) 1
            return
        }

        # Pass 2: Format the section table of contents
        set result "<h2><a name=\"_toc\">Table of Contents</a></h2>\n\n"

        foreach id $trans(ids) {
            set level [IdLevel $id]
            if {$level >= $depth} {
                continue
            }

            set level [expr {min($level,9)}]
            set indent "indent$level"

            if {$trans(stype-$id) eq "preface"} {
                set linktext $trans(title-$id)
            } else {
                set linktext "$trans(number-$id) $trans(title-$id)"
            }

            set link "<a href=\"#$id\">$linktext</a>"

            if {$depth == 0} {
                append result "$link<br>\n"
            } else {
                append result \
                "<span class=\"$indent\">$link</span><br>\n" 
            }
        }

        append result "<p>"

        return $result
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

    proc xref {ref {text ""}} {
        # Pass 1: Do nothing
        if {[$macro pass] == 1} {
            return
        }

        # Pass 2: Format the link.

        # FIRST, if it's a section ID, just return in the link.
        if {$ref in $trans(ids)} {
            set href "#$ref"
            if {$text eq ""} {
                set text $trans(linktext-$ref)
            }

            return "<a href=\"$href\">$text</a>"
        }

        set pageref [split $ref "#"]
        lassign $pageref pageId anchor

        if {[llength $pageref] > 2 || $pageId eq ""} {
            throw INVALID "Invalid xref: \"$ref\""
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
        } elseif {[manpage::manref parse $pageId name num]} {
            if {$trans(manroot) eq ""} {
                throw INVALID "Invalid xref, man page references are not enabled."
            }
            set url "$trans(manroot)/man$num/$name.html"
        } else {
            # FIXME: Need a better mechanism for warnings
            puts "Warning: Unrecognized xref \"$ref\"\n in $trans(infile)"
            return "<b>&lt;xref [list $ref]&gt;</b>"
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

    proc version {} {
        return $trans(version)
    }

    #---------------------------------------------------------------------
    # Helpers

    # Identity tag
    #
    # Defines a macro that expands to the same named HTML tag.

    proc Identity {tag} {
        $macro proc $tag {} [format {
            return "<%s>"
        } $tag]
    }

    # StyleTag tag
    #
    # tag   - A style tag name
    #
    # Defines style tag macros.

    proc StyleTag {tag} {
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

    proc CheckSyntax {id} {
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

    proc CheckUniqueness {id} {
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

    proc CheckPrevious {id stype stypes} {
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

    proc CheckLevel {id stype} {
        # FIRST, analyze the ID
        set segments  [split $id .]
        set level     [IdLevel $id]

        # NEXT, analyze the previous ID
        set pid [lindex $trans(ids) end]
        
        if {$pid ne ""} {
            set ptype     $trans(stype-$pid)
            set psegments [split $pid .]
            set plevel    [IdLevel $pid]
        } else {
            set ptype ""
        }

        # NEXT, if it's a preface it can't be a child.
        if {$stype eq "preface" && $level > 0} {
            throw INVALID [outdent "
                Invalid section level: '$id' is a level $level section ID,
                but preface sections cannot have subsections.
            "]
        }

        # NEXT, if the IDs are of different types, this must be
        # a toplevel ID.
        if {$stype ne $ptype && $level != 0} {
            throw INVALID [outdent "
                Invalid section level: '$id' is a level $level section ID, but
                as the first $stype in the document it must be a 
                level 0 ID.
            "]
        }

        # NEXT, if this is a toplevel section, we're good.
        if {$level == 0} {
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
                    Section ID '$id' cannot logically follow section '$pid'.
                "] 
            }

            incr i
        }

        return
    }

    # IdLevel id
    #
    # Returns the level of the ID, which is 1 less than the number of
    # segments.

    proc IdLevel {id} {
        expr {[llength [split $id .]] - 1}
    }

    # Header id title
    #
    # id     - A section ID
    # title  - A section title
    #
    # Outputs returns an HTML header appropriate for the section level.

    proc Header {id title} {
        set level [IdLevel $id]

        if {$trans(toc)} {
            set href { href="#_toc"}
        } else {
            set href ""
        }

        if {$level == 0} {
            return "<h2><a name=\"$id\"$href>$title</a></h2>\n"
        } else {
            return "<h3><a name=\"$id\"$href>$title</a></h3>\n"
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







