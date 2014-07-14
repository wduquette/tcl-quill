#-------------------------------------------------------------------------
# TITLE: 
#    macro.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl
#
# DESCRIPTION:
#    macro(n): macro-expander based on textutil::expander.
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Namespace Exports

namespace eval ::quill:: {
    namespace export \
        macro
}

snit::type ::quill::macro {
    #---------------------------------------------------------------------
    # Components

    component exp    ;# The textutil::expander
    component interp ;# The smartinterp


    #---------------------------------------------------------------------
    # Instance Variables

    # Info Array
    #
    # pass   - The expansion pass, 1 or 2.

    variable info -array {
        pass 1
    }

    #---------------------------------------------------------------------
    # Options

    # -commands to interp
    # -brackets to exp
    

    #---------------------------------------------------------------------
    # Delegated Methods

    # To expander
    delegate method cappend     to exp
    delegate method cget        to exp
    delegate method cis         to exp
    delegate method cname       to exp
    delegate method cpop        to exp
    delegate method cpush       to exp
    delegate method cset        to exp
    delegate method cvar        to exp
    delegate method errmode     to errmode
    delegate method lb          to lb
    delegate method rb          to rb
    delegate method setbrackets to setbrackets
    delegate method textcmd     to textcmd
    delegate method where       to where

    # To smartinterp
    delegate method eval        to smartinterp
    delegate method alias       to smartinterp
    delegate method proc        to smartinterp
    delegate method clone       to smartinterp
    delegate method ensemble    to smartinterp
    delegate method smartalias  to smartinterp

    #---------------------------------------------------------------------
    # Other Public Methods

    # pass - return pass number
    # expand - two-pass expansion of string
    # expandfile - two-pass expansion of file content
    # reset - Reset interp state
    # vocab - Register a macro library, so that it is defined on reset.

}

#-----------------------------------------------------------------------
# Main Routine

# main
#
# Processes the arguments on the application's command line.

proc main {} {
    # FIRST, get the .ehtml files in the current directory.
    set files [glob -nocomplain [file join [pwd] *.ehtml]]

    if {[llength $files] == 0} {
        puts "Error, no *.ehtml files in this directory."
        exit 1
    }

    # NEXT, create the expander.
    ::textutil::expander expander
    expander setbrackets << >>

    # NEXT, set up the :memory: database for storing the man page catalog
    sqlite3 db :memory:
    
    db eval {
        CREATE TABLE manpages (
            -- Name of the man page, e.g., name(sec)
            manpage TEXT PRIMARY KEY,

            -- Title of the man page
            title   TEXT,

            -- Name of the parent man page, or ''
            parent  TEXT
        );

        CREATE TABLE anchors (
            -- Name of the man page on which the anchor appears
            manpage TEXT,

            -- Anchor
            anchor TEXT,

            PRIMARY KEY(manpage, anchor)
        );

        CREATE TABLE sections (
            section_id  INTEGER PRIMARY KEY AUTOINCREMENT,

            -- Name of the man page in which the section appears
            manpage TEXT,

            -- Title of the section
            section TEXT,

            -- Parent section, or ''
            parent  TEXT
        );

        CREATE TABLE items (
            item_id  INTEGER PRIMARY KEY AUTOINCREMENT,

            -- Name of the man page in which the item appears
            manpage  TEXT,

            -- The item name (the anchor)
            item     TEXT,

            -- The item text (e.g., command signature)
            itemtext TEXT,

            -- Definition List Level: 0, 1, 2...
            level    INTEGER
        );

    }
    
    # NEXT, add the local lib directory to the auto_path.
    set binpath [file dirname [info script]]
    lappend ::auto_path [file join $binpath ../lib]

    # NEXT, scan and format the files
    if {[catch {processFiles $files} result]} {
        puts $result
        exit 1
    }

    # NEXT, produce the "index.html" file as an index of all of
    # the others.
    
    createIndex
}

# processFiles files
#
# files    A list of the files to process
#
# Scans and then formats all of the files.

