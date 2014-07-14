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
    # vocabs - List of macro vocabulary objectx

    variable info -array {
        pass   1
        vocabs {}
    }

    #---------------------------------------------------------------------
    # Options

    option -commands         \
        -default         all \
        -configuremethod ConfigureCommands

    method ConfigureCommands {opt val} {
        set options($opt) $val
        $interp configure -commands $val
    }

    # -brackets pair
    #
    # Sets a pair of macro-expansion brackets.
    option -brackets             \
        -default         {<< >>} \
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
    delegate method errmode     to errmode
    delegate method lb          to lb
    delegate method rb          to rb
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
    # Constructor

    constructor {args} {
        # FIRST, create the components
        install exp using [texutil::expander ${selfns}::exp]
        $exp setbrackets << >>

        install interp using [smartinterp ${selfns}::interp]

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

    # expand text
    #
    # text   - A string containing macros to expand
    #
    # Does a two-pass expansion and returns the result.

    method expand {text} {
        set info(pass) 1
        $exp expand $text
        set info(pass) 2
        set output [$exp expand $text]
        set info(pass) 1

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

    # reset 
    #
    # Resets the expander's macro interpreter.

    method reset {} {
        # FIRST, Recreate the smartinterp
        $interp destroy
        install interp using [smartinterp ${selfns}::interp]
        $interp configure -commands $opts(-commands)

        # NEXT, redefine the macros
        $self DefineLocalMacros
        $self DefineVocabularies
    }

    # DefineLocalMacros
    #
    # Defines the default macro set, which is quite small.

    method RedefineLocalMacros {} {
        # do script
        #
        # Executes the script in the expansion interpreter, leaving
        # no output.

        $interp proc do {script} {
            uplevel #0 $script
            return
        }

        # TBD Clone "template" in, once I've added template to the
        # quill(n) library.
    }
}







