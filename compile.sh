#!/bin/sh -e

latexmk -xelatex -time supp-5.tex
latexmk -pdflua -time main.tex