proc processFiles {files} {
    global info

    # FIRST, scan each file.
    foreach filename $files {
        puts "Scanning $filename"

        set fullname [file normalize $filename]
        
        # FIRST, get the file's text.
        set f [open $filename r]
        set text [read $f]
        close $f

        # NEXT, do the scanning pass.
        set info(pass)         1
        set info(filename)     $filename
        set info(manpage)      ""
        set info(section)      {}
        set info(deflistLevel) -1

        expander expand $text
    }

    # NEXT, format and write each file

    foreach filename $files {
        puts "Formatting $filename"

        set fullname [file normalize $filename]

        # FIRST, get the file's text.
        set f [open $filename r]
        set text [read $f]
        close $f

        # NEXT, do the formatting pass
        set info(pass)     2
        set info(filename) $filename
        set info(manpage)  ""
        set info(section)  {}

        set result [expander expand $text]

        # Write out the file
        manpageRef parse $info(manpage) basename mansec
        set outname "$basename.html"
        
        puts "Writing $outname"

        set f [open $outname w]
        puts $f $result
        close $f
    }
}


# createIndex
#
# Creates an index of the man pages in this directory.

proc createIndex {} {
    global manpageCSS

    set manDir [file tail [pwd]]

    switch -exact -- $manDir {
        man1    {set title "Section 1: Commands"}
        man5    {set title "Section 5: File Formats"}
        mann    {set title "Section n: Tcl Packages"}
        mani    {set title "Section i: Tcl Interfaces"}
        default {set title "Index of Man Pages"}
    }

    set result "<html>\n"
    append result "<head>\n"
    append result "<title>$title</title>\n"
    append result "<style>\n"
    append result "<!--\n"
    append result $manpageCSS
    append result "-->\n"
    append result "</style>\n"
    append result "</head>\n"
    append result "<body>\n"
    append result "<h1 class=\"header\">Glue Documentation</h1>\n"
    append result "<h1>$title</h1>\n"
    append result "\n"

    append result [LinksToChildren ""]

    set ts [clock format [clock seconds]]
    append result "<hr class=\"outdent\">\n"
    append result "<span class=\"outdent\">\n"
    append result "<i>Generated from [file tail [pwd]]/*.ehtml on $ts</i>\n"
    append result "</span>\n"
    append result "</body>\n"
    append result "</html>\n"

    set f [open [file join [pwd]/index.html] w]
    puts $f $result
    close $f
}

# LinksToChildren parent
#
# parent     "", or a manpage with children
#
# Creates a bulleted list of links to child man pages, recursing if
# a child also has children.

proc LinksToChildren {parent} {
    set result "<ul>\n"

    db eval {
        SELECT manpage, title 
        FROM manpages
        WHERE parent = $parent
    } {
        manpageRef parse $manpage basename mansec
        append result \
           "<li><a href=\"$basename.html\">$manpage</a></b> -- $title\n"

        if {[db exists {SELECT * FROM manpages WHERE parent = $manpage}]} {
            append result [LinksToChildren $manpage]
        }
    }

    append result "</ul><p>\n"

    return $result
}


#-----------------------------------------------------------------------
# Macros

# exppass
#
# Returns the pass number, 1 or 2.

proc exppass {} {
    global info

    return $info(pass)
}

# manpage name title ?options...?
#
# name     The manpage name, e.g., "manpage(5)"
# title    A short, descriptive title
#
# -parent name     Name of the parent man page.
#
# Produces the header for the man page, and adds it to the directory
# index.

proc manpage {name title args} {
    global info
    global manpageCSS

    # FIRST, Get the options
    array set opts {
        -parent ""
    }
    array set opts $args

    # NEXT, have we already set the page's name?
    if {$info(manpage) ne ""} {
        error "encountered two <<manpage>> macros in this file"
    }

    # NEXT, Save the manpage name
    set info(manpage) $name

    # Pass 1: Catalog the page and return.
    if {[exppass] == 1} {
        # FIRST, Validate name and -parent page name
        manpageRef validate $name

        if {$opts(-parent) ne ""} {
            manpageRef validate $opts(-parent)
        }
        
        # NEXT, have we seen this page name before?
        if {[db exists {SELECT * FROM manpages WHERE manpage=$name}]} {
            error "encountered two manpage(5) files with the same name."
        }

        db eval {
            INSERT INTO manpages(manpage, title, parent)
            VALUES($name,$title,$opts(-parent))
        }

        return
    }

    # Pass 2: Format the Output
    set result "<html>\n"
    append result "<head>\n"
    append result "<title>$name: $title</title>\n"
    append result "<style>\n"
    append result "<!--\n"
    append result $manpageCSS
    append result "-->\n"
    append result "</style>\n"
    append result "</head>\n"
    append result "<body>\n"
    append result "<h1 class=\"header\">Glue Documentation</h1>\n"

    if {$opts(-parent) ne ""} {
        append result "<h1>$name: $title -- [xref $opts(-parent)]</h1>\n"
    } else {
        append result "<h1>$name: $title</h1>\n"
    }

    append result "\n"
    append result [contents]
    append result "\n"

    return $result
}

