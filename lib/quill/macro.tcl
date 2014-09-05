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
        pass   1
    }

    # Registered macroset(i) commands.

    variable macrosets {}

    #---------------------------------------------------------------------
    # Options

    # -commands
    #
    # all | safe | none -- specifies which commands are available in the
    # macro interpreter.  Changes take effect on reset.

    option -commands   \
        -default   safe \
        -type     {snit::enum -values {all safe none}}

    # -passcommand command
    #
    # Command to call between the expansion passes.

    option -passcommand

    # -brackets pair
    #
    # Sets a pair of macro-expansion brackets.
    option -brackets           \
        -default         {< >} \
        -configuremethod ConfigureBrackets

    method ConfigureBrackets {opt val} {
        set options($opt) $val

        $exp setbrackets {*}$val
    }

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
    delegate method errmode     to exp
    delegate method lb          to exp
    delegate method rb          to exp
    delegate method textcmd     to exp
    delegate method where       to exp

    # To smartinterp
    delegate method eval        to interp
    delegate method alias       to interp
    delegate method proc        to interp
    delegate method clone       to interp
    delegate method ensemble    to interp
    delegate method smartalias  to interp

    #---------------------------------------------------------------------
    # Constructor

    constructor {args} {
        # FIRST, create the components
        install exp using textutil::expander ${selfns}::exp
        $exp setbrackets << >>
        $exp errmode fail

        set interp ""
        $self reset

        # NEXT, save the options
        $self configurelist $args
    }

    #---------------------------------------------------------------------
    # Other Public Methods

    # pass
    #
    # Return the expansion pass.

    method pass {} {
        return $info(pass)
    }

    # expandonce text
    #
    # text - A text string
    #
    # Expands the text string in one pass, without affecting the
    # the current pass.

    method expandonce {text} {
        return [$exp expand $text]
    }

    # expand text
    #
    # text   - A string containing macros to expand
    #
    # Does a two-pass expansion and returns the result.

    method expand {text} {
        try {
            set info(pass) 1
            $exp expand $text
            callwith $options(-passcommand)
            set info(pass) 2
            set output [$exp expand $text]
            set info(pass) 1
        } on error {result eopts} {
            if {[string match "Error in macro*" $result]} {
                throw SYNTAX $result
            }
            return {*}$eopts $result
        }

        return $output
    }

    # expandfile filename
    #
    # filename  - Name of a text file
    #
    # Expands the contents of the file, and returns the result.

    method expandfile {filename} {
        return [$self expand [readfile $filename]]
    }

    # macroset prefix
    #
    # prefix  - A command prefix implementing macroset(i).
    #
    # Registers the command prefix. It will take effect on the next
    # and subsequent resets.

    method macroset {prefix} {
        lappend macrosets $prefix
    }

    # reset 
    #
    # Resets the expander's macro interpreter.

    method reset {} {
        # FIRST, Recreate the smartinterp
        catch {$interp destroy}
        install interp using smartinterp ${selfns}::interp \
            -commands $options(-commands)
        $exp evalcmd [list $interp eval]

        # NEXT, redefine the macros
        $self DefineLocalMacros

        # NEXT, define any registered macro sets.
        foreach macroset $macrosets {
            {*}$macroset install $self
        }
    }

    # DefineLocalMacros
    #
    # Defines the default macro set, which is quite small.

    method DefineLocalMacros {} {
        # Make the processor itself available.
        $interp alias macro $self

        $interp proc do {script} {
            uplevel #0 $script
            return
        }

        $interp smartalias expand {text} 1 1 \
            [mymethod expandonce]

        $interp smartalias pass {} 0 0 \
            [mymethod pass]


        $interp clone template ::quill::template
        $interp clone tsubst   ::quill::tsubst
    }
}







