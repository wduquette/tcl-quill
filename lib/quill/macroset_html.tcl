#-------------------------------------------------------------------------
# TITLE: 
#    macroset_html.tcl
#
# AUTHOR:
#    Will Duquette
# 
# PROJECT:
#    Quill: Project Build System for Tcl
#
# DESCRIPTION:
#    macroset_html(n): A macroset(i) object implementing standard HTML
#    tags as macro(n) macros.
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# macroset_html singleton

snit::type ::quill::macroset_html {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no


    # install macro
    #
    # macro  - An instance of macro(n)
    #
    # Installs the macros into the instance.

    typemethod install {macro} {
        # FIRST, basic tags.
        foreach tag {
            b i code tt pre em strong 
        } {
            StyleTag $macro $tag
        }

        foreach tag {
            p ul ol li
        } {
            Identity $macro $tag
            Identity $macro /$tag
        }

        foreach tag {
            br
        } {
            Identity $macro $tag
        }

        # NEXT, convenience macros.
        $macro proc hrule {} { return "<hr>\n" }
        $macro proc lb {}    { return "&lt;"   }
        $macro proc rb {}    { return "&gt;"   }

        $macro proc link {url {text ""}} {
            if {$text eq ""} {
                set text $url
            }

            return "<a href=\"$url\">$text</a>"
        }

        # NEXT, definition list macros.

        $macro proc deflist {args} {
            return "<dl>\n"
        }

        $macro proc def {text} {
            set text [expand $text]
            return "<dt><b>$text</b><dd>\n"
        }

        $macro proc /deflist {args} {
            return "</dl>\n"
        }

        # NEXT, topic list macros
        $macro proc topiclist {} {
            return "<table class=\"topiclist\">"
        }

        $macro proc topic {topic} {
            set topic [expand $topic]
            append result \
                "<tr class=\"topicrow\">\n" \
                "<td class=\"topicname\">$topic</td>\n" \
                "<td class=\"topictext\">"

            return $result
        }

        $macro proc /topic {} {
            return "</td></tr>"
        }

        $macro proc /topiclist {args} {
            return "</table>"
        }

        # NEXT, examples and listings.
        $macro proc box {} {
            return "<div class=\"box\">"
        }

        $macro proc /box {} {
            return "</div>"
        }
        
        $macro proc example {} {
            return "<pre class=\"example\">"
        }

        $macro proc /example {} {
            return "</pre>"
        }

        $macro proc listing {} {
            macro cpush listing
        }

        $macro proc /listing {} {
            set text [macro cpop listing]

            set lines [list]
            set i 0
            foreach line [split [string trim $text] \n] {
                lappend lines \
                    [format "<span class=\"linenum\">%04d</span> %s" [incr i] $line] 
            }

            return "<pre class=\"listing\">\n[join $lines \n]\n</pre>\n"
        }

        $macro proc mark {symbol} {
            return "<div class=\"mark\">$symbol</div>"
        }

        $macro proc bigmark {symbol} {
            return "<div class=\"bigmark\">$symbol</div>"
        }
    }

    #---------------------------------------------------------------------
    # Helpers

    # Identity macro tag
    #
    # macro   - The instance of macro(n)
    # tag     - The tag to define.
    #
    # Defines a macro that expands to the same named HTML tag.

    proc Identity {macro tag} {
        $macro proc $tag {} [format {
            return "<%s>"
        } $tag]
    }

    # StyleTag macro tag
    #
    # macro - The instance of macro(n)
    # tag   - A style tag name
    #
    # Defines style tag macros, which can be used in the normal way
    # or with <$tag args> syntax.

    proc StyleTag {macro tag} {
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