# section title
#
# Produces the section header, and provides for cross-references

proc section {title} {
    global info

    # Pass 1: Catalog this section.
    if {[exppass] == 1} {
        anchorSave $title

        set info(section) $title

        db eval {
            INSERT INTO sections(manpage, section)
            VALUES($info(manpage), $title)
        }

        return
    }

    # Pass 2: Produce the section header and anchor
    return "<h2><a name=\"$title\">$title</a></h2>\n"
}

# subsection title
#
# Produces the section header, and provides for cross-references

proc subsection {title} {
    global info

    # Pass 1: Catalog this section.
    if {[exppass] == 1} {
        anchorSave $title

        if {$info(section) eq ""} {
            error "subsection found before any section, \"$title\""
        }

        db eval {
            INSERT INTO sections(manpage, section, parent)
            VALUES($info(manpage), $title, $info(section))
        }

        return
    }

    # Pass 2: Produce the subsection header and anchor
    return "<h3><a name=\"$title\">$title</a></h3>\n"
}

# tclsh command
# 
# Formats command as though it had been entered at the tclsh prompt,
# and then computes its result, and adds that to the output.
# Note that some commands, notably "puts", can't be handled with this;
# all "puts" calls must be formatted by hand.

proc tclsh {command} {
    # Evaluate command at the global level, and 
    # print out both the command and the result.

    set output "% "
    append output [string trim $command]
    set result [uplevel \#0 $command]

    if {"" != $result} {
        append output "\n$result"
    }

    set output [string map {& &amp; < &lt; > &gt;} $output]

    return $output
}

# swallow script
#
# script    A Tcl script
#
# Evaluates the script at the global scope, and swallows any
# return value.

proc swallow {script} {
    uplevel \#0 $script
    return
}

# deflist args...
#
# args     Arbitrary text identifying the deflist.
#
# Begins a definition list.  The args are ignored,
# but are convenient for matching up the deflist with
# its /deflist.

proc deflist {args} {
    global info

    incr info(deflistLevel)

    return "<dl>\n"
}

# defitem name text
#
# name    The item's name, e.g., "section"
# text    The text used to document the item.
#
# Begins documentation for the item.  The "name"
# is the name of the item, which can be used in
# cross-references, e.g., a command name;
# the "text" is the full text of the item, e.g.,
# the command's full signature.

proc defitem {name text} {
    global info

    # pass 1: Catalog the item
    if {[exppass] == 1} {
        anchorSave $name

        db eval {
            INSERT INTO items(manpage, item, itemtext, level)
            VALUES($info(manpage), $name, $text, $info(deflistLevel))
        }

        return
    }
    
    # pass 2: Format the item.
    return "<dt><b><a name=\"$name\">$text</a></b><dd>\n"
}

# defopt option text
#
# option  The option's name, e.g., "-myoption"
# text    The text used to document the option.
#
# Begins documentation for the option.  At present,
# no cataloging is done.

proc defopt {option text} {
    global info

    # pass 1: do nothing for now.
    if {[exppass] == 1} {
        return
    }
    
    # pass 2: Format the item.
    return "<dt><b>$text</b><dd>\n"
}

# /deflist args...
#
# args     Arbitrary text identifying the deflist.
#
# Ends a definition list.  The args are ignored,
# but are convenient for matching up the deflist with
# its /deflist, especially when deflists are nested.

proc /deflist {args} {
    global info

    incr info(deflistLevel) -1

    return "</dl>\n"
}

# itemlist
#
# Returns a formatted list of links for the SYNOPSIS section.

proc itemlist {} {
    global info

    set result ""

    db eval {
        SELECT item, itemtext, level
        FROM items
        WHERE manpage = $info(manpage)
    } {
        set class "indent$level"
        append result \
            "<span class=\"$class\">[xref #$item $itemtext]</span><br>\n"
    }

    return $result
}

# children
#
# Returns a formatted list of links to manpages which are
# children of this man page.

proc children {} {
    global info

    # pass 1 -- do nothing
    if {[exppass] == 1} {
        return
    }

    # pass 2 -- format the list
    set result [LinksToChildren $info(manpage)]
    return $result
}


# xref pageref ?text?
#
# pageref     A string that names an external page in some way
# text        The link text.
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
#     name(1)        Links to ../man1/name.html
#     name(5)        Links to ../man5/name.html
#     name(n)        Links to ../mann/name.html
#     name(i)        Links to ../mani/name.html
#     http:...       Links to the URL
#
# The default link text is the anchor, if given, or the pageId otherwise.
#
# If the link is to this page, and the anchor is unknown, a warning
# is produced.

proc xref {pageref {text ""}} {
    # Pass 1: Do nothing
    if {[exppass] == 1} {
        return
    }

    # Pass 2: Parse the pageref, and format the link.
    set pageref [split $pageref "#"]
    set pageId [lindex $pageref 0]
    set anchor [lindex $pageref 1]

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
    } elseif {[string match "http:*" $pageId]} {
        set url $pageId
    } elseif {[manpageRef parse $pageId name num]} {
        set url "../man$num/$name.html"
    } else {
        error "Unrecognized pageId: \"$pageId\""
    }

    # Next, make sure we know the anchor
    if {$pageId eq ""} {
        if {![anchorExists $anchor]} {
            puts "Warning: unknown anchor, \"$anchor\""
        }
    }

    if {$anchor ne ""} {
        return "<a href=\"$url#$anchor\">$text</a>"
    } else {
        return "<a href=\"$url\">$text</a>"
    }
}

