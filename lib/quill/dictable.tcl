#-----------------------------------------------------------------------
# TITLE:
#    dictable.tcl
#
# AUTHOR:
#    Will Duquette
#
# PROJECT:
#    Quill: Project Build System for Tcl
#
# DESCRIPTION:
#    dictable(n): Formatting and manipulation of "tables" -- lists of
#    dictionaries with identical keys.
#
#-----------------------------------------------------------------------

namespace eval ::quill:: {
    namespace export \
        dictable
}

#-------------------------------------------------------------------------
# code ensemble

snit::type ::quill::dictable {
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
    #    -skipsame list   - List of keys; identical values in successive
    #                       columns are omitted.
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
        set skipCols    [list]
        set headers     [interleave $columns $columns]

        foroption opt args {
            -leader      { set leader      [lshift args]}
            -sep         { set sep         [lshift args]}
            -columns     { set columns     [lshift args]}
            -showheaders { set showHeaders 1            }
            -skipsame    { set skipCols    [lshift args]}
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
        set oldrow [interleave $columns {}]

        foreach row $table {
            set rlist [list]
            foreach key $columns {
                set value [dict get $row $key]

                if {$key in $skipCols && $value eq [dict get $oldrow $key]} {
                    set value ""
                }
                lappend rlist [format %-*s $w($key) $value]
            }
            lappend tlist "$leader[join $rlist $sep]"
            set oldrow $row
        }

        return [join $tlist \n]
    }

    # sort table ?cspecs?
    #
    # cspecs - A list of column sort specifications; defaults to all, 
    #          using string compare, in increasing order.
    #
    # Sorts the table's entries by the data in each specified column.
    # If no columns are given, all columns are sorted, taking
    # the order from the first record in the table.
    #
    # A column specification is a list beginning with the column name.
    # It may include the following options:
    #
    #    -numeric    - Convert values to doubles and do numeric comparison
    #    -nocase     - Case-insensitive string comparison (ignored if 
    #                  -numeric is given)
    #    -decreasing - Sorts in decreasing order.
    #

    typemethod sort {table {cspecs {}}} {
        # FIRST, if the table has one or fewer entries, just return it.
        if {[llength $table] <= 1} {
            return $table
        }

        # NEXT, get the columns on which to sort.
        if {![got $cspecs]} {
            set cspecs [dict keys [lindex $table 0]]
        }

        # NEXT, sort it.
        return [lsort -command [myproc RowCompare $cspecs] $table]
    }

    # RowCompare cspecs r1 r2
    #
    # cspecs    - The column specs
    # r1        - The first row
    # r2        - The second row
    #
    # Compares the two row dictionaries, returning -1 if r1 < r2,
    # 0 if r1 eq r2, and +1 if r1 > r2, using [Compare].

    proc RowCompare {cspecs r1 r2} {
        foreach cspec $cspecs {
            set key [lshift cspec]
            set v1 [dict get $r1 $key]
            set v2 [dict get $r2 $key]
            set result [Compare $v1 $v2 {*}$cspec]

            if {$result != 0} {
                return $result
            }
        }

        return 0
    }

    # puts table ?options...?
    #
    # table - A list of dictionaries with identical keys
    #
    # Options: as for "table format".
    #
    # Formats the table and prints it to stdout.

    typemethod puts {table args} {
        puts [$type format $table {*}$args]
    }

    # filter table key pattern ?key pattern...?
    #
    # table   - A dictable
    # key     - A key
    # pattern - A glob pattern
    #
    # Returns a table containing only rows that match the patterns.

    typemethod filter {table args} {
        set result [list]
        foreach row $table {
            if {[FilterMatch $row $args]} {
                lappend result $row
            }
        }

        return $result
    }

    # FilterMatch row pdict
    #
    # row    - A row from a table
    # pdict  - A dictionary of "key/pattern" pairs
    #
    # Returns 1 if all patterns match, and 0 otherwise.

    proc FilterMatch {row pdict} {
        dict for {key pattern} $pdict {
            if {![string match $pattern [dict get $row $key]]} {
                return 0
            }
        }

        return 1
    }

    #---------------------------------------------------------------------
    # Helpers

    # Compare v1 v2 ?options?
    #
    # v1, v2  - Values
    #
    # By default, does a [string compare] of the two values, returning
    # -1, 0, or +1 in the usual way.  The following options can be used:
    #
    #    -decreasing   - Sorts in decreasing order, rather than increasing.
    #    -numeric      - Sorts using numeric comparison, rather than string.
    #    -nocase       - Sorts case-insensitively.
    
    proc Compare {v1 v2 args} {
        set order   1
        set numeric 0
        set nocase  0

        foroption opt args {
            -decreasing { set order   -1 }
            -numeric    { set numeric 1  }
            -nocase     { set nocase  1  }
        }

        if {$numeric} {
            if {double($v1) < double($v2)} {
                set result -1
            } elseif {double($v1) > double($v2)} {
                set result 1
            } else {
                set result 0
            }
        } else {
            # String
            if {$nocase} {
                set result [string compare -nocase $v1 $v2]
            } else {
                set result [string compare $v1 $v2]
            }
        }

        set result [expr {$order * $result}]
        return $result
    }
}

