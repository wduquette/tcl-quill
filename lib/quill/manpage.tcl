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
    pragma -hasinstances no -hastypedestroy no

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

        h3 {
            position: relative;
            left: -0.2in;
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
    # Type Variables

    typevariable macro ""  ;# The macro(n) object


    # manSections: Array of man page section titles by section directory.
    typevariable manSections -array {
        man1 "Section 1: Applications"
        man5 "Section 5: File Formats"
        mann "Section n: Tcl Packages"
        mani "Section i: Tcl Interfaces"
    }

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
    #   title-$name     - Title for manpage $name
    #
    # Information for the current manpage.
    #
    #   filename        - The current manpage's filename.
    #   manpage         - The manref of the current manpage.
    #   section         - The current section
    #   sections        - A list of the sections in this page.  Each 
    #                     entry is a list, {depth title}, where depth
    #                     is 0 or 1.
    #   anchors         - A list of the anchors defined for this page.
    #   items           - A list of the synopsis items defined for this
    #                     page.  Each entry is a list, {depth name text}.
    #   deflistLevel    - How deeply nested deflists are

    typevariable trans -array {
    }

    #---------------------------------------------------------------------
    # Delegated Methods

    delegate typemethod expand to macro
    delegate typemethod eval   to macro
    delegate typemethod lb     to macro
    delegate typemethod rb     to macro

    #---------------------------------------------------------------------
    # Other Public Methods

    # format indir ?options...?
    #
    # indir    - The input manpage directory
    #
    # Options:
    #    -header  - Header text for all manpages
    #    -version - Project version string for packages.
    #    -outdir  - Output directory; defaults to input directory.
    #
    # Processes all *.manpage files in the current directory,
    # which is assumed to be called "man$suffix", e.g., "mann".

    typemethod format {indir args} {
        # FIRST, get the options
        set trans(header) "Software Man Page"
        set trans(version) 0.0.0
        set outdir $indir

        foroption opt args -all {
            -header  { set trans(header) [lshift args]  }
            -outdir  { set outdir [lshift args]         }
            -version { set trans(version) [lshift args] }
        }

        # NEXT, set up transient data that spans multiple manpages
        set pagesec [GetManSection $indir]
        set trans(docroot)  [file dirname $outdir]
        set trans(manpages) [list]
        
        # NEXT, process the files
        foreach filename [glob -nocomplain [file join $indir *.manpage]] {
            # FIRST, reset the macro processor for each file.
            $type ResetMacros

            # NEXT, set up the transient data for this page
            set trans(manpage)      ""
            set trans(section)      ""
            set trans(anchors)      [list]
            set trans(sections)     [list]
            set trans(items)        [list]
            set trans(deflistLevel) -1

            # NEXT, process this file.
            set trans(filename) [file tail $filename]
            set pagename [file rootname $trans(filename)]
            set outpath [file join $outdir $pagename.html]

            puts "Writing $outpath"
            writefile $outpath [$macro expandfile $filename]
        }

        # NEXT, Write the index
        CreateIndex $outdir
    }

    # GetManSection indir
    #
    # indir   - The input directory
    #
    # Gets the input manpage section code from the input directory name.

    proc GetManSection {indir} {
        set dir [file tail $indir]

        if {[string match man* $dir]} {
            return [string range $dir 3 end]
        } else {
            return n
        }
    }

    # CreateIndex
    #
    # Creates an index of the man pages in this directory.

    proc CreateIndex {outdir} {
        set manDir [file tail $outdir]

        if {[info exists manSections($manDir)]} {
            set title $manSections($manDir)
        } else {
            set title "Man Pages"
        }

        set ts [clock format [clock seconds]]

        append result                                    \
            "<html>\n"                                   \
            "<head>\n"                                   \
            "<title>$title</title>\n"                    \
            "<style>\n"                                  \
            "<!--\n"                                     \
            $manpageCSS                                  \
            "-->\n"                                      \
            "</style>\n"                                 \
            "</head>\n"                                  \
            "<body>\n"                                   \
            "<h1 class=\"header\">$trans(header)</h1>\n" \
            "<h1>$title</h1>\n"                          \
            "\n"                                         \
            [LinksToChildren ""]                   \
            "<p><hr class=\"outdent\">\n"                \
            "<span class=\"outdent\">\n"                 \
            "<i>Generated on $ts</i>\n"                  \
            "</span>\n"                                  \
            "</body>\n"                                  \
            "</html>\n"

        set fname [file join $outdir index.html]
        puts "Writing $fname"
        writefile $fname $result
    }

    # LinksToChildren parent
    #
    # parent  - "", or a manpage with children
    #
    # Creates a bulleted list of links to child man pages, recursing if
    # a child also has children.

    proc LinksToChildren {parent} {
        set result "<ul>\n"

        if {$parent eq ""} {
            set names $trans(manpages)
        } else {
            set names $trans(children-$parent)
        }

        foreach name $names {
            manref parse $name base sec
            set title $trans(title-$name)

            append result \
               "<li><a href=\"$base.html\">$name</a></b> -- $title\n"

            if {[info exists trans(children-$name)]} {
                append result [LinksToChildren $name]
            }
        }

        append result "</ul>\n"

        return $result
    }

    # mansec num title
    #
    # num   - A section number, e.g., 1, 5, n
    # title - The section title
    #
    # This command adds another manpage section and title to the 
    # system.

    typemethod mansec {num title} {
        set manSections(man$num) "Section $num: $title"
    }

    #---------------------------------------------------------------------
    # Macro Management

    # ResetMacros
    #
    # Resets the macro processor's interpreter.

    typemethod ResetMacros {} {
        if {$macro eq ""} {
            set macro [::quill::macro ${type}::macro -brackets {< >}]
            $macro macroset ::quill::macroset_html
        }
        
        # FIRST, reset it.
        $macro reset

        # NEXT, define our own macros.
        DefineLocalMacros
    }

    # DefineLocalMacros
    #
    # Defines the default manpage set, which is quite small.

    proc DefineLocalMacros {} {
        # FIRST, manpage-specific macros
        # FIXME: All aliases should be smartaliases.
        $macro smartalias manpage {name title ?parent?} 2 3 \
            [myproc manpage]

        $macro smartalias section {title} 1 1 \
            [myproc section]

        $macro smartalias subsection {title} 1 1 \
            [myproc subsection]

        $macro smartalias defitem {name text} 2 2 \
            [myproc defitem]

        $macro smartalias defopt {text} 1 1 \
            [myproc defopt]

        $macro smartalias itemlist {} 0 0 \
            [myproc itemlist]


        $macro smartalias xref {pageref ?text?} 1 2 \
            [myproc xref]

        $macro smartalias /manpage {} 0 0 \
            [myproc /manpage]

        $macro proc tag {name {text ""}} {
            if {$text ne ""} {
                return "[tt][lb]$name [expand $text][rb][/tt]"
            } else {
                return "[tt][lb]$name[rb][/tt]"
            }
        }

        $macro proc xtag {name} {
            set parts [split $name "#"]
            if {[llength $parts] == 2} {
                lassign $parts page tag
            } else {
                set page ""
                set tag $name
            }

            return "[tt][lb][xref $page#$tag $tag][rb][/tt]"
        }

        $macro smartalias version {} 0 0 \
            [myproc version]

    }

    #---------------------------------------------------------------------
    # Manpage Macros

    # manpage name title ?parent?
    #
    # name   - The man page name, e.g., quill(n)
    # title  - The man page title
    # parent - A parent man page, or "".
    #
    # Begins a man page, and sets up the metadata for the subsequent
    # macros.

    proc manpage {name title {parent ""}} {
        # Pass 1: Catalog the page and return.
        if {[$macro pass] == 1} {
            # FIRST, have we already set the page's name?
            if {$trans(manpage) ne ""} {
                error "encountered two <manpage> macros in this file"
            }

            # NEXT, Save the manpage name
            set trans(manpage) $name
            set trans(title-$name) $title

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
                "<h1>$name: $title -- [xref $parent]</h1>\n"
        } else {
            append result \
                "<h1>$name: $title</h1>\n"
        }

        append result  \
            "\n"       \
            [contents] \
            "\n"

        return $result
    }

    # /manpage
    #
    # Terminates a man page, and provides the footer.

    proc /manpage {} {
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

    #---------------------------------------------------------------------
    # Man Page Sections and Subsections

    # section title
    #
    # title   - The section title
    #
    # Produces the section header, and provides for cross-references

    proc section {title} {
        # Pass 1: Catalog this section.
        if {[$macro pass] == 1} {
            AnchorSave $title

            set trans(section) $title
            lappend trans(sections) [list 0 $title]

            return
        }

        # Pass 2: Produce the section header and anchor
        return "<h2><a name=\"$title\">$title</a></h2>\n"
    }

    # subsection title
    #
    # title - The subsection title
    #
    # Produces the subsection header, and provides for cross-references

    proc subsection {title} {
        # Pass 1: Catalog this section.
        if {[$macro pass] == 1} {
            AnchorSave $title

            if {$trans(section) eq ""} {
                error "subsection found before any section, \"$title\""
            }

            lappend trans(sections) [list 1 $title]

            return
        }

        # Pass 2: Produce the subsection header and anchor
        return "<h3><a name=\"$title\">$title</a></h3>\n"
    }

    # contents
    #
    # Formats the section/subsection table of contents.  This is
    # used automatically by Manpage.

    proc contents {} {
        # Pass 1: do nothing
        if {[$macro pass] == 1} {
            return
        }

        # Pass 2: Format the section table of contents
        set result ""

        foreach item $trans(sections) {
            lassign $item depth title

            if {$depth == 0} {
                append result "[xref #$title]<br>\n"
            } else {
                append result \
                "<span class=\"indent1\">[xref #$title]</span><br>\n" 
            }
        }

        append result "<p>"

        return $result
    }

    #---------------------------------------------------------------------
    # Definition Lists

    # defitem name text
    #
    # name  - The item's name, e.g., "section"
    # text  - The text used to document the item.
    #
    # Begins documentation for the item.  The "name"
    # is the name of the item, which can be used in
    # cross-references, e.g., a command name;
    # the "text" is the full text of the item, e.g.,
    # the command's full signature.

    proc defitem {name text} {
        set text [$macro expandonce $text]

        # pass 1: Catalog the item
        if {[$macro pass] == 1} {
            AnchorSave $name

            lappend trans(items) \
                [list $trans(deflistLevel) $name $text]

            return
        }
        
        # pass 2: Format the item.
        return "<dt><b><a name=\"$name\">$text</a></b><dd>\n"
    }

    # defopt text
    #
    # text   - The text used to document the option.
    #
    # Begins documentation for the option.

    proc defopt {text} {
        # pass 1: do nothing for now.
        if {[$macro pass] == 1} {
            return
        }
        
        # pass 2: Format the item.
        set text [$macro expandonce $text]
        return "<dt><b>$text</b><dd>\n"
    }


    # itemlist
    #
    # Returns a formatted list of links for the SYNOPSIS section.

    proc itemlist {} {
        if {[$macro pass] == 1} {
            return
        }

        set result ""

        foreach entry $trans(items) {
            lassign $entry depth item text

            set class "indent$depth"
            append result \
                "<span class=\"$class\">[xref #$item $text]</span><br>\n"
        }

        return $result
    }


    #---------------------------------------------------------------------
    # Cross-References

    # xref pageref ?text?
    #
    # pageref   - A string that names an external page in some way
    # text      - The link text.
    #
    # Creates a cross-reference link based on the pageref.  If ?text?
    # is given, it's used as the link text; otherwise, the link text
    # is determined from the pageref as described below.
    #
    # Pagerefs have the form "<pageId>#<anchor>".  Either the pageId or
    # the anchor can be omitted, but not both.  If the anchor is present,
    # the "#" must be present as well.  If the pageId is omitted, the
    # link is to an anchor in this man page; otherwise, it identifies the
    # target HTML page.  The pageId may take any of the following forms:
    #
    #     name($sec)  - Links to ../man$sec/name.html
    #     http...     - Links to the URL
    #
    # The default link text is the anchor, if given, or the pageId otherwise.
    #
    # If the link is to this page, and the anchor is unknown, a warning
    # is produced.

    proc xref {pageref {text ""}} {
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
            if {![AnchorExists $anchor]} {
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

    proc version {} {
        return $trans(version)
    }

    #---------------------------------------------------------------------
    # Helpers

    # AnchorSave anchor
    #
    # anchor   - A link anchor
    #
    # Saves the anchor for this page, so we know that it exists.  The new
    # anchor must not already exist on this page.

    proc AnchorSave {anchor} {
        if {[AnchorExists $anchor]} {
            error "Duplicate anchor, \"$anchor\""
        }

        lappend trans(anchors) $anchor
    }

    # AnchorExists anchor
    #
    # anchor  - A possible link anchor
    #
    # While processing a page, returns 1 if the anchor is known, and 0 
    # otherwise.

    proc AnchorExists {anchor} {
        expr {$anchor in $trans(anchors)}
    }
}







