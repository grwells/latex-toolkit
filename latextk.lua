#!/usr/bin/lua
--[[
--  Author: Garrett Wells 
--  Date:   08/16/2023
--  This script defines a toolkit api for LaTeX projects.
--
--  The directory structure will be structured as follows:
--
--   ./
--   |
--   |
--   *--> src/
--   |        makefile
--   |        <latex source files>.tex
--   |
--   |
--   *--> include/
--   |           |
--   |           *--> diagrams/
--   |           |
--   |           *--> pictures/
--   |
--   |
--   *--> bibliography/
--   |                 <bib_file>.bib
--   |
--   *--> scripts/
--]]

function make_directory_structure (base) 
 -- make directory structure, substituting in base as project name
    mkdir_cmd_str = string.format("mkdir -p ./%s/src ./%s/include/pictures ./%s/include/diagrams ./%s/bibliography", base, base, base, base)
    os.execute(mkdir_cmd_str)
 -- create main latex file
    os.execute(string.format("touch ./%s/src/main.tex", base))
end

function clone_latex_toolkit ()
    -- clone toolkit from github
    os.execute([[git clone https://github.com/grwells/latex-toolkit.git ./scripts]])
end

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end


function create_new_project (base) 
    -- create a new LaTeX project directory
    txt = string.format("Project Name: %s ", base)
    cap = string.rep("*", string.len(txt) + 2)
    io.write(cap, "\n", txt, " *\n", cap, "\n")
    make_directory_structure(base)
    -- clone_latex_toolkit()
end


function infer_project_name (t)
    -- default function params
    -- all calls to this function must be of form infer_project_name{...}
    setmetatable(t, {__index={silent=true}})

    local fp = io.popen("basename $PWD", "r")
    local base = fp:read("*a")
    base = string.sub(base, 1, -2) -- remove newline character
    fp:close()

    txt = string.format("Project Name: %s", base)
    cap = string.rep("*", string.len(txt) + 2)
    
    if not silent then
        io.write(cap, "\n", txt, " *\n", cap, "\n")
    end

    return base
end

local argparse = require "argparse"

-- [[
-- Define arguments and flags for this program to be printed by argparse.
-- ]]
local parser = argparse() 
    :name "LaTeX - Toolkit"
    :description [[
██╗      █████╗ ████████╗███████╗██╗  ██╗              ████████╗██╗  ██╗
██║     ██╔══██╗╚══██╔══╝██╔════╝╚██╗██╔╝              ╚══██╔══╝██║ ██╔╝
██║     ███████║   ██║   █████╗   ╚███╔╝     █████╗       ██║   █████╔╝ 
██║     ██╔══██║   ██║   ██╔══╝   ██╔██╗     ╚════╝       ██║   ██╔═██╗ 
███████╗██║  ██║   ██║   ███████╗██╔╝ ██╗                 ██║   ██║  ██╗
╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝                 ╚═╝   ╚═╝  ╚═╝
                                                                        

A script for autogenerating, evaluating, and managing any LaTeX project. 
]]

parser:flag "-c --word-count"
    :description "print word count summary by section"
    :action(
        function(args)
            os.execute([[texcount ./src/main.tex]])
        end
    )

parser:flag "-g --generate-pdf"
    :description "compile and generate a pdf of the latex document in ./src/ using pdflatex command"
    :action(
        function(args)
            os.execute([[cd ./src/ && pdflatex main.tex]])
        end
    )

parser:flag "-p --print-pdf"
    :description "compile and generate a pdf and print on default printer"
    :action(
        function(args)
            os.execute([[cd ./src/ && pdflatex main.tex]])
            os.execute([[lpr ./src/main.pdf]])
        end
    )

parser:flag "-o --open-document" 
    :description "open the LaTeX document in ./src/ in NeoVim for editing"
    :action(
        function(args)
            os.execute([[nvim +TZAtaraxis ./src/main.tex]])
        end
    )

parser:flag "-v --view" 
    :description "open generated pdf without compiling"
    :action(
        function(args)
            os.execute([[xdg-open ./src/main.tex]])
        end
    )

parser:flag "-w --pdf-view" 
    :description "generate and open the pdf in the default system pdf viewer"
    :action(
        function(args)
            if file_exists("./src/main.pdf") then
                io.write("[DEBUG] building for bibtex")
                os.execute([[cd ./src/ && pdflatex main.tex && bibtex main && pdflatex main.tex && xdg-open main.pdf]])
            else
                os.execute([[cd ./src/ && pdflatex main.tex && xdg-open main.pdf]])
            end
        end
    )

parser:flag "-t --tree-view"
    :description "list directory structure and files in tree format"
    :action(
        function(args)
            os.execute([[find . | sed -e "s/[^-][^\/]*\//  |/g" -e "s/|\([^ ]\)/|-\1/"]])
        end
    )

parser:option "-n --new-project" 
    :description "generate a new project directory and default LaTeX file from scratch"
    :args "?"     
    :action(
        function(args, _, fn)
            print("project name: ", fn[1])
            make_directory_structure(fn[1])
        end
    )


local args = parser:parse()

