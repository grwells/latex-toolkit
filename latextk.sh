#!/bin/bash
# Author: Garrett Wells
# Date: 08/11/2023
#
# This script defines a toolkit api for LaTeX projects.
#
# The directory structure will be structured as follows:
#
#   ./
#   |
#   |
#   *--> src/
#   |        makefile
#   |        <latex source files>.tex
#   |
#   |
#   *--> include/
#   |           |
#   |           *--> diagrams/
#   |           |
#   |           *--> pictures/
#   |
#   |
#   *--> bibliography/
#   |                 <bib_file>.bib
#   |
#   *--> scripts/

function make_directory_structure () {
    # make directory structure
    mkdir -p ./$1/src ./$1/include/pictures ./$1/include/diagrams ./$1/bibliography
    echo "moving to project directory $1/"
    # create main latex file
    touch ./$1/src/$1.tex
}

function clone_latex_toolkit () {
    # clone toolkit from github
    git clone https://github.com/grwells/latex-toolkit.git ./scripts
}

function create_new_project () {
    # create a new LaTeX project directory
    echo "
    ********************************
    * LaTeX Project: $1      *
    ********************************"
    make_directory_structure $1
    clone_latex_toolkit $1
}


project_name=$(basename $(pwd))

# process command line arguments
case "$1" in

    wc) texcount ./src/$project_name.tex
        ;;

    pdf) 
        cd ./src/
        pdflatex $project_name.tex
        ;;

    pdf-print) 
        cd ./src/
        pdflatex $project_name.tex && lpr $project_name.pdf
        ;;

    open) nvim -c TZAtaraxis ./src/$project_name.tex
        ;;

    view) xdg-open ./src/$project_name.pdf
        ;;

    pdf-view)
        cd ./src/
        pdflatex $project_name.tex
        xdg-open $project_name.pdf
        ;;

    create) 
        read -p "enter project name > "
        create_new_project $REPLY
        ;;

    *)  echo "invalid option"
        ;;
esac
