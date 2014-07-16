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
    # Instance Variables

    # manSections: Array of man page section titles by section directory.
    variable manSections -array {
        man1 "Section 1: Commands"
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
        
        # NEXT, set up the transient data for this page
        set trans(manpage)      ""
        set trans(section)      ""
        set trans(anchors)      [list]
        set trans(sections)     [list]
        set trans(items)        [list]
        set trans(deflistLevel) -1

        # NEXT, process the files
        foreach filename [glob -nocomplain [file join $indir *.manpage]] {
            # FIRST, reset the macro processor for each file.
            $self ResetMacros

            # NEXT, process this file.
            set trans(filename) [file tail $filename]
            set pagename [file rootname $trans(filename)]
            set outpath [file join $outdir $pagename.html]

            puts "Writing $outpath"
            writefile $outpath [$macro expandfile $filename]
        }

        # NEXT, Write the index
        $self CreateIndex $outdir
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

    # CreateIndex
    #
    # Creates an index of the man pages in this directory.

    method CreateIndex {outdir} {
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
            [$self LinksToChildren ""]                         \
            "<hr class=\"outdent\">\n"                   \
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

    method LinksToChildren {parent} {
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
                append result [$self LinksToChildren $manpage]
            }
        }

        append result "</ul><p>\n"

        return $result
    }

    # mansec num title
    #
    # num   - A section number, e.g., 1, 5, n
    # title - The section title
    #
    # This command adds another manpage section and title to the 
    # system.

    method mansec {num title} {
        set manSections(man$num) "Section $num: $title"
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

        $macro smartalias section {title...} 1 - \
            [mymethod Section]

        $macro smartalias subsection {title...} 1 - \
            [mymethod Subsection]

        $macro alias deflist $self Deflist

        $macro smartalias defitem {name text} 2 2 \
            [mymethod Defitem]

        $macro smartalias defopt {text} 1 1 \
            [mymethod Defopt]

        $macro alias /deflist $self /Deflist

        $macro alias itemlist $self Itemlist

        $macro smartalias xref {pageref ?text?} 1 2 \
            [mymethod Xref]

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

    # Section title...
    #
    # title   - The section title
    #
    # Produces the section header, and provides for cross-references

    method Section {args} {
        set title $args

        # Pass 1: Catalog this section.
        if {[$macro pass] == 1} {
            $self AnchorSave $title

            set trans(section) $title
            lappend trans(sections) [list 0 $title]

            return
        }

        # Pass 2: Produce the section header and anchor
        return "<h2><a name=\"$title\">$title</a></h2>\n"
    }

    # Subsection title...
    #
    # title - The subsection title
    #
    # Produces the subsection header, and provides for cross-references

    method Subsection {args} {
        set title $args

        # Pass 1: Catalog this section.
        if {[$macro pass] == 1} {
            $self AnchorSave $title

            if {$trans(section) eq ""} {
                error "subsection found before any section, \"$title\""
            }

            lappend trans(sections) [list 1 $title]

            return
        }

        # Pass 2: Produce the subsection header and anchor
        return "<h3><a name=\"$title\">$title</a></h3>\n"
    }

    # Contents
    #
    # Formats the section/subsection table of contents

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

    # Deflist args...
    #
    # args   - Arbitrary text identifying the deflist.
    #
    # Begins a definition list.  The args are ignored,
    # but are convenient for matching up the deflist with
    # its /deflist.

    method Deflist {args} {
        incr trans(deflistLevel)

        return "<dl>\n"
    }

    # Defitem name text
    #
    # name  - The item's name, e.g., "section"
    # text  - The text used to document the item.
    #
    # Begins documentation for the item.  The "name"
    # is the name of the item, which can be used in
    # cross-references, e.g., a command name;
    # the "text" is the full text of the item, e.g.,
    # the command's full signature.

    method Defitem {name text} {
        # pass 1: Catalog the item
        if {[$macro pass] == 1} {
            $self AnchorSave $name

            lappend trans(items) \
                [list $trans(deflistLevel) $name $text]

            return
        }
        
        # pass 2: Format the item.
        set text [$macro expandonce $text]
        return "<dt><b><a name=\"$name\">$text</a></b><dd>\n"
    }

    # defopt text
    #
    # text   - The text used to document the option.
    #
    # Begins documentation for the option.

    method Defopt {text} {
        # pass 1: do nothing for now.
        if {[$macro pass] == 1} {
            return
        }
        
        # pass 2: Format the item.
        set text [$macro expandonce $text]
        return "<dt><b>$text</b><dd>\n"
    }

    # /Deflist args...
    #
    # args  - Arbitrary text identifying the deflist.
    #
    # Ends a definition list.  The args are ignored,
    # but are convenient for matching up the deflist with
    # its /deflist, especially when deflists are nested.

    method /Deflist {args} {
        incr trans(deflistLevel) -1

        return "</dl>\n"
    }

    # Itemlist
    #
    # Returns a formatted list of links for the SYNOPSIS section.

    method Itemlist {} {
        if {[$macro pass] == 1} {
            return
        }

        set result ""

        foreach entry $trans(items) {
            lassign $entry depth item text

            set class "indent$depth"
            append result \
                "<span class=\"$class\">[$self Xref #$item $text]</span><br>\n"
        }

        return $result
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

    # Xref pageref ?text?
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

    method Xref {pageref {text ""}} {
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
    # Helpers

    # AnchorSave anchor
    #
    # anchor   - A link anchor
    #
    # Saves the anchor for this page, so we know that it exists.  The new
    # anchor must not already exist on this page.

    method AnchorSave {anchor} {
        if {[$self AnchorExists $anchor]} {
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

    method AnchorExists {anchor} {
        expr {$anchor in $trans(anchors)}
    }


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