# /manpage
#
# Produces the footer for the man page.

proc /manpage {} {
    global info

    # Pass 1: Make sure we've got a <<manpage>>.
    if {[exppass] == 1} {
        # FIRST, have we set the page's name?
        if {$info(manpage) eq ""} {
            error "encountered <</manpage>> before <<manpage>> in this file"
        }

        return
    }

    # Pass 2: Format the Output
    set ts [clock format [clock seconds]]
    append result "<hr class=\"outdent\">\n"
    append result "<span class=\"outdent\">\n"
    append result "<i>Generated from [file tail $info(filename)] on $ts</i>\n"
    append result "</span>\n"
    append result "</body>\n"
    append result "</html>\n"

    return $result
}


#-----------------------------------------------------------------------
# Utility Routines

# anchorSave anchor
#
# anchor       A link anchor
#
# Saves the anchor for this page, so we know that it exists.  The new
# anchor must not already exist on this page.

proc anchorSave {anchor} {
    global info

    if {[catch {
        db eval {
            INSERT INTO anchors(manpage,anchor)
            VALUES($info(manpage), $anchor)
        }
    }]} {
        error "Duplicate anchor, \"$anchor\""
    }
}

# anchorExists anchor
#
# anchor       A possible link anchor
#
# While processing a page, returns 1 if the anchor is known, and 0 
# otherwise

proc anchorExists {anchor} {
    global info

    return [db exists {
        SELECT * FROM anchors
        WHERE manpage = $info(manpage)
        AND   anchor  = $anchor
    }]
}

# contents
#
# Formats the section/subsection table of contents

proc contents {} {
    global info

    # Pass 1: do nothing
    if {[exppass] == 1} {
        return
    }

    # Pass 2: Format the section table of contents
    set result ""

    db eval {
        SELECT section, parent
        FROM sections
        WHERE manpage = $info(manpage)
    } {
        # Indent subsections
        if {$parent eq ""} {
            append result "[xref #$section]<br>\n"
        } else {
            append result \
                "<span class=\"indent1\">[xref #$section]</span><br>\n"
        }
    }

    append result "<p>"

    return $result
}


#-----------------------------------------------------------------------
# Main-line Code

main









