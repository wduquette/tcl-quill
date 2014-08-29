#-----------------------------------------------------------------------
# TITLE:
#    table.tcl
#
# AUTHOR:
#    Will Duquette
#
# PROJECT:
#    Quill: Project Build System for Tcl
#
# DESCRIPTION:
#    table(n): Formatting and manipulation of "tables" -- lists of
#    dictionaries with identical keys.
#
#-----------------------------------------------------------------------

namespace eval ::quill:: {
    namespace export \
        table
}

#-------------------------------------------------------------------------
# code ensemble

snit::type ::quill::table {
    pragma -hasinstances no -hastypedestroy no

    # format table ?options...?
    #
    # table   - A list of dictionaries with identical keys
    #
    # Options:
    #    -leader string   - Text to put at the beginning of each line;
    #                       defaults to "".
    #    -sep string      - Separator between columns; defaults to " ".
    #    -columns list    - List of keys to output.
    #    -showheaders     - If given, include column headers.
    #    -headers dict    - Dictionary of header names by key.
    #
    # Produces tabular output for the "table", one column per key.
    # By default, all keys are included, in the order returned by 
    # [dict keys] for the first item in the table.  The set of 
    # columns can be ordered and limited using the -columns option.
    #
    # By default, no column headers are shown.  If -showheaders is
    # given, column headers are displayed.  By default, the header
    # labels are the key names.  If -headers is given, the provided
    # strings replace the key names.

    typemethod format {table args} {
        # FIRST, if the table is empty return the empty string.
        if {[llength $table] == 0} {
            return ""
        }

        # NEXT, get the options.
        set leader      ""
        set sep         " "
        set columns     [dict keys [lindex $table 0]]
        set showHeaders 0
        set headers     [interleave $columns $columns]

        foroption opt args {
            -leader      { set leader      [lshift args]}
            -sep         { set sep         [lshift args]}
            -columns     { set columns     [lshift args]}
            -showheaders { set showHeaders 1}
            -headers     { 
                set headers [dict merge $headers [lshift args]]
            }
        }

        # NEXT, if there are headers add them to the table.
        if {$showHeaders} {
            set table [linsert $table 0 $headers]
        }

        # NEXT, get the column widths.
        foreach key $columns {
            set w($key) 0
        }

        foreach row $table {
            foreach key $columns {
                set len [string length [dict get $row $key]]
                if {$len > $w($key)} {
                    set w($key) $len
                }
            }
        }

        # NEXT, if there are headers, add the column lines.
        if {$showHeaders} {
            set lines [dict create]
            foreach key $columns {
                dict set lines $key [string repeat - $w($key)]
            }
            set table [linsert $table 1 $lines]
        }


        # NEXT, build up the output to return.
        set tlist [list]
        foreach row $table {
            set rlist [list]
            foreach key $columns {
                lappend rlist [format %-*s $w($key) [dict get $row $key]]
            }
            lappend tlist "$leader[join $rlist $sep]"
        }

        return [join $tlist \n]
    }

    # puts table ?options...?
    #
    # table - A list of dictionaries with identical keys
    #
    # Options: as for "table format".
    #
    # Formats the table and prints it to stdout.

    typemethod puts {table args} {
        puts [table format $table {*}$args]
    }
}

