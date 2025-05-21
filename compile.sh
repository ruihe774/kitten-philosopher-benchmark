#!/bin/sh
latexmk -pdflua -time -e '$lualatex=q/lualatex %O -shell-escape %S/' main.tex
